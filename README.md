# kim5425.github.io

Academic homepage of Haesung Kim, built with [Jekyll](https://jekyllrb.com/) and the
[al-folio](https://github.com/alshedivat/al-folio) theme, served by GitHub Pages.

## Publications are not edited here

The publication list is **not** maintained in this repository. The single source of truth
is a BibTeX file kept with the rest of the academic record, outside this repo. It is
copied in — one way — by:

```
pwsh -File bin/sync-sot.ps1
```

That script writes `_bibliography/papers.bib`, which jekyll-scholar renders on the
[publications](https://kim5425.github.io/publications/) page. `_bibliography/papers.bib`
carries a "GENERATED FILE" header: any edit made to it directly is destroyed on the next
sync. To change what the site shows, change the source and re-run the script.

Run `bin/sync-sot.ps1 -Check` to see whether the committed copy is stale without writing
anything (exit 2 means stale).

A `pre-commit` hook enforces this, because nothing downstream can: the GitHub Actions
build only checks out this repository and never sees the source, so a stale copy would
publish silently. Git does not track hooks, so run this once per clone:

```
pwsh -File bin/install-hooks.ps1
```

## Local preview

Requires Ruby 3.x with the DevKit.

```
bundle install
bundle exec jekyll serve --livereload
```

The site is then at <http://127.0.0.1:4000>.

## Deployment

Pushing to `main` triggers `.github/workflows/deploy.yml`, which builds the site and
publishes it to the `gh-pages` branch. Everything under `_site/` is generated; nothing
there is committed.

## Layout

| Path | What it is |
| --- | --- |
| `_pages/about.md` | Front page: bio, profile block, links |
| `_pages/publications.md` | Renders the bibliography; contains no list of its own |
| `_pages/research.md` | Research themes |
| `_pages/contact.md` | Work contact details |
| `_pages/cv.md` | CV page — currently hidden from the nav, pending real data |
| `_pages/news.md` | News page — currently hidden from the nav, `_news/` is empty |
| `_data/socials.yml` | Profile links (email, ORCID, GitHub) |
| `_data/cv.yml` | CV data for the CV page |
| `_includes/hook/bib.liquid` | Renders the preprint / co-first-author badges on each reference |
| `bin/sync-sot.ps1` | The one-way bibliography sync described above |
| `bin/serve.ps1` | Sync + local preview in one command |
| `bin/install-hooks.ps1` | Installs the pre-commit freshness check |

## Two things not to get wrong

**Citation metrics.** Any figure on the publications page must carry the date it was
retrieved and must come from the maintained metrics record, never from memory. An
undated citation count on a public page is a claim nobody can check. Do not add a
publication count from Google Scholar — it merges duplicates and same-name authors; the
list on the page is the count.

**Author name matching.** `scholar.first_name` in `_config.yml` lists both `Haesung` and
`Hae Sung`, because one published record uses the spaced spelling. Match on the full
given name only: most papers here have three or four coauthors surnamed Kim, so a
surname-only rule would bold all of them.

## Licence

Theme: al-folio, MIT (see `LICENSE`). Site content: © Haesung Kim.
