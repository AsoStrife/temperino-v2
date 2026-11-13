# Feature: Vista calendario (attività e masturbazioni)

Piano: `docs/plans/2026-11-13-calendar-view.md`. Stile e componenti: `docs/knowledge/design-system.md`.

## Comportamento

Nei tab **Attività** e **Masturbazioni** l'app bar ha un selettore a due icone (`ListLayoutToggle`): **Lista** (la vista storica, vedi `activities.md` e `masturbations.md`) e **Calendario**. La scelta è unica per i due tab e resta dopo il riavvio (`settings.listLayout` in `shared_preferences`).

In vista calendario:

- Calendario verticale in stile app del ciclo: un mese per blocco, **il mese corrente in alto**, scorrendo verso il basso si va nel passato fino a gennaio di `AppConfig.startYear`.
- Fissa sotto la barra dei comandi, la riga dei giorni della settimana **L M M G V S D** (settimana da lunedì).
- **Tablet**: i mesi sono in una griglia di 2 colonne (verticale) o 3 (orizzontale), dal più recente in alto a sinistra; ogni mese ha la propria riga dei giorni e 6 righe di settimane, e la riga fissa sotto la barra non c'è. Dettagli in `tablet-layout.md`.
- Ogni mese: titolo "Novembre 2026" con il numero di record del mese a destra, poi la griglia dei giorni in una tile.
- Oggi: numero in grassetto su cerchio tonale rosso. Giorni futuri: numero attenuato.
- Giorni con record: numero in grassetto e **cuore** sotto il numero; la cella è tappabile (feedback aptico).
- **Tocco su un giorno**: con un solo record si apre il form in modifica; con più record si apre un foglio dal basso con la data estesa, il numero di record e una riga per record (la stessa riga della lista). Il tocco su una riga chiude il foglio e apre il form.
- In alto a destra: pulsante **"Vai a oggi"** (torna al mese corrente e riporta la pillola anno all'anno corrente), selettore Lista/Calendario, pillola anno.
- **Pillola anno**: in vista calendario non filtra ma **porta il calendario a quell'anno** (al mese corrente per l'anno in corso, a dicembre per gli anni passati). All'apertura del calendario si parte dall'anno selezionato.
- Pull-to-refresh: ricarica tutti gli anni.
- Caricamento: il calendario compare quando tutti gli anni sono caricati; errore di un anno → stato di errore con "Riprova".
- Nessun record: messaggio "Non sono presenti …" con pulsante "Aggiungi …" sopra il calendario vuoto.

### Cuori

| Tab | Cuore |
| --- | --- |
| Attività | Rosso (`accent`) per ogni giorno con almeno un'attività. |
| Masturbazioni | **Rosso** (`genderFemale`) se quel giorno si è masturbata solo una donna, **blu** (`genderMale`) se solo un uomo, **bicolore** (metà sinistra partner 1, metà destra partner 2, ciascuna nel colore del proprio sesso) se si sono masturbati entrambi i partner. |

Il colore segue il **sesso nel profilo locale**, non lo slot: se nel profilo si cambia il sesso di un partner, i cuori si ricolorano subito. Con due partner dello stesso sesso il cuore bicolore ha due metà uguali (TalkBack dice comunque i due nomi). Sopra il calendario delle masturbazioni c'è una legenda: un cuore per partner con il nome e il cuore "Entrambi".

### Accessibilità

- Ogni cella è un nodo unico: "Giovedì 12 novembre 2026, oggi, 2 attività, 1 scopata" / "…, 1 masturbazione: Andrea". Le celle con record sono pulsanti.
- La riga L M M G V S D e i cuori sono decorativi (esclusi dalla semantica); il titolo del mese è un'intestazione.
- Celle di almeno 48 × 48 dp: margine laterale del calendario 12 dp invece di 16 (su 360 dp la cella è esattamente 48 dp); l'altezza delle righe cresce con il testo ingrandito.
- Lo scorrimento animato verso un mese rispetta "riduci movimento" (`context.motion`: salto senza animazione).

## Dati e stato

