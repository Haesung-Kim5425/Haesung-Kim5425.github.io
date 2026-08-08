---
layout: page
permalink: /cv/
title: CV
nav: true
nav_order: 3
description: Curriculum vitae — awards, funding, patents, teaching and conference presentations.
---

{% comment %}
  ★ Nothing on this page is typed by hand.

  Every section below renders from _data/record.yml, copied by bin/sync-sot.ps1 from the
  machine-readable record. That is the whole point: al-folio's own CV layout assembles a
  CV from _data/cv.yml, which would put a second copy of the education, appointments,
  grants and teaching history in this repository next to the real one. Two copies of a CV
  drift, and the public one is always the copy nobody remembered to update.

  So: to change anything here, change achievements/record.yml and re-sync. Do not add a
  fact to this page directly — it would be invisible to the CV PDF and the biosketch,
  which read the same record.

  Two things this page must keep doing:

  1. The patent's English title is a TRANSLATION. The Korean gazette carries no English
     name, so presenting one unqualified would invent an official title. The Korean title
     is shown alongside and the translation is labelled.
  2. Presentation type (oral/poster) is shown only where the record has it — one entry of
     nine. Everywhere else the record does not say, and "not recorded" must not be
     rendered as though it were "attended without presenting".

  The PDF is the same record rendered by the hub session, so the two cannot disagree.
{% endcomment %}

{% assign r = site.data.record %}

<p style="margin: 1.2rem 0 2rem;">
  <a
    href="{{ '/assets/pdf/Haesung_Kim_CV.pdf' | relative_url }}"
    target="_blank"
    rel="noopener"
    style="display:inline-block;padding:0.55rem 1.1rem;border:1px solid var(--global-theme-color);border-radius:0.3rem;color:var(--global-theme-color);text-decoration:none;font-weight:600;line-height:1.4;"
    >Download full CV (PDF)</a
  >
</p>

The full CV also covers education, appointments and the complete publication list. The
publications are on the [publications]({{ '/publications/' | relative_url }}) page.

## Awards and honours

<ul>
{% for a in r.awards %}
  <li>
    <strong>{{ a.name }}</strong>{% if a.detail %} <span style="color: var(--global-text-color-light);">({{ a.detail }})</span>{% endif %}<br />
    {{ a.org }} · {{ a.year }}
  </li>
{% endfor %}
</ul>

## Research grants and projects

<ul>
{% for g in r.grants %}
  <li>
    {{ g.title }}<br />
    <span style="color: var(--global-text-color-light);">
      {{ g.funder }} · <strong>{{ g.role }}</strong> · {{ g.start }}{% if g.end %} – {{ g.end }}{% endif %}
    </span>
  </li>
{% endfor %}
</ul>

## Patents

<ul>
{% for p in r.patents %}
  <li>
    <strong>{{ p.title_en }}</strong>
    {%- if p.title_en_is_translation %}
      <span style="color: var(--global-text-color-light);">(translated title)</span>
    {%- endif %}<br />
    {% if p.title_ko %}<span lang="ko">{{ p.title_ko }}</span><br />{% endif %}
    <span style="color: var(--global-text-color-light);">
      {{ p.office }}, patent no. {{ p.number }} · {{ p.status }} {{ p.registered_on }}
      {%- if p.assignee %} · assignee: {{ p.assignee }}{% endif %}
    </span>
    {%- if p.related_doi %}
      <br /><span style="color: var(--global-text-color-light);">
        Covers the technique in
        <a href="https://doi.org/{{ p.related_doi }}">doi.org/{{ p.related_doi }}</a>
      </span>
    {%- endif %}
  </li>
{% endfor %}
</ul>

## Teaching

<ul>
{% for t in r.teaching %}
  <li>
    <strong>{{ t.role }}</strong> — {{ t.course }}<br />
    <span style="color: var(--global-text-color-light);">
      {{ t.institution }} · {{ t.year }}{% if t.detail %} · {{ t.detail }}{% endif %}
    </span>
  </li>
{% endfor %}
</ul>

## Conference presentations

{% assign intl = r.conferences | where: "scope", "international" %}
{% assign dom = r.conferences | where: "scope", "domestic" %}

**International**

<ul>
{% for c in intl %}
  <li>
    {{ c.name }}{% if c.short %} ({{ c.short }}){% endif %}<br />
    <span style="color: var(--global-text-color-light);">
      {{ c.location }} · {{ c.year }}{% if c.presentation %} · {{ c.presentation }} presentation{% endif %}
    </span>
  </li>
{% endfor %}
</ul>

**Domestic**

<ul>
{% for c in dom %}
  <li>
    {{ c.name }}{% if c.short %} ({{ c.short }}){% endif %}
    <span style="color: var(--global-text-color-light);">
      · {{ c.year }}{% if c.presentation %} · {{ c.presentation }} presentation{% endif %}
    </span>
  </li>
{% endfor %}
</ul>

<p style="font-size: 0.85em; color: var(--global-text-color-light); margin-top: 1.5rem;">
  Conference papers with a DOI are listed on the
  <a href="{{ '/publications/' | relative_url }}">publications</a> page; the list above is
  attendance and presentation history, which is a separate record.
</p>
