# Bug della vecchia app da non replicare (B1–B14)

Ogni voce è un requisito. La colonna "Dove" indica il codice che lo garantisce: se tocchi quei file, verifica che il requisito resti valido.

| # | Bug nella vecchia app | Soluzione nella nuova app | Dove |
| --- | --- | --- | --- |
| B1 | Rapporto D/A con divisione per zero (`Infinity`/`NaN`). | `StatsCalculator.ratio` restituisce `null` se il denominatore è 0; `Formatters.ratio` mostra "—". Il grafico mensile non disegna i mesi `null`. | `stats_calculator.dart`, `formatters.dart`, `ratio_chart.dart` |
| B2 | Grafico sborrate con 8 zone su 12. | `cumshotCounts` conta tutte le 12 zone di `CumshotZone`, compresa `none`; il grafico le mostra tutte, ordinate. | `stats_calculator.dart`, `stats_screen.dart` |
| B3 | (rimosso nella v3 della specifica) etichetta "Ditalini/Seghe" dipende dal sesso. | `Gender.masturbationLabel`. | `partner_profile.dart` |
| B4 | `reverse()` modificava l'array dello store. | Le liste sono ordinate su una copia e restituite come `List.unmodifiable`; `StatsCalculator` non muta gli input. | repository, `stats_calculator.dart` |
| B5 | Il cambio anno non ricaricava i dati. | Tutti i provider dati sono `family` sull'anno e le schermate guardano `yearProvider`. | `year_preference.dart`, schermate |
| B6 | Anno selezionato non salvato. | `YearNotifier` legge/scrive `settings.year` in `shared_preferences`, con clamp fra `startYear` e anno corrente. | `year_preference.dart` |
| B7 | Spinner di cancellazione bloccato (typo). | Un solo stato `FormBusy` per form, resettato in `finally`. | form attività e masturbazione, `form_widgets.dart` |
| B8 | Errore di salvataggio masturbazione mai mostrato. | Ogni errore di salvataggio/cancellazione mostra uno SnackBar con il messaggio di `AppException`. | `showErrorSnack` in `form_widgets.dart` |
| B9 | (rimosso nella v3) paginazione. | Il client scarica comunque tutte le pagine. | `strapi_pagination.dart` |
| B10 | `orderBy` non è sintassi Strapi v4. | Si invia `sort=date:desc`. Il backend lo ignora (vedi `backend-api.md`), quindi si ordina anche in locale. | `app_config.dart`, repository |
| B11 | `new Date('AAAA-MM-GG')` in UTC fa slittare il giorno. | Tipo `DateOnly` senza ora né fuso. | `date_only.dart`, DTO |
| B12 | `toys` inviato come 0. | `toys` è `bool`, default `false`, serializzato come booleano. | `masturbation.dart`, `masturbation_dto.dart` |
| B13 | Totali che sommavano `null`. | `JsonReaders.readInt(null) == 0`. | `json_readers.dart` |
| B14 | Nomi delle pratiche diversi fra form e statistiche. | Un solo nome per pratica in `AppConfig.practiceLabels`, usato da `Practice.label` in form, lista e statistiche. | `app_config.dart`, `sexual_activity.dart` |

## Regressioni dell'app nuova

| Bug | Causa | Soluzione | Dove |
| --- | --- | --- | --- |
| Le pagine dei tab scorrevano fino sotto la barra flottante: ultimo elemento coperto e non cliccabile (introdotto con il layout tablet). | `MediaQuery.removePadding(context: context, …)` in `ShellScaffold.build` usava il `context` sopra lo `Scaffold` e sovrascriveva il `MediaQuery` del body, che porta l'altezza della barra (`extendBody`). `AppPage` riceveva solo l'inset di sistema. | `Builder` attorno a `removePadding`, così legge il `MediaQuery` interno al body. | `shell_scaffold.dart` |
