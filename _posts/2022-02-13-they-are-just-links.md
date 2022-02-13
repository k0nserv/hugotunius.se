---
layout: post
title: "They Are Just Links"
categories: nfts ethereum opinion
date: 2022-01-13
description: > 
  On the promises of NFTs and they're actual purpose as a speculative asset with no regard for artists or decentralisation.
---

NFTs exploded into mainstream popularity in the latter half of 2021 and if you follow me on Twitter you'll know I'm not a fan. In "crypto"-speak I'm [NGMI(not gonna make it)](https://blog.libertasbella.com/glossary/ngmi/). But what are NFTs anyway?

The common meme is that NFTs are kind of like receipts or, more charitably, certificates of ownership. The ugly monkey you buy is actually a piece of state maintained in a smart contract on a Blockchain, typically Ethereum. Ethereum based NFTs implement the [EIP-721](https://eips.ethereum.org/EIPS/eip-721) standard. This standard describes the behaviour that a smart contract should implement to be an NFT. NFTs aren't exclusively visual art, but that's the most common form so let's roll with it. 

Let's use the [ugly monkeys](https://boredapeyachtclub.com/#/) as an example. The [contract](https://etherscan.io/address/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d) supports the metadata extension for EIP-271, which specifies the method:

{% highlight solidity %}
tokenURI(uint256 tokenId) external view returns (string);
{% endhighlight %}

Given a token id return a URI that points to its metadata. For the ugly monkeys the URI looks like this `https://us-central1-bayc-metadata.cloudfunctions.net/api/tokens/{token_id}`. That domain doesn't look particularly decentralised, in fact it's part of Google cloud. If Google goes out of business or otherwise lose access to this domain who knows what your ugly monkey will be pointing to in the future. To boot Google are [notorious](https://killedbygoogle.com/) for sun setting products. With GCP maybe they'll not be as aggressive, but it's not hard to imagine a future were Google changes the structure of cloud function URLs. A change like that would have a long grace period and most users would easily migrate since changing a URL is not that hard. Except if you have locked the URL inside an immutable smart contract on the Ethereum Blockchain that is.

Here's a concrete example with ugly monkey `#5465`.

{% highlight bash %}
$ curl https://us-central1-bayc-metadata.cloudfunctions.net/api/tokens/5465
{% endhighlight %}

{% highlight json %}
{
  "image": "https://ipfs.io/ipfs/Qmbijgmi1APqH2UaMVPkwoAKyNiBEHUjap54s3MAifKta6",
  "attributes": [
    {
      "trait_type": "Background",
      "value": "Gray"
    },
    {
      "trait_type": "Clothes",
      "value": "Stunt Jacket"
    },
    {
      "trait_type": "Fur",
      "value": "Dark Brown"
    },
    {
      "trait_type": "Mouth",
      "value": "Phoneme  ooo"
    },
    {
      "trait_type": "Hat",
      "value": "Short Mohawk"
    },
    {
      "trait_type": "Eyes",
      "value": "Crazy"
    }
  ]
}
{% endhighlight %}

The image of the ugly monkey is stored on [IPFS](https://en.wikipedia.org/wiki/InterPlanetary_File_System) which is at least decentralised, although the ipfs.io gateway isn't.

## It's all About Ownership

NFT ~~shillers~~ proponents will tell you NFTs are all about proving ownership. What does a given NFT actually prove? Mostly that there's some state locked in an Ethereum contract where your wallet is recorded as the owner.

Here's a pop quiz: Which of these two is the BAYC contract and which is my own NFT UMBC(Ugly Monkey Boat Cabal)?

1. `0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D` 
1. `0xBC4CA0EdA9647A8aB7C2061c2E118A18a936f13D`

If you guessed `2` congrats, you correctly identified my superior NFT, UMBC.

UMBC doesn't exist, I would never actually create an NFT. However, there's an interesting conundrum here: If I duplicate the BAYC contract and deploy it, how can someone tell the difference between mine and the original? 

This question came up when Twitter launched support for [NFT profile pictures](https://help.twitter.com/en/using-twitter/twitter-blue-fragments-folder/nft), which are displayed as hexagons. People were angry at Twitter for not launching with the concept of "verified collections". BAYC would be a verified collection, UMBC would not.

However, the whole notion of a "verified collection" hints at a bigger problem: who does the verifying? It's weird for an, ostensibly, decentralised concept to become useless without introducing a centralised entity like a verifier. [OpenSea](opensea.io), the leading NFT marketplace, is rapidly filling the role of verifier and central authority in the NFT space. It has banned several NFTs from its platform, effectively dooming those projects. The centralisation on OpenSea is already so significant that OpenSea having an outage [took down Twitter's NFT feature](https://www.vice.com/en/article/g5qjej/people-cant-see-some-nfts-in-crypto-wallets-after-opensea-goes-down). So much for the promise of decentralisation.

## Wait, It's Not 2007?!

If you squint, NFTs are awfully similar to torrents and there are interesting parallels with the legal battles between The Pirate Bay and the entertainment industry circa 2007.

Back in those olden days a common defence employed by pirates was that the torrents are just links, they don't actually contain any content and thus aren't and couldn't be infringing on copyright. The point that both Google and The Pirate Bay could be used to find torrent files was a frequent argument. 

You can make a very similar argument about my hypothetical UMBC NFT described above. It would simply contain links, perhaps the same ones that BAYC uses, to metadata and artwork. I'm not a lawyer, but I don't see how that can be construed as a copyright violation, they're just links after all. Of course UMBC would get immediately banned from OpenSea, effectively killing the project. 

## The Decentralisation That Wasn't

It turns out NFTs aren't particularly decentralised. The most popular NFT directly depends on Google's cloud and the links it stored on the Ethereum Blockchain could all stop resolving tomorrow. Knowing the NFT space such an event would, paradoxically, increase the value of the ugly monkeys.

Even if you can, in theory, mint anything as an NFT, good luck getting anywhere when you end up banned from OpenSea. Your project might as well not exist at that point.


NFTs remain a solution in search of a problem. A speculative, hype-driven scam were neither the art nor the decentralisation is important, making a quick buck by not being the greater fool is.
