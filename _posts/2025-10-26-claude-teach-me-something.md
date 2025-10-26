---
layout: post
title: "Claude, Teach Me Something"
date: 2025-10-26
description: >
    Leveraging Claude to learn, instead of doom scrolling with a touch of the Socratic method.
categories: ai claude
---

I've been experimenting with a new Claude workflow as an alternative to doom scrolling. It leverages what LLMs do best: non-determinism and text. I call it "Teach me something". 

The idea is: if I'm bored, instead of going on Reddit, I can ask Claude to teach me something. This might not be the most efficient learning method, but it beats scrolling Reddit. In Claude I've set this up as a project with custom instructions. The prompt I'm currently using is:

> **Project Instructions: Socratic Teaching Sessions**
> 
> In this project you will teach me something new using the **Socratic method** - asking questions to gauge my knowledge and guide my discovery rather than simply explaining concepts.
> 
> **Areas (in order of my decreasing expertise):**
> 
> - Programming
> - Computer science
> - UX/UI/UXR
> - Cybersecurity
> - Machine learning
> - Cooking
> - Physics
> - Economics (behavioral or otherwise)
> - Psychology
> - Engineering 
> - Music theory
>
> **Your approach:**
> When I say “Teach me something,” you will perform the following steps. If I say "Teach me something about \<topic\>" you skip the first 2 steps.
> 
> 1. Consult previous chats in this project to avoid repetition
> 1. Choose a diverse topic from one of my areas 
> 1. **Use questions to assess what I already know**
> 1. **Guide me toward insights through dialogue** rather than direct explanation
> 1. Let my responses shape the direction and depth of the lesson
> 
> **Goal:** Help me discover and understand concepts through guided inquiry, building on what I know and filling gaps through my own reasoning.
> 
> Keep the topics diverse across sessions.
> 
> At the end of a session direct me towards primary sources to confirm and read more. Prefer websites, papers, podcast, and books in that order.

This works nicely. The topic diversity has been good and the Socratic method works, especially because Claude gauges and responds to my prior knowledge. So far Claude has taught me about The Allais Paradox, the physics of consonance, and the chemistry of salt in cooking, to name a few. Claude can list previous chats within a project to keep track of topics. The only point of friction, is ensuring chats are named correctly as Claude will often just name them "Learn something new" based on the first user interaction. Claude lacks a tool call to rename chats, so instead I've been asking it to suggest a name at the end and then I rename the chat myself. The last instruction in the prompt ensures I can verify what Claude has said and dig deeper.

Initially I didn't instruct Claude to use the Socratic method, but that works much better. It's significantly less "information-dumpy". When I know a topic well, Claude successfully shortcuts the basics.

This effectively combines two strengths of LLMs: non-determinism and text. The topics are kept diverse and I rely on Claude's vast knowledge of topics to find interesting points of discussion. Claude, and all LLMs, are great at conversation and this extends to the back and forth of the Socratic method. At the end, the provided sources protect against hallucination and offer a next step beyond the LLM.
