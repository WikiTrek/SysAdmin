# WikiTrek — Infrastructure

This document describes the technical infrastructure behind the WikiTrek ecosystem.
It is intended for contributors, developers, and anyone curious about how the
project is built and hosted.

---

## The WikiTrek Ecosystem

WikiTrek is an Italian Star Trek wiki ecosystem consisting of several interconnected
sites, all hosted on a single server.

| Site | URL | Description |
|---|---|---|
| WikiTrek | [wikitrek.org](https://wikitrek.org) | Main Italian Star Trek wiki — MediaWiki + SemanticMediaWiki |
| DataTrek | [data.wikitrek.org](https://data.wikitrek.org) | Structured data repository — MediaWiki + Wikibase |
| SPARQL endpoint | [query.wikitrek.org](https://query.wikitrek.org) | Interactive SPARQL query interface for DataTrek |
| QuickStatements | [qs.wikitrek.org](https://qs.wikitrek.org) | Batch data editing tool for DataTrek |
| Trek Blog | [blog.wikitrek.org](https://blog.wikitrek.org) | News and articles — WordPress |
| Personal site | [lucamauri.net](https://lucamauri.net) | Maintainer's personal site |

WikiTrek and DataTrek are closely linked: DataTrek acts as a Wikibase repository
and WikiTrek as its client, allowing structured data from DataTrek to be embedded
and queried on WikiTrek pages via SemanticMediaWiki.

---

## Technology Stack

### Wiki layer

| Component | Technology |
|---|---|
| Wiki engine | [MediaWiki](https://www.mediawiki.org) 1.43 LTS |
| Structured data | [Wikibase](https://wikiba.se) (same technology powering Wikidata) |
| Semantic queries | [SemanticMediaWiki](https://www.semantic-mediawiki.org) 6.x |
| Language | PHP 8.5 |
| Database | MariaDB 11.8 |
| Web server | Apache 2.4 (prefork + mod_php) |

### Data services layer

The SPARQL query service and batch editing tools run as Docker containers,
managed via the [`wikibase-data-services`](https://github.com/lucamauri/wikibase-data-services)
repository (GPL v2).

| Service | Technology | Purpose |
|---|---|---|
| SPARQL endpoint | [Blazegraph/WDQS](https://www.mediawiki.org/wiki/Wikidata_Query_Service) | Stores and queries RDF triples from DataTrek |
| Search | [Elasticsearch](https://www.elastic.co) | Full-text search backend |
| WDQS Updater | wmde/wdqs-updater | Keeps Blazegraph in sync with DataTrek edits |
| QuickStatements | [QuickStatements](https://github.com/magnusmanske/quickstatements) | Batch data import and editing |
| Query UI | wdqs-frontend | Web interface for writing and running SPARQL queries |

### Bot protection

All wiki and blog traffic passes through [Anubis](https://github.com/TecharoHQ/anubis),
a lightweight bot challenge middleware. Anubis sits between the public internet and
Apache, filtering automated traffic before it reaches MediaWiki or WordPress.

---

## Repository Overview

The WikiTrek infrastructure is maintained across several public repositories:

### Data services

| Repository | Description |
|---|---|
| [`lucamauri/wikibase-data-services`](https://github.com/lucamauri/wikibase-data-services) | Docker Compose stack for SPARQL, Elasticsearch, QuickStatements (GPL v2) |

### MediaWiki extensions

Six MediaWiki extensions are maintained by the WikiTrek project maintainer:

| Extension | Repository | Status | Description |
|---|---|---|---|
| Wiki2Ban | [`lucamauri/Wiki2Ban`](https://github.com/lucamauri/Wiki2Ban) | Production | Fail2Ban integration for brute-force protection |
| RecentActivity | [`lucamauri/RecentActivity`](https://gitlab.com/lucamauri/RecentActivity) | Production | Parser function for recently edited pages |
| ParagraphLinks | [`lucamauri/ParagraphLinks`](https://github.com/lucamauri/ParagraphLinks) | Production | Deep-link anchors for paragraphs |
| PageToGitHub | [`lucamauri/PageToGitHub`](https://github.com/lucamauri/PageToGitHub) | Production | Syncs wiki pages to a GitHub repository |
| MoreInfo | [`lucamauri/MoreInfo`](https://github.com/lucamauri/MoreInfo) | Early stage | Structured external resource links |
| ActivityWiki | [`lucamauri/ActivityWiki`](https://github.com/lucamauri/ActivityWiki) | Early stage | ActivityPub / Fediverse integration |

All extensions are licensed under **GPL v2**.

---

## Architecture Overview

```
                        ┌─────────────────────────────────────────┐
                        │              unitedwikitrek             │
                        │                                         │
Internet ──HTTPS──►  Apache :443 (TLS termination)                │
                        │                                         │
                        ▼                                         │
                     Anubis (bot filtering)                       │
                        │                                         │
                        ▼                                         │
                   Apache :8080 (internal)                        │
                        │                                         │
               ┌────────┴────────┐                                │
               ▼                 ▼                                │
         MediaWiki (wt)    MediaWiki (dt)                         │
         wikitrek.org    data.wikitrek.org                        │
                                 │                                │
                                 ▼                                │
                         Docker containers                        │
                    (WDQS, Elasticsearch, QS)                     │
                    query.wikitrek.org                            │
                    qs.wikitrek.org                               │
                        └─────────────────────────────────────────┘
```

All sites are hosted on a single Hetzner Cloud VPS running Ubuntu 26.04 LTS,
consolidating what was previously two separate servers.

---

## Notable Extensions in Use

Beyond the six custom extensions above, WikiTrek makes notable use of:

- **[SemanticMediaWiki](https://www.semantic-mediawiki.org)** — powers structured
  property queries and factboxes across all WikiTrek articles
- **[Wikibase](https://wikiba.se)** — DataTrek is a full Wikibase repository,
  meaning it uses the same data model as Wikidata
- **[WikibaseClient](https://www.mediawiki.org/wiki/Extension:WikibaseClient)** —
  WikiTrek is linked to DataTrek as a Wikibase client, allowing sitelinks and
  structured data access
- **[VisualEditor](https://www.mediawiki.org/wiki/Extension:VisualEditor)** —
  WYSIWYG editing for contributors unfamiliar with wikitext
- **[PluggableAuth](https://www.mediawiki.org/wiki/Extension:PluggableAuth) +
  [WSOAuth](https://www.mediawiki.org/wiki/Extension:WSOAuth)** — DataTrek uses
  WikiTrek as its OAuth identity provider, allowing single sign-on between the
  two wikis

---

## Reporting Issues

- **Wiki content issues** — use the wiki's own talk pages or the
  [WikiTrek community portal](https://wikitrek.org/wiki/WikiTrek:Bar)
- **Technical issues with the wiki software** — open an issue in the relevant
  extension repository listed above
- **Infrastructure issues** — contact the maintainer directly

---

## Maintainer

WikiTrek is maintained by **Luca Mauri** ([@lucamauri](https://github.com/lucamauri)).
