---
layout: cv
permalink: /cv/
title: CV
nav: false # ★ hidden until the hub session delivers the rendered CV PDF and _data/cv.yml
nav_order: 3
sitemap: false # keep the empty placeholder out of search engines; remove when the page goes live
cv_pdf: # set to /assets/pdf/cv.pdf once the file exists, then flip nav to true
cv_format: rendercv # options: rendercv, jsonresume
description: Curriculum vitae.
toc:
  sidebar: left
---

{% comment %}
  Hidden from the navigation on purpose.

  This page renders from _data/cv.yml. The al-folio demo data (Albert Einstein) has been
  removed so that nothing fabricated can ever reach the public site. Publishing an
  incomplete or invented CV on a public academic page is a reputational risk, so the page
  stays unlinked until real data arrives.

  To turn it on:
    1. The hub session renders the CV from the academic record into assets/pdf/cv.pdf.
    2. Fill _data/cv.yml from achievements/record.md (same source, no retyping). Leave
       the email out — _data/socials.yml holds the only copy; render it from there.
    3. Set cv_pdf: /assets/pdf/cv.pdf, nav: true, drop sitemap: false above, and
       uncomment cv_pdf in _data/socials.yml for the download button.
{% endcomment %}
