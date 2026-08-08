---
layout: page
permalink: /contact/
title: contact
description:
nav: true
nav_order: 4
---

Email is the best way to get in touch.

**Email** — {% al_email_protect_link site.data.socials.email %}

{% comment %}
  The tag above comes from the al_email_protect plugin (protect_email: true in
  _config.yml). It emits no user@host string and no mailto: target into the HTML — the
  halves are rejoined by the browser on click. Do not replace it with a plain
  <a href="mailto:..."> link; that hands the address straight to harvesters.

  It also reads the address from _data/socials.yml, which is the only copy of it in the
  site, so there is exactly one line to change when the address changes.
{% endcomment %}

**Affiliation** — Birck Nanotechnology Center, Purdue University, West Lafayette, IN, USA

**ORCID** — [0000-0002-3392-9444](https://orcid.org/0000-0002-3392-9444)

Enquiries are welcome — from colleagues about collaborations, from students with
questions about the measurement techniques in these papers, and from anyone who cannot
get access to a paper and would like a copy.

{% comment %}
  ★ PUBLIC PAGE — work contact only. Never add: home address, personal mobile number,
  office phone, or a street address. The owner settled the scope on 2026-08-08: work
  email, institution and city, and nothing beyond that.

  NO PRONOUNS, here as everywhere else on the site (owner's choice, 2026-08-08). That is
  why this page says "Enquiries are welcome" rather than "I am happy to hear from...".
{% endcomment %}
