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
anything.

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
| `bin/sync-sot.ps1` | The one-way bibliography sync described above |

## Licence

Theme: al-folio, MIT (see `LICENSE`). Site content: © Haesung Kim.