- `listLayoutProvider` (`lib/features/settings/data/layout_preference.dart`): `ListLayout.list | calendar`.
- `activityDaysProvider` / `masturbationDaysProvider` (`lib/features/calendar/presentation/calendar_providers.dart`): provider derivati che osservano `activitiesProvider(y)` / `masturbationsProvider(y)` per **ogni** anno di `selectableYears()` e raggruppano per giorno. Le masturbazioni includono il cuore del giorno (`MasturbationHeart`), calcolato con il profilo. Dopo `add`/`edit`/`remove` i notifier ricaricano/invalidano gli anni toccati e il calendario si aggiorna da solo.
- Logica pura in `lib/features/calendar/domain/day_events.dart`: `CalendarDays.groupByDay`, `monthsDescending`, `focusMonthOf`, `daysInMonth`, `leadingBlanks`, `weekRows`; `MasturbationHeart.of`. Non modificano gli input (B4).
- **Form da calendario**: le route di modifica accettano `?year=AAAA` (`Routes.activity(id, year: …)`, `Routes.masturbation(id, year: …)`). Il form cerca il record nella lista di quell'anno e salva/cancella tramite il notifier dell'anno del record, non dell'anno selezionato. Senza `year` si usa l'anno selezionato (comportamento della lista).

## Scorrimento a un mese

`SliverEventCalendar` usa `SliverVariedExtentList`: l'altezza di ogni mese è calcolata in anticipo (`_Metrics`: titolo + righe × altezza riga, in funzione di larghezza e scala del testo). Così `showMonth` calcola l'offset esatto anche per mesi mai costruiti: `precedingScrollExtent` della sliver + somma delle altezze dei mesi precedenti − altezza della barra fissa di `AppPage` (status bar + `AppPage.barHeight`: toolbar 56 + riga dei giorni 36).

In griglia (tablet) ogni elemento della lista è una **riga di mesi** con altezza fissa (6 settimane + riga dei giorni), l'indice è `mese ~/ colonne` e la barra fissa non include la riga dei giorni. Le colonne sono calcolate con `SliverEventCalendar.columnsFor(larghezza)` sia dalla sliver sia dalla schermata (che decide se mostrare `CalendarWeekdayHeader`), sulla stessa larghezza.

## File

- `lib/features/calendar/domain/day_events.dart`
- `lib/features/calendar/presentation/calendar_providers.dart`
- `lib/features/settings/data/layout_preference.dart`
- `lib/shared/widgets/event_calendar.dart` (`SliverEventCalendar`, `CalendarDay`, `CalendarWeekdayHeader`)
- `lib/shared/widgets/heart_mark.dart`, `day_events_sheet.dart`, `layout_toggle.dart`
- `lib/features/activities/presentation/activities_list_screen.dart`, `lib/features/masturbations/presentation/masturbations_list_screen.dart` (ramo calendario)
- `lib/features/activities/presentation/activity_form_screen.dart`, `lib/features/masturbations/presentation/masturbation_form_screen.dart` (parametro `year`)
- `lib/app/router.dart` (query `year`), `lib/app/theme.dart` (token `genderFemale`, `genderMale`), `lib/core/config/app_config.dart` (`prefListLayout`), `lib/core/utils/formatters.dart` (`dateLong`, `weekdayNarrow`)

## Casi limite

- Giorno con più record dello stesso partner: cuore pieno, foglio con tutte le righe.
- Record di un anno diverso da quello selezionato: si apre comunque (parametro `year`).
- Modifica della data che sposta il record in un altro anno: il notifier invalida l'anno di destinazione; il calendario mostra il cuore nel nuovo giorno.
- Testo di sistema al 200%: righe più alte, numero e cuore non si sovrappongono; la riga L M M G V S D limita la scala a 1,6.

## Verifica manuale

Vedi il log del piano per lo stato aggiornato.

1. Cambio Lista ↔ Calendario su entrambi i tab, riavvio: la vista resta.
2. Cuori nei giorni giusti; tap su giorno con 1 record → form; con 2+ → foglio → form.
3. Masturbazioni: rosso / blu / bicolore secondo il profilo; cambio sesso nel profilo → colori aggiornati.
4. Pillola anno → il calendario scorre all'anno; "Vai a oggi" → torna in alto.
5. Tema chiaro e scuro, testo grande, TalkBack.
