---
layout: page
permalink: /contact/
title: contact
description:
nav: true
nav_order: 4
---

The best way to reach me is by email.

**Email** — {% al_email_protect_link site.data.socials.email %}

{% comment %}
  The tag above comes from the al_email_protect plugin (protect_email: true in
  _config.yml). It emits no user@host string and no mailto: target into the HTML — the
  halves are rejoined by the browser on click. Do not replace it with a plain
  <a href="mailto:..."> link; that hands the address straight to harvesters.

  It also reads the address from _data/socials.yml, which is the only copy of it in the
  site, so there is exactly one line to change when the address changes.
{% endcomment %}

**Affiliation** — Purdue University, West Lafayette, IN, USA

**ORCID** — [0000-0002-3392-9444](https://orcid.org/0000-0002-3392-9444)

I am happy to hear from colleagues about collaborations, from students with questions
about the measurement techniques in my papers, and from anyone who wants a copy of a
paper they cannot access.

{% comment %}
  ★ PUBLIC PAGE — work contact only. Never add: home address, personal mobile number,
  office phone, or a street address. The owner settled the scope on 2026-08-08: work
  email, institution and city, and nothing beyond that.
{% endcomment %}
