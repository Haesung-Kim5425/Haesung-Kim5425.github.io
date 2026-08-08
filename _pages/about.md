---
layout: about
title: about
permalink: /
# Front matter cannot read data files, so the lab name and URL are repeated here from
# profile.yml (position.lab / position.lab_url). If either changes there, change it here
# too — this is the one place on the page that cannot follow automatically.
subtitle: Opto-electronic characterization and physics-based modeling of semiconductor devices · <a href="https://specere.org">Specere Lab</a>, Purdue University

profile:
  align: right
  image: prof_pic.jpg
  image_circular: false # crops the image to make it circular
  more_info: >
    <p><a href="https://specere.org">Specere Lab</a></p>
    <p>Purdue University</p>
    <p>West Lafayette, IN, USA</p>
  # Same caveat as the subtitle above: front matter is static, so these repeat
  # position.lab / position.lab_url / position.city from profile.yml by hand.

selected_papers: true # the five papers flagged selected={true} in the bibliography source
# of truth. Which papers appear is decided there, not here — this page must never carry
# a hand-curated list of its own, or the two will drift apart.
social: true # includes social icons at the bottom of the page

announcements:
  enabled: true # items come from _news/
  scrollable: true # adds a vertical scroll bar if there are more than 3 news items
  limit: 5 # leave blank to include all the news in the `_news` folder

latest_posts:
  enabled: false # this site has no blog
  scrollable: true
  limit: 3
---

{% comment %}
  The biography is rendered from the machine-readable profile in the academic record
  (achievements/profile.yml, copied here by bin/sync-sot.ps1), not written out below.

  It is APPROVED TEXT — built only from facts stated in the owner's CV and signed off by
  the owner on 2026-08-08. Do not paste it into this file to "just tweak the wording":
  copy-edits, tightening and paraphrase are all off limits, and a copy here would drift
  from the CV and biosketch that render the same paragraph. Changes go through the hub.

  Two house rules travel with it — see `style` in the profile — and apply to every other
  rendering too, including page descriptions, og:description and image alt text:

    1. NO PRONOUNS (style.pronouns: none). The owner chose to be referred to by name or
       with subjectless constructions. Do not introduce he/she/they anywhere.
    2. NO PUBLICATION COUNT in prose (style.publication_counts_in_prose: false). A number
       written into a sentence goes stale the next time something is published. The
       publications page is the count.

  (Liquid comment, not an HTML one: Jekyll strips this at build time. An HTML comment
  would be served to every visitor who opens the page source.)
{% endcomment %}

{{ site.data.profile.bio.long }}

The full list of papers is on the [publications](/publications/) page; the research
themes are described in more detail under [research](/research/).
