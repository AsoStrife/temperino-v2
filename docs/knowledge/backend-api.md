# Backend Strapi: contratto API

Il backend è lo stesso Strapi v4 della vecchia app. Non va modificato. Tutti i valori (URL, path, token, nomi dei parametri) sono in `lib/core/config/app_config.dart`.

## Base

- Base URL: `AppConfig.baseUrl` (`https://strapi.andreacorriga.com/api/`).
- Header: `Authorization: Bearer <AppConfig.apiToken>`, aggiunto dall'interceptor di `ApiClient`. Il token è versionato per scelta del proprietario.
- Timeout: `AppConfig.requestTimeout` (20 s) per connessione, invio e ricezione.

## Endpoint usati

| Operazione | Metodo e path | Body |
| --- | --- | --- |
| Lista attività dell'anno | GET `sexual-activities` | — |
| Crea attività | POST `sexual-activities` | `{ "data": { ... } }` |
| Modifica attività | PUT `sexual-activities/{id}` | `{ "data": { ... } }` |
| Cancella attività | DELETE `sexual-activities/{id}` | — |
| Lista masturbazioni dell'anno | GET `masturbations` | — |
| Crea masturbazione | POST `masturbations` | `{ "data": { ... } }` |
| Modifica masturbazione | PUT `masturbations/{id}` | `{ "data": { ... } }` |
| Cancella masturbazione | DELETE `masturbations/{id}` | — |

Query di lista per l'anno `Y` (`yearQuery` in `lib/core/network/strapi_pagination.dart`):

```
filters[date][$gte]=Y-01-01
filters[date][$lte]=Y-12-31
sort=date:desc
pagination[page]=N
pagination[pageSize]=100
```

## Schema dei record

`sexual-activities` → `attributes`:

| Campo | Tipo | Note |
| --- | --- | --- |
| `date` | `AAAA-MM-GG` | Letto come `DateOnly` (B11). |
| `sex`, `blowjob`, `handjob`, `anal`, `fingering`, `lick`, `tits_fuck` | bool | Accetta anche 0/1/null in lettura. L'app invia solo true/false. |
| `cumshot` | stringa | Uno dei 12 valori di `AppConfig.cumshotLabels`. Vuoto/sconosciuto → `none`. |
| `orgasm_a`, `orgasm_b` | int | null → 0 (B13). |
| `createdAt`, `updatedAt` | ISO | Ignorati. |

`masturbations` → `attributes`:

| Campo | Tipo | Note |
| --- | --- | --- |
| `date` | `AAAA-MM-GG` | |
| `who` | `A` / `B` | A = partner 1, B = partner 2. |
| `toys` | bool | Inviato sempre come booleano (B12). |
| `n_orgasms` | int | null → 0. |

Il parser (`JsonReaders.attributes`) accetta sia la forma v4 `{id, attributes: {...}}` sia quella piatta v5, per robustezza.

## Comportamento reale verificato (12 novembre 2026)

Verificato con GET in sola lettura sull'anno 2025:

- **I filtri per data funzionano**: tornano solo record dell'anno richiesto.
- **`sort=date:desc` viene ignorato**: i record arrivano in ordine crescente di data.
- **`pagination[pageSize]` viene ignorato**: con `pageSize=5` la risposta è `{"page":1,"pageSize":128,"pageCount":1,"total":128}`, cioè tutti i record in una pagina.

Conseguenze nel client (già implementate):

- I repository ordinano sempre in locale per data decrescente, **su una nuova lista** (B4). Questo chiude il punto aperto "Sort di Strapi (B10)" della specifica: si invia comunque `sort` (sintassi v4 corretta) ma non ci si affida.
- `fetchAllPages` continua a leggere `meta.pagination.pageCount` e si ferma a `page >= pageCount`: funziona sia se il backend pagina sia se restituisce tutto.

Volumi indicativi: 2025 → 128 attività, 85 masturbazioni.
