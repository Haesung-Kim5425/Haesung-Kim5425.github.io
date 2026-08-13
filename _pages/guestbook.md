---
layout: page
permalink: /guestbook/
title: Guestbook
description: Leave a note — a question about a paper, a possible collaboration, or just hello.

# ── NOT LIVE YET ────────────────────────────────────────────────────────────
# Three values in _config.yml (giscus.repo_id, giscus.category, giscus.category_id)
# have to be filled in before this page can be published. Until then:
#
#   giscus_comments: false   keeps the comment box off. With it true and the config
#                            incomplete, the page renders a red "giscus comments
#                            misconfigured" warning to every visitor — bin/check-public.ps1
#                            refuses to pass a build containing that box, so this cannot
#                            go out by accident.
#   nav: false               keeps it out of the menu
#   sitemap: false           keeps a half-finished page out of search results
#
# To go live, flip all three and re-run bin/check-public.ps1. Nothing else here changes.
# ────────────────────────────────────────────────────────────────────────────
giscus_comments: false
nav: false
nav_order: 6
sitemap: false
---

{% comment %}
  How this works, since a guestbook on a static site is not obvious:

  GitHub Pages serves files. There is no server here and no database, so nothing on this
  site can accept a visitor's writing. giscus borrows the repository's GitHub Discussions
  as the store — the comment box is an iframe, entries live in Discussions, and the owner
  moderates them there.

  Consequences worth keeping in mind rather than discovering later:

  * Visitors need a GitHub account. That excludes most non-technical readers, and it is
    also what keeps the spam out. Both halves of that trade are real.
  * Entries are public and attached to the writer's GitHub identity.
  * Nothing is pre-moderated. A post is visible the moment it is made, and stays until
    it is deleted or hidden in the repository's Discussions tab.

  Only this page carries `giscus_comments`. The flag is per-page in al_comments, so the
  publications, research, CV, contact and news pages are unaffected — that is deliberate:
  a comment box under a publication list invites a different and less useful conversation.
{% endcomment %}

Questions about a paper, ideas for collaboration, or a note in passing — all welcome here.

{% if page.giscus_comments %}
Signing in with a GitHub account is required to post, and entries are public.
For anything private, email is on the [contact]({{ '/contact/' | relative_url }}) page.
{% else %}

<p style="color: var(--global-text-color-light);">
  The guestbook is not open yet. In the meantime, email is on the
  <a href="{{ '/contact/' | relative_url }}">contact</a> page.
</p>

{% endif %}
