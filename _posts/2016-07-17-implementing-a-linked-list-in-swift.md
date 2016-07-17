---
title: Implementing a Linked List in Swift 3
layout: post
categories: swift data-structures
date: 2016-07-17
description: >
  In this post I show how to implement
  a Linked List in Swift 3
---

In this post I'll show how to implement a Linked List in Swift 3. For this post there's also a Playground version that works with Xcode 8 Beta 2 and above. If you prefer to read it you can find it [here](/files/LinkedList.playground.zip).

Linked lists are type of list with certain characteristics relating to the performance of insertion, deletion, and traversal.
They are valuable when maintaining lists where reference items don't need to be looked up by index and the performance of insertion and
deletion is important. Linked list works by having each node in the list maintain a reference to the next node. Here we'll implement
what's called a doubly linked list where each node contains a list to the previous as well.

## Nodes
To start of we need to implement a node container that will hold our values and the reference to the next and previous values.
We'll make it generic over the type T. Because Linked List are based on reference semantics we are going to use a class rather
than a struct. We adopt `CustomStringConvertible` for nicer output.

{% highlight swift %}
public class Node<T: Equatable> {
    typealias NodeType = Node<T>

    /// The value contained in this node
    public let value: T
    var next: NodeType? = nil
    var previous: NodeType? = nil

    public init(value: T) {
        self.value = value
    }
}

extension Node: CustomStringConvertible {
    public var description: String {
        get {
            return "Node(\(value))"
        }
    }
}
{% endhighlight %}

Note that the type of `next` and `previous` are `NodeType?` because it's valid for a node to not have a next or previous node. The start
node will not have a previous node and the end node will never have a next node.

## The List itself
Now let's build the initial list structure. It will have two references, the start and end nodes, a count, a `isEmpty` method at first. Again
the start and end nodes are optional because a list can be empty, however one invariant is that a non empty list always has both a start
and end node. We are making the list a class rather than a struct for reasons that'll become apparent when we talk about copy-on-write in the end.

{% highlight swift %}
public final class LinkedList<T: Equatable> {
    public typealias NodeType = Node<T>

    private var start: NodeType? {
        didSet {
            // Special case for a 1 element list
            if end == nil {
                end = start
            }
        }
    }

    private var end: NodeType? {
        didSet {
            // Special case for a 1 element list
            if start == nil {
                start = end
            }
        }
    }

    /// The number of elements in the list at any given time
    public private(set) var count: Int = 0

    /// Wether or not the list is empty. Returns `true` when
    /// count is 0 and `false` otherwise
    public var isEmpty: Bool {
        get {
            return count == 0
        }
    }

    /// Create a new LinkedList
    ///
    /// - returns: An empty LinkedList
    public init() {

    }

    /// Create a new LinkedList with a sequence
    ///
    /// - parameter: A sequence
    /// - returns: A LinkedList containing the elements of the provided sequence
    public init<S: Sequence where S.Iterator.Element == T>(_ elements: S) {
        for element in elements {
            append(value: element)
        }
    }
}
{% endhighlight %}

This is the basic structure of our linked list. Of course we cannot do anything with it quite yet.

## Operations

Let's implement some operations so that we can actually use our linked list productively. We'll start by implementing
the basics `append`, `remove`, `nodeAt`, and `valueAt`. You might think that `nodeAt` and `valueAt` does the same thing, but as we'll
see returning the node allows us to then use the node when calling `remove`.

### Append

{% highlight swift %}
extension LinkedList {

    /// Add an element to the front of the list.
    ///
    /// - complexity: O(1)
    /// - parameter value: The value to add
    public func append(value: T) {
        let previousEnd = end
        end = NodeType(value: value)

        end?.previous = previousEnd
        previousEnd?.next = end

        count += 1
    }
}
{% endhighlight %}

This is fairly straightforward. We first find the previous end node, make a new end node with the provided value and then update the next node
for the previous node and the previous node for the new end node. Note that this works both for the case when there was a `previousNode` and
when there wasn't. There's no need to check `previousNode` for `nil` instead we can use the `?` operator.

### Finding values and nodes by index

Now let's implement node/value lookup. Let's start with a private helper function that makes it simple to iterate over all nodes and optionally
stop when we find something interesting. This will have complexity O(n) since it needs to go through all nodes in the worst case.

{% highlight swift %}
extension LinkedList {

