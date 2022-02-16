---
layout: post
title: "NFTs, How Do They Work?"
categories: nfts ethereum opinion
date: 2022-01-16
description: > 
  An attempt to explain NFTs in a mostly accurate way, that requires minimal technical understanding 
---

Freaking ~~magnets~~  NFTs, how do they work? In this post I'll try to explain NFTs in a way that's mostly accurate, but requires minimal technical understanding. I'm going to assume the reader is familiar with excel style software and [Google Sheets](https://www.google.co.uk/sheets/about/) in particular.

At its core every NFT project is like a single Google Sheet. It has a creator who has some special permission to modify the sheet. 

An NFT within the project is like a single row in the sheet. Each row contains only two things: a name and an id. For example, if my NFT has 10,000 unique tokens then I could use the ids from 1 through 10,000 to identify each token.

<span aria-hidden="true">
[![]({{ 'img/nfts-how-do-they-work/empty-sheet.png' | asset_url }})](/img/nfts-how-do-they-work/empty-sheet.png)
</span>

To begin with the sheet is empty. The creator might assign themselves a few tokens by creating new rows with their own name and some ids. Then they invite other people to "mint" new tokens and gain rows with their name in them. In order to mint, the user has to pay the creator a small fee(for example via Venom). In return for payment a row is added to the sheet containing the user's name and a randomly selected unassigned id. In addition the user is given permission to change who owns the id they were allocated, this facilitates selling their token. Eventually all 10,000 tokens run out and there are no longer unassigned ids. The creator will now refuse to mint more tokens.

<span aria-hidden="true">
[![]({{ 'img/nfts-how-do-they-work/minted-sheet.png' | asset_url }})](/img/nfts-how-do-they-work/minted-sheet.png)
</span>

Users can sell their row in the sheet to other people. When they do, they update the name in the row to the buyer's name and in so doing loses the ability to change it.

Now you might be saying: but aren't NFTs, like, ugly pictures of monkeys? Yes they can be and often are images, but they don't have to be. Further, what's actually stored is just an id as I've described. 

So how do you get the picture of your ugly monkey to show off to your friends? You use a special URL, which is stored in a cell somewhere in the sheet, and then append your token's id to it. For example, the URL might be `https://ugly-monkeys.com/` and if you own monkey #54 then its image can be found at `https://ugly-monkeys.com/54`. Depending on how the creator has set things up they might be able to change the URL in the sheet. Maybe tomorrow your ugly monkey will become a zebra, because the creator changed the URL to `https://ugly-zebras.com`, exciting!

Now instead of a Google Sheet imagine all this data lives on a Blockchain, for example [Ethereum](https://ethereum.org/en/), and that's mostly how it all works.

## Caveats 

This section contains some caveats about analogy above. They aren't super important, but if you are interested read on.

1. Almost all of the steps outlined above are executed by the sheet(it's actually a [smart contract](https://en.wikipedia.org/wiki/Smart_contract)) itself. The creator creates the contract and they can have special permission to withdraw funds stored in the contract and change some properties of it, but the minting and selling process is handled by the contract. 
2. The contact is running on a decentralised network of computers that power the Blockchain in question. This is very unlike Google Sheets(which is centralised), were Google are ultimately in control and could change the sheet at will. 
3. The example of monkeys turning into zebras above is not made up. This is possible in real NFTs, for example in the most famous NFT project: [Bored Ape Yacht Club](https://boredapeyachtclub.com/#/).
4. In the case of Ethereum(as of February 2022) running this decentralised network of computers consumes an absurd amount of energy and generates massive electronic waste. This isn't just because the network contains a lot of computers, at its core Blockchains like Ethereum are intentionally extremely wasteful.
