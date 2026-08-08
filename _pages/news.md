---
layout: page
title: news
permalink: /news/
nav: true
nav_order: 5
---

{% include news.liquid %}

<!-- Items live in _news/ (front matter: layout: post, date, inline: true for a one-liner).
     Every one of them is sourced from the academic record the hub session maintains.

     Two rules:

     1. Only things that have actually happened — a paper published, a talk given, an
        award received, a position started. Never "submitted", "under review" or
        "accepted pending revision" on a public page.

     2. Do not invent date precision. Most of these are recorded to a month or an
        academic term, so `date:` is a sort key and _includes/news.liquid prints the
        year alone. If an item needs a real day, put it in the item's own text. -->