    /// Utility method to iterate over all nodes in the list invoking a block
    /// for each element and stopping if the block returns a non nil `NodeType`
    ///
    /// - complexity: O(n)
    /// - parameter block: A block to invoke for each element. Return the current node
    ///                    from this block to stop iteration
    ///
    /// - throws: Rethrows any values thrown by the block
    ///
    /// - returns: The node returned by the block if the block ever returns a node otherwise `nil`
    private func iterate(block: (node: NodeType, index: Int) throws -> NodeType?) rethrows -> NodeType? {
        var node = start
        var index = 0

        while node != nil {
            let result = try block(node: node!, index: index)
            if result != nil {
                return result
            }
            index += 1
            node = node?.next
        }

        return nil
    }
}
{% endhighlight %}

Now that we have our `iterate` function we can start using it by implementing `nodeAt` and `valueAt`

{% highlight swift %}
extension LinkedList {

    /// Return the node at a given index
    ///
    /// - complexity: O(n)
    /// - parameter index: The index in the list
    ///
    /// - returns: The node at the provided index.
    public func nodeAt(index: Int) -> NodeType {
        precondition(index >= 0 && index < count, "Index \(index) out of bounds")

        let result = iterate {
            if $1 == index {
                return $0
            }

            return nil
        }

        return result!
    }

    /// Return the value at a given index
    ///
    /// - complexity: O(n)
    /// - parameter index: The index in the list
    ///
    /// - returns: The value at the provided index.
    public func valueAt(index: Int) -> T {
        let node = nodeAt(index: index)
        return node.value
    }
}
{% endhighlight %}

### Removing

Let's now add the ability to remove values and nodes from the linked list. Here we'll see why `nodeAt` is important to support fast removals.

{% highlight swift %}
extension LinkedList {

    /// Remove a give node from the list
    ///
    /// - complexity: O(1)
    /// - parameter node: The node to remove
    public func remove(node: NodeType) {
        let nextNode = node.next
        let previousNode = node.previous

        if node === start {
            start = node.next
        } else if node === end {
            end = node.previous
        } else {
            previousNode?.next = nextNode
            nextNode?.previous = previousNode
        }

        count -= 1
        assert(
            (end != nil && start != nil && count != 1) || (end == nil && start == nil && count == 0),
            "Internal invariant not upheld at the end of remove"
        )
    }

    /// Remove a give node from the list at a given index
    ///
    /// - complexity: O(n)
    /// - parameter atIndex: The index of the value to remove
    public func remove(atIndex index: Int) {
        precondition(index >= 0 && index < count, "Index \(index) out of bounds")

        // Find the node
        let result = iterate {
            if $1 == index {
                return $0
            }
            return nil
        }

        // Remove the node
        remove(node: result!)
    }
}
{% endhighlight %}

As you can see here `remove(atIndex:)` is O(n) because it has to first find the node at the given index before removing it
while `remove(node:)` is only O(1) because the node is already given. An implementation of `remove(value:)` would also be
O(n) because it would have to find the correct node in a similar way as `remove(atIndex:)`

## Making the list swiftier

The swift runtime provides a set of protocols that we can adopt to make instances of `LikendList` behave more like any
of the other collections in swift.

### `Sequence`

