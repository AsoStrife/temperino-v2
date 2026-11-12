# Feature: Configurazione, rete ed errori

## Configurazione statica

`lib/core/config/app_config.dart` (`abstract final class AppConfig`) è l'unico file con:

- nome, versione, package dell'app;
- `baseUrl`, `apiToken`, `requestTimeout`;
- path degli endpoint, nomi dei parametri di paginazione/filtro/sort (raw string per `$`);
- `pageSize`, `maxParallelRequests`, `startYear`;
- valori API dei partner, avatar, immagini;
- etichette di dominio (zone, pratiche, sesso, conteggi masturbazione);
- chiavi di `shared_preferences`.

Non usa variabili d'ambiente né `--dart-define`: per cambiare ambiente si modifica il file.

## Client HTTP

- `ApiClient` (`lib/core/network/api_client.dart`): dio con `baseUrl`, timeout, JSON, interceptor `Authorization: Bearer <token>`. Metodi `get/post/put/delete` che restituiscono la mappa JSON e convertono ogni errore in `AppException`.
- `fetchAllPages` (`strapi_pagination.dart`): scarica tutte le pagine finché `page < pageCount`.
- `yearQuery(year)`: filtri `date` fra 1/1 e 31/12 e `sort=date:desc`.
- `mapWithConcurrency` (`lib/core/utils/concurrency.dart`): esegue task con limite di parallelismo, risultati nell'ordine di input.

## Errori

`AppException` (sealed) con messaggio italiano pronto per la UI:

| Tipo | Quando |
| --- | --- |
| `NetworkException` | nessuna connessione, errore di socket, certificato non valido |
| `RequestTimeoutException` | timeout di connessione/invio/ricezione |
| `ServerException(statusCode)` | risposta 4xx/5xx |
| `InvalidResponseException` | JSON inatteso, data non valida |
| `UnknownException` | altro |

## Utilità

- `DateOnly`: data senza ora né fuso, `parse('AAAA-MM-GG')`, `toJson()`, confronto (B11).
- `Formatters`: `dd-MM-yyyy`, nomi di mesi/giorni in italiano, rapporto con "—" (B1).
- `JsonReaders`: `readInt` (null → 0), `readBool` (true/false/0/1), `attributes` (v4 e v5).

## Verifica manuale

1. Con rete: le liste si caricano.
2. Senza rete: messaggio "Impossibile contattare il server…" e "Riprova".
3. Token errato (modifica locale temporanea): "Errore del server (401)" / "(403)".
