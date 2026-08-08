---
layout: page
title: news
permalink: /news/
nav: false # ★ hidden until _news/ contains at least one real, verified item
nav_order: 5
sitemap: false # keep the empty placeholder out of search engines; remove when the page goes live
---

{% include news.liquid %}

<!-- Hidden from the navigation because _news/ is currently empty (the three al-folio
     demo announcements were deleted). An empty News page reads as a broken site.

     To turn it on: add a file to _news/ (front matter: layout: post, date, inline: true
     for a one-liner), then set nav: true above and flip `announcements.enabled` to true
     in _pages/about.md so the items also show on the front page.

     Only post things that have actually happened — an accepted paper, a talk given, an
     award received. No "submitted" or "under review" items on a public page. -->
