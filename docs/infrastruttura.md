# WikiTrek — Infrastruttura

Questo documento descrive l'infrastruttura tecnica dell'ecosistema WikiTrek.
È destinato a collaboratori, sviluppatori e a chiunque voglia capire come il
progetto è costruito e ospitato.

---

## L'ecosistema WikiTrek

WikiTrek è un ecosistema di wiki italiani dedicati a Star Trek, composto da
diversi siti interconnessi, tutti ospitati su un unico server.

| Sito | URL | Descrizione |
|---|---|---|
| WikiTrek | [wikitrek.org](https://wikitrek.org) | Wiki italiano principale su Star Trek — MediaWiki + SemanticMediaWiki |
| DataTrek | [data.wikitrek.org](https://data.wikitrek.org) | Repository di dati strutturati — MediaWiki + Wikibase |
| Endpoint SPARQL | [query.wikitrek.org](https://query.wikitrek.org) | Interfaccia interattiva per interrogazioni SPARQL su DataTrek |
| QuickStatements | [qs.wikitrek.org](https://qs.wikitrek.org) | Strumento per l'inserimento batch di dati in DataTrek |
| Trek Blog | [blog.wikitrek.org](https://blog.wikitrek.org) | Notizie e articoli — WordPress |
| Sito personale | [lucamauri.net](https://lucamauri.net) | Sito personale del maintainer |

WikiTrek e DataTrek sono strettamente collegati: DataTrek funge da repository
Wikibase e WikiTrek da suo client, permettendo di incorporare e interrogare i
dati strutturati di DataTrek nelle pagine di WikiTrek tramite SemanticMediaWiki.

---

## Stack tecnologico

### Livello wiki

| Componente | Tecnologia |
|---|---|
| Motore wiki | [MediaWiki](https://www.mediawiki.org) 1.43 LTS |
| Dati strutturati | [Wikibase](https://wikiba.se) (la stessa tecnologia che alimenta Wikidata) |
| Interrogazioni semantiche | [SemanticMediaWiki](https://www.semantic-mediawiki.org) 6.x |
| Linguaggio | PHP 8.5 |
| Database | MariaDB 11.8 |
| Web server | Apache 2.4 (prefork + mod_php) |

### Livello servizi dati

Il servizio di interrogazione SPARQL e gli strumenti di editing batch sono eseguiti
come container Docker, gestiti tramite il repository
[`wikibase-data-services`](https://github.com/lucamauri/wikibase-data-services)
(licenza GPL v2).

| Servizio | Tecnologia | Scopo |
|---|---|---|
| Endpoint SPARQL | [Blazegraph/WDQS](https://www.mediawiki.org/wiki/Wikidata_Query_Service) | Archivia e interroga i triple RDF di DataTrek |
| Ricerca | [Elasticsearch](https://www.elastic.co) | Backend per la ricerca full-text |
| WDQS Updater | wmde/wdqs-updater | Mantiene Blazegraph sincronizzato con le modifiche di DataTrek |
| QuickStatements | [QuickStatements](https://github.com/magnusmanske/quickstatements) | Importazione e modifica batch dei dati |
| Interfaccia query | wdqs-frontend | Interfaccia web per scrivere ed eseguire interrogazioni SPARQL |

### Protezione dai bot

Tutto il traffico verso i wiki e i blog transita attraverso [Anubis](https://github.com/TecharoHQ/anubis),
un middleware leggero per la verifica dei bot. Anubis si interpone tra internet e
Apache, filtrando il traffico automatizzato prima che raggiunga MediaWiki o WordPress.

---

## Panoramica dei repository

L'infrastruttura WikiTrek è mantenuta in diversi repository pubblici:

### Servizi dati

| Repository | Descrizione |
|---|---|
| [`lucamauri/wikibase-data-services`](https://github.com/lucamauri/wikibase-data-services) | Stack Docker Compose per SPARQL, Elasticsearch, QuickStatements (GPL v2) |

### Estensioni MediaWiki

Il maintainer del progetto sviluppa e mantiene sei estensioni MediaWiki:

| Estensione | Repository | Stato | Descrizione |
|---|---|---|---|
| Wiki2Ban | [`lucamauri/Wiki2Ban`](https://github.com/lucamauri/Wiki2Ban) | Produzione | Integrazione con Fail2Ban per la protezione da attacchi brute-force |
| RecentActivity | [`lucamauri/RecentActivity`](https://gitlab.com/lucamauri/RecentActivity) | Produzione | Funzione parser per le pagine modificate di recente |
| ParagraphLinks | [`lucamauri/ParagraphLinks`](https://github.com/lucamauri/ParagraphLinks) | Produzione | Ancore per i collegamenti diretti ai paragrafi |
| PageToGitHub | [`lucamauri/PageToGitHub`](https://github.com/lucamauri/PageToGitHub) | Produzione | Sincronizza le pagine wiki con un repository GitHub |
| MoreInfo | [`lucamauri/MoreInfo`](https://github.com/lucamauri/MoreInfo) | In sviluppo | Riquadro strutturato con link a risorse esterne |
| ActivityWiki | [`lucamauri/ActivityWiki`](https://github.com/lucamauri/ActivityWiki) | In sviluppo | Integrazione con il Fediverso tramite ActivityPub |

Tutte le estensioni sono rilasciate con licenza **GPL v2**.

---

## Panoramica dell'architettura

```
                        ┌─────────────────────────────────────────┐
                        │              unitedwikitrek              │
                        │                                          │
Internet ──HTTPS──►  Apache :443 (terminazione TLS)               │
                        │                                          │
                        ▼                                          │
                     Anubis (filtraggio bot)                       │
                        │                                          │
                        ▼                                          │
                   Apache :8080 (interno)                          │
                        │                                          │
               ┌────────┴────────┐                                 │
               ▼                 ▼                                 │
         MediaWiki (wt)    MediaWiki (dt)                          │
         wikitrek.org    data.wikitrek.org                         │
                                 │                                 │
                                 ▼                                 │
                         Container Docker                          │
                    (WDQS, Elasticsearch, QS)                      │
                    query.wikitrek.org                             │
                    qs.wikitrek.org                                │
                        └─────────────────────────────────────────┘
```

Tutti i siti sono ospitati su un unico VPS Hetzner Cloud con Ubuntu 26.04 LTS,
consolidando quella che era in precedenza un'infrastruttura su due server separati.

---

## Estensioni di rilievo in uso

Oltre alle sei estensioni sviluppate internamente, WikiTrek fa uso rilevante di:

- **[SemanticMediaWiki](https://www.semantic-mediawiki.org)** — gestisce le
  interrogazioni sulle proprietà strutturate e i factbox in tutti gli articoli
  di WikiTrek
- **[Wikibase](https://wikiba.se)** — DataTrek è un repository Wikibase completo,
  basato sullo stesso modello dati di Wikidata
- **[WikibaseClient](https://www.mediawiki.org/wiki/Extension:WikibaseClient)** —
  WikiTrek è collegato a DataTrek come client Wikibase, consentendo sitelink e
  accesso ai dati strutturati
- **[VisualEditor](https://www.mediawiki.org/wiki/Extension:VisualEditor)** —
  editing WYSIWYG per i collaboratori che non conoscono il wikitext
- **[PluggableAuth](https://www.mediawiki.org/wiki/Extension:PluggableAuth) +
  [WSOAuth](https://www.mediawiki.org/wiki/Extension:WSOAuth)** — DataTrek utilizza
  WikiTrek come identity provider OAuth, permettendo il single sign-on tra i
  due wiki

---

## Segnalare problemi

- **Problemi con i contenuti del wiki** — usa le pagine di discussione del wiki o
  il [Bar di WikiTrek](https://wikitrek.org/wiki/WikiTrek:Bar)
- **Problemi tecnici con il software wiki** — apri una segnalazione nel repository
  dell'estensione corrispondente tra quelli elencati sopra
- **Problemi di infrastruttura** — contatta direttamente il maintainer

---

## Maintainer

WikiTrek è mantenuto da **Luca Mauri** ([@lucamauri](https://github.com/lucamauri)).
