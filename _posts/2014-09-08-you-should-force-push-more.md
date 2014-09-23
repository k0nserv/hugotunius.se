---
layout: post
title:  "You should force push more"
categories: git vsc
---
Git's force push feature is the source of a lot of controversy and errors. It's widely considered to be dangerous and left for use only in extreme situations. I use it every single day.

The atlassian [guide](https://www.atlassian.com/git/tutorial/remote-repositories#!push) on git offers the following advice.

> Same as the above command, but force the push even if it results in a non-fast-forward merge. Do not use the --force flag unless you’re absolutely sure you know what you’re doing.

[sensible.io](http://sensible.io/) has a [blog post](http://blog.sensible.io/2012/10/09/git-to-force-put-or-not-to-force-push.html) dedicated to the subject with the final words

> Use force push only as a last resort when everything else fails. Things might get ugly for you and for your repository.

In November 2013 the developers of [Jenkins](http://jenkins-ci.org/) had a huge problem at their hands when one of the developers accidentally [force pushed more than 150 repositories](https://news.ycombinator.com/item?id=6713742).

### Ground rules

As warned above force push is quite a powerful feature which will cause issues when used incorrectly. Therefore we need to establish some ground rules before doing any force pushing.

**1** Force pushing to the master or development branches should be avoid at all costs. If it is absolutely necessary it should be coordinated with all developers in the team. If possible force pushing should be disabled for these branches.

**2** Work should not be done in master or development, but in [feature branches](https://www.atlassian.com/git/workflows#!workflow-feature-branch). Features should be small enough that only one developer work in the each branch or in a fork of the main repository.

**3** Commits are considered immutable only after they have been merged into master or development. Before that they maybe be reordered, squashed and deleted at will.

With these grounds rules established we can now look at a few scenarios when it's useful to use force push.

### Cleaning up the intention of a feature branch

Let's say I am working on implementing a method in a JavaScript project. My initial implementation looks like this

{% highlight javascript line %}
// fib.js
var fbi = function(i) {
    if (i == 0 || i == 1) {
        return i;
    }

    return fbi(i - 1) + fbi(i - 2);
};
{% endhighlight %}

I make a commit and submit a PR. My git log now looks like this

{% highlight text line %}
* 7492f01 (HEAD, origin/add-fibonacci-implementation) Implement Fibonacci sequence
* aa1fdb3 (develop, origin/develop) Solve halting problem
{% endhighlight %}

The PR is reviewed and luckily someone finds my spelling mistake. So I fix it.

{% highlight text line %}
* 97f5b3d (HEAD, origin/add-fibonacci-implementation) Rename incorrectly 
named fbi to fib 
* 7492f01 Implement Fibonacci sequence
* aa1fdb3 (develop, origin/develop) Solve halting problem
{% endhighlight %}

It was also pointed out that I didn't wrap my code in an anonymous self executing function so I fix that too.

{% highlight text line %}
* aaf7382 (HEAD, origin/add-fibonacci-implementation) Wrap Fibonacci 
implementation in anonymous self executing function
* 97f5b3d Rename incorrectly named fbi to fib
* 7492f01 Implement Fibonacci sequence
* aa1fdb3 (develop, origin/develop) Solve halting problem
{% endhighlight %}

Lastly someone points out that this function would fit better in `math.js` so I move it there.

{% highlight text line %}
* d270e1a (HEAD, origin/add-fibonacci-implementation) Move Fibonacci
implementation to math.js
* aaf7382 Wrap Fibonacci implementation in anonymous self executing function
* 97f5b3d Rename incorrectly named fbi to fib
* 7492f01 Implement Fibonacci sequence
* aa1fdb3 (develop, origin/develop) Solve halting problem
{% endhighlight %}

This is my final implementation

{% highlight javascript line %}
(function() {
    "use strict";
    var fib = function(i) {
        if (i == 0 || i == 1) {
            return i;
        }

        return fbi(i - 1) + fbi(i - 2);
    };    
})();
{% endhighlight %}

If we now merge this PR we will merge 4 commits out of which 3 are just fixing issues in the first one. Instead of merging the PR I use interactive rebase to squash all commits into a single commit which reflects the work done in this feature branch.

{% highlight bash line %}
> git rebase -i aa1fdb3
{% endhighlight %}

My final git log is

{% highlight text line %}
* 134c072 (HEAD, origin/add-fibonacci-implementation) Implement Fibonacci sequence
* aa1fdb3 (develop, origin/develop) Solve halting problem
{% endhighlight %}

I try to push my changes, but I can't. My push is being rejected by the remote.

{% highlight text line %}
To git@git.url.com:url.git
 ! [rejected]        add-fibonacci-implementation -> add-fibonacci-implementation 
 (non-fast-forward)
error: failed to push some refs to 'git@git.url.com:url.git'
To prevent you from losing history, non-fast-forward updates were rejected
Merge the remote changes before pushing again.  See the 'Note about
fast-forwards' section of 'git push --help' for details.
{% endhighlight %}

Here force push comes to the rescue, the PR is merged and the git log of the repository is kept unpolluted by useless commits.

### Forgetting that one thing

Again let's say I am implementing some feature with the following code

{% highlight javascript line linenos %}
var implodeUniverse = function () {
    universe.implode();
    universe = null;
};
{% endhighlight %}

I commit my changes and end up with a git log like the following.

{% highlight text line %}
* fc26bb2 (HEAD, origin/add-support-for-universe-implode) Implement imploding 
the universe
* aa1fdb3 (develop, origin/develop) Solve halting problem
{% endhighlight %}

Just as I push my changes to the remote I realise that I forgot to check the answer before imploding the universe. I have to modify my code a bit.

{% highlight javascript line linenos %}
var implodeUniverse = function (answer) {
    if (answer == 42) {
        return;
    }

    universe.implode();
    universe = null;
};
{% endhighlight %}

At this point I could make another commit and then push it. A commit message like **"Add check of answer before imploding universe"** would have made sense here, however the answer check is really something that should have been in the original commit. It is not deserving of its very own commit. A better solution to this problem is:

{% highlight bash line %}
> git add -A
> git commit --amend 
> git push origin add-support-for-universe-implode -f
{% endhighlight %}

Now I can open my pull request and maintain a clean git log without surplus commits.

### Merging a diverged branch

In some cases your branch might diverge from the branch it was forked off of. When this happens GitHub shows the following UI:

![](/img/github_merge_fail.png)

These are the steps that GitHub suggests to resolve this issue

{% highlight bash line %}
# Step 1: From your project repository, bring in the changes and test.
git fetch origin
git checkout -b branch-name origin/branch-name
git merge base-branch

# Step 2: Merge the changes and update on GitHub.
git checkout base-branch
git merge --no-ff branch-name
git push origin base-branch
{% endhighlight %} 

The problem with this solution is that you will unfortunately create a merge commit which looks like this

{% highlight text line %}
Merge branch 'base-branch' into branch-name
{% endhighlight %}

Commits like these will pollute your commit log and make it harder to read. They should be avoided when they are not the result of a PR or syncing develop/master with each other. Instead we can use a combination of rebase and force push to solve the problem.

{% highlight bash line %}
git fetch --all
git checkout -b branch-name origin/branch-name
git rebase base-branch
# We resolve any conflicts as we would in a merge 
# git rebase --abort can be used to revert to before 
# the rebase started if we make a mistake

# When we are done we simply do a force push
git push origin branch-name -f
{% endhighlight %}

### Conclusion

Force push is an extremely powerful ally when utilised correctly. It helps a team keep the git log clean from surplus and misleading commits by instead making the intent of each feature branch and each commit clearer. However a good branching model and workflow is required to support heavy usage of force push. The fact that commits are not considered immutable and sacred until they have been merged into a stable branch is very important if force push is to be used heavily. The forking model used for open source projects on GitHub works very well with this paradigm of force pushing. As a policy I always use rebase and force push to clean-up my pull request just before being merged into the forked repository.

### Log comparison
The following is a comparison between using and not using the techniques I've showed in this post.

**Without force push**
{% highlight text line %}
*   beb4bb2 (HEAD, master) Merge pull request #3 from repo/fix-issue-in-halting-problem-solution
|\
| *   8b7e651 (fix-issue-in-halting-problem-solution) Merge branch 'master' into fix-issue-in-halting-problem-solution
| |\
| |/
|/|
* | b9b34a6 Some other work
| * 2e36a3e Fix issue in halting problem
|/
*   44a0a3b Merge pull request #2 from repo/add-support-for-universe-implode
|\
| * f765021 (add-support-for-universe-implode) Add check of answer before imploding universe
| * 77b212c Implement imploding the universe
|/
*   867ee6c Merge pull request #1 from repo/add-fibonacci-implementation
|\
| * cbefffc (add-fibonacci-implementation) Move fibonacci implementation to math.js
| * 7fcbc1d Wrap Fibonacci implementation in anonymous self executing function
| * 1bd7afd Rename incorrectly named fbi to fib
| * c19e08b Implement Fibonacci sequence
|/
* 9ab66f2 Solve halting problem
{% endhighlight %}

**With force push**
{% highlight text line %}
*   a695ebf (HEAD, master) Merge pull request #3 from repo/fix-issue-in-halting-problem-solution
|\
| * 9d94892 (fix-issue-in-halting-problem-solution) Fix issue in halting problem
|/
* 1cef0ed Some other work
*   5e2f2ca Merge pull request #2 from repo/add-support-for-universe-implode
|\
| * 9850906 (add-support-for-universe-implode) Implement imploding the universe
|/
*   cb01283 Merge pull request #1 from repo/add-fibonacci-implementation
|\
| * e1eb155 (add-fibonacci-implementation) Implement Fibonacci sequence
|/
* 5576d02 Solve halting problem
{% endhighlight %}




 