The [`Sequence`](https://developer.apple.com/library/ios/documentation/Swift/Reference/Swift_SequenceType_Protocol/)
protocol(was `SequenceType` in Swift 2) allows the list to be iterated over using the `for..in` construct and adds a bunch
of new methods to the type. Some of these are `forEach`, `map`, and `filter`.

All we have to do to get all this is implement the method `makeIterator` that returns an iterator conforming to the
`IteratorProcotol`. Let's first create the iterator `LinkedListIterator`. A question to ask is wether the Iterator
should be an iterator of `T` or of `Node<T>`. I'm opting for `Node<T>` here.

{% highlight swift %}
public struct LinkedListIterator<T: Equatable>: IteratorProtocol {
    public typealias Element = Node<T>

    /// The current node in the iteration
    private var currentNode: Element?

    private init(startNode: Element?) {
        currentNode = startNode
    }

    public mutating func next() -> LinkedListIterator.Element? {
        let node = currentNode
        currentNode = currentNode?.next

        return node
    }
}
{% endhighlight %}

And now we conform to `Sequence` by implementing `makeIterator`

{% highlight swift %}
extension LinkedList: Sequence {
    public typealias Iterator = LinkedListIterator<T>

    public func makeIterator() -> LinkedList.Iterator {
        return LinkedListIterator(startNode: start)
    }
}
{% endhighlight %}

And now we can do things like

{% highlight swift %}
var list = LinkedList<Int>()
list.append(value: 10)
list.append(value: 20)
list.append(value: 30)

for node in list {
    print("\(node)")
}

let values: [Int] = list.map {
    $0.value
}
{% endhighlight %}

It's also possible to implement `Collection` for further benefits such as subscript support. However `Collection`s generally feature
O(1) subscript behaviour and since our LinkedList is O(n) it might be confusing to do so. I'm opting to skip it

### Copy on Write

Most data structures in Swift are structs, but use a method called copy-on-write(COW) to reduce the amount of copying required by
only copying the data structure before writes. Let's implement this for our LinkedList. The general idea is to create a struct that wraps
our LinkedList and delegates task to the underlying class. When mutating methods are invoked we'll explicitly make a copy of the underlying
class and perform the actions on that copy. We also need to add a method to copy all the underlying data in our LinkedList.

{% highlight swift %}
extension LinkedList {
    func copy() -> LinkedList<T> {
        let newList = LinkedList<T>()

        for element in self {
            newList.append(value: element.value)
        }

        return newList
    }
}

// Typically you'd call this class `LinkedList`
// and the wrapped struct `_LinkedList` or `LinkedListStorage`.
// The internal implementation would be marked private and
// this is the interface you'd expose.
public struct LinkedListCOW<T: Equatable> {
    public typealias NodeType = Node<T>

    private var storage: LinkedList<T>
    private var mutableStorage: LinkedList<T> {
        mutating get {
            // Only copy if there are multiple references
            // to storage
            if !isUniquelyReferencedNonObjC(&storage) {
                storage = storage.copy()
            }

            return storage
        }
    }

    public init() {
        storage = LinkedList()
    }

    public init<S: Sequence where S.Iterator.Element == T>(_ elements: S) {
        storage = LinkedList(elements)
    }

    public var count: Int {
        get {
            return storage.count
        }
    }

    public var isEmpty: Bool {
        get {
            return storage.isEmpty
        }
    }

    public mutating func append(value: T) {
        mutableStorage.append(value: value)
    }

    public func nodeAt(index: Int) -> NodeType {
        return storage.nodeAt(index: index)
    }

    public func valueAt(index: Int) -> T {
        let node = nodeAt(index: index)
        return node.value
    }


    public mutating func remove(node: NodeType) {
        mutableStorage.remove(node: node)
    }

    public mutating func remove(atIndex index: Int) {
        mutableStorage.remove(atIndex: index)
    }
}
{% endhighlight %}

For brevity I'm skipping over implementing `Sequence` for `LinkedListCOW`. As you can see from the implementation of
`LinkedListCOW` we simply delegate all read-only calls to the underlying `LinkedList` called `storage`. However
for mutating methods(`remove(node:)`, `remove(atIndex:)`, and `append(value:)`) we use the property `mutableStorage`
that first makes a copy for the storage for us if the storage is not uniquely referenced e.g if more than one object has
a reference to it. To illustrate this let's implement `CustomStringConvertible` and print the storage's position in memory.

{% highlight swift %}
extension LinkedListCOW: CustomStringConvertible {
    public var description: String {
        get {
            let address = unsafeAddress(of: storage)
            return "LinkedListCOW(storage: \(address))"
        }
    }
}


let list1 = LinkedListCOW([1, 2, 3])
var list2 = list1

print("List 1: \(list1), count: \(list1.count)")
print("List 2: \(list2), count: \(list2.count)")

let first1 = list1.nodeAt(index: 0)
let first2 = list2.nodeAt(index: 0)

print("List 1 first node: \(list1)")
print("List 2 first node: \(list2)")

print("Modify list 2")
list2.append(value: 4) // Modify list2 causes copy

print("List 1: \(list1), count: \(list1.count)")
print("List 2: \(list2), count: \(list2.count)")
{% endhighlight %}

As you can see here when we assign `list1` to `list2` we are performing a struct copy, but we are only copying the reference to the internal
`storage` which is a very cheap operation. As long as we don't make any modifications to `list2` both structs share the same underlying storage.
It's only when we append to `list2` that the copy occurs, hence copy-on-write.


