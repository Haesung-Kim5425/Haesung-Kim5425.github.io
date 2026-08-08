---
layout: page
permalink: /contact/
title: Contact
description:
nav: true
nav_order: 4
---

Email is the best way to get in touch.

**Email** — {% al_email_protect_link site.data.profile.contact.email %}

{% comment %}
  The tag above is from the al_email_protect plugin. It is safe to call whether or not
  protection is enabled: with `protect_email: false` (the current setting) it renders an
  ordinary mailto: link, and with it on it renders a click-to-copy element instead.

  Protection is off deliberately — see the note at `protect_email` in _config.yml. The
  short version: it displayed the address as "kim5425 [at] purdue [dot] edu" while the
  same address still went out in plain text via the footer mail icon and inside the CV
  PDF, so it cost the reader something and protected nothing.

  Keep using the tag rather than hand-writing the address: it reads from the profile, so
  there is exactly one place to change when the address changes.
{% endcomment %}

**Affiliation** — {{ site.data.profile.position.display }}

**ORCID** — [{{ site.data.profile.ids.orcid }}]({{ site.data.profile.ids.orcid_url }})

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
