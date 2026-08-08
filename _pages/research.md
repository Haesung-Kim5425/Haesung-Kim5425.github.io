---
layout: page
permalink: /research/
title: Research
description: Four device families, one recurring problem — telling overlapping mechanisms apart.
nav: true
nav_order: 2
---

{% comment %}
  ★ SOURCING RULE FOR THIS PAGE

  NO PRONOUNS anywhere on this site — the owner chose to be referred to by name or with
  subjectless constructions (confirmed 2026-08-08). Write "the work", not "my work" or
  "their work". NO publication count in prose either; it goes stale on the next paper.

  The four tracks below are the four research tracks recorded in the academic record the
  hub session maintains (achievements/record.md), taken from the owner's CV. The
  supporting detail in each is drawn from the verified bibliography — every technique
  named here corresponds to a published, DOI-checked paper on the publications page.

  Nothing unpublished, in preparation, or under review appears here, and no funded
  project is described as an outcome. If a claim cannot be traced to the record or to a
  paper in the bibliography, it does not belong on this page.
{% endcomment %}

{{ site.data.profile.research_focus }} The recurring problem
across all of it: an ordinary I–V or C–V sweep returns a single lumped number where
several physical mechanisms overlap. Until those mechanisms can be separated, a device's
behaviour gets attributed to a fitting parameter rather than to a trap population, a
resistance, or an interface.

Four device families run through it.

## Ferroelectric FETs

Modelling and characterization of transient behaviour and electrical-stress instability.

Ferroelectric HfZrO<sub>2</sub> transistors are attractive as non-volatile memory, but
what limits them as a *memory cell* is often not the ferroelectric — it is the
interfacial layer between it and the channel. The published work quantifies that:
read-after-write latency and the charge-trapping dynamics that set it, the role the
interfacial layer plays in memory-cell failure, the interaction between channel carriers
and remote traps across the HfZrO<sub>2</sub>/SiO<sub>2</sub> interface, and how trapping
evolves with endurance cycling and temperature.

A related collaboration takes the same material in a different direction: a programmable
ferroelectric rectifier used as the element of a neuromorphic crossbar array.

## Ferroelectric TFTs

Characterization of fabrication conditions, particularly thermal process sequence.

Here the questions are structural. How device structure shapes ferroelectric switching
characteristics; how source/drain resistance together with subgap density of states sets
the switching-speed limit in IGZO/HfZrO<sub>x</sub> ferroelectric TFTs; how defects
mediate the memory window in IGZO-channel devices; and how remnant polarization is
distributed spatially in an inverted-staggered stack.

## Amorphous oxide semiconductor (a-IGZO) TFTs

Extraction techniques for sub-bandgap density of states, parasitic resistances and
conduction-band-minimum energy; modelling of opto-electronic characteristics;
characterization of transient properties.

In a-IGZO thin-film transistors the quantities that matter most are the hardest to reach
directly. The methods developed for them include photonic I–V with the photogating effect
and photovoltaic-de-embedded photonic C–V for subgap density of states, extraction of the
conduction-band-minimum energy, simultaneous extraction of mobility enhancement factor and
threshold voltage in the presence of parasitic resistance, low-temperature intrinsic
field-effect mobility separated from contact resistance, low-frequency noise as a probe of
contact-metal effects, and trap dynamics recovered from transient response.

## Silicon MOSFETs, including GAA FETs and NAND flash

Extraction of interface states and parasitic resistance; modelling of opto-electronic
characteristics; equivalent-capacitance modelling; proton-irradiation effects.

The earliest and most general line of work. It covers alternating-current and
current-to-transconductance-ratio techniques for separating parasitic resistances from
intrinsic device behaviour, capacitance-based and deep-depletion C–V methods for mapping
the spatial and energy distribution of traps across the substrate, interface-trap
characterization in silicon nanosheet gate-all-around MOSFETs from subthreshold I–V
characteristics, and the effect of proton irradiation on the SiN<sub>x</sub> and
Si–SiO<sub>2</sub> interfaces of a flash memory cell.

---

The full publication list, with DOIs, is on the [publications](/publications/) page.
