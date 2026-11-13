# Piano: vista calendario per attività e masturbazioni

- **Stato:** ✅ Completato
- **Inizio:** 2026-11-13
- **Ultimo aggiornamento:** 2026-11-13
- **Feature doc:** `docs/features/calendar-view.md` (nuovo) + aggiornamento di `docs/features/activities.md` e `docs/features/masturbations.md`
- **Avanzamento:** 7/7 step

## Obiettivo

Nei tab **Attività** e **Masturbazioni** l'utente può passare dalla lista attuale a una vista calendario: un calendario verticale che scorre verso il passato (il mese più recente in alto), in cui ogni giorno con almeno un evento mostra un cuore. Toccando un giorno si apre l'evento (o, se sono più di uno, un foglio con l'elenco da cui aprire il singolo record).

Verificabile alla fine:

- Il selettore Lista / Calendario in alto cambia vista su entrambi i tab e la scelta resta dopo il riavvio.
- Ogni giorno con attività mostra un cuore rosso; ogni giorno con masturbazioni mostra un cuore rosso (donna), blu (uomo) o diviso in due colori (entrambi i partner si sono masturbati quel giorno).
- Tocco su un giorno con un solo record → si apre il form in modifica; con più record → foglio con l'elenco.

## Ambito

- In ambito:
  - Selettore a due segmenti (icone lista / calendario) nell'app bar di `ActivitiesListScreen` e `MasturbationsListScreen`, scelta persistita in `shared_preferences`.
  - Calendario condiviso `SliverEventCalendar` (mesi in verticale, settimana da lunedì, oggi evidenziato, giorni con evento marcati dal cuore).
  - Calendario attività: cuore unico nel colore dell'accento.
  - Calendario masturbazioni: cuore rosso/blu/bicolore in base al sesso dei partner dal profilo, con legenda.
  - Foglio di dettaglio per i giorni con più record.
  - Copertura temporale: dal gennaio di `AppConfig.startYear` fino al mese corrente.
  - Aggiornamento automatico dopo add/edit/delete (il calendario osserva i provider per anno).
  - Form apribili per record di qualsiasi anno (query `?year=`).
- Fuori ambito:
  - Modifica o creazione direttamente dal calendario (si usano i form esistenti).
  - Cancellazione con swipe nella vista calendario.
  - Nuovi endpoint, filtri o campi sul backend (vincolo 1 di `AGENTS.md`).
  - Statistiche e Home: invariate.
  - Test automatici (vincolo 4): la verifica è `flutter analyze` + prova manuale.

## Decisioni prese

Confermate dall'utente con "Implementa il piano" (default proposti nel piano):

1. Il calendario copre **tutti gli anni** da `AppConfig.startYear` al corrente. La pillola anno, in vista calendario, **porta il calendario all'anno scelto** (mese corrente per l'anno in corso, dicembre per gli anni passati); all'apertura si parte dall'anno selezionato.
2. Scelta Lista/Calendario **condivisa fra i due tab** (`settings.listLayout`).
3. Settimana da lunedì, iniziali da `intl` (`Formatters.weekdayNarrow`).
4. Colori dei cuori masturbazioni dal **sesso** (`Gender`): `genderFemale` = rosso lampone, `genderMale` = blu nuovo #2563EB / #60A5FA (contrasti calcolati in `design-system.md`).
5. Bicolore: metà sinistra partner A, metà destra partner B, ciascuna nel colore del proprio sesso; stesso sesso → metà uguali.
6. Cuore attività: un solo colore (`accent`).
7. Giorno con più record: `showDayEventsSheet` (`useRootNavigator: true`), una riga per record (la stessa riga della lista).

Decisioni emerse durante il lavoro:

8. Pulsante **"Vai a oggi"** nell'app bar in vista calendario (riporta anche la pillola all'anno corrente).
9. **Form di un altro anno**: le route di modifica accettano `?year=AAAA`; il form cerca il record in quell'anno e salva/cancella con il notifier dell'anno del record. Senza, dal calendario un record del 2024 con anno selezionato 2026 dava "non trovata".
10. Margine laterale del calendario 12 dp (non 16): su 360 dp la cella è 48 dp.
11. Altezze dei mesi calcolate in anticipo (`SliverVariedExtentList`) per poter saltare a un mese mai costruito.

## File coinvolti

Nuovi:

- `docs/plans/2026-11-13-calendar-view.md` – questo piano
- `docs/features/calendar-view.md` – feature doc
- `lib/features/calendar/domain/day_events.dart` – `CalendarDays`, `MasturbationHeart`, `CalendarMonth`, `MasturbationDay`
- `lib/features/calendar/presentation/calendar_providers.dart` – `activityDaysProvider`, `masturbationDaysProvider`, `calendarMonths`
- `lib/features/settings/data/layout_preference.dart` – `ListLayout`, `listLayoutProvider`
- `lib/shared/widgets/event_calendar.dart` – `SliverEventCalendar`, `CalendarDay`, `CalendarWeekdayHeader`
- `lib/shared/widgets/heart_mark.dart` – `HeartMark`
- `lib/shared/widgets/day_events_sheet.dart` – `showDayEventsSheet`
- `lib/shared/widgets/layout_toggle.dart` – `ListLayoutToggle`

Modificati:

- `lib/core/config/app_config.dart` – `prefListLayout`
- `lib/core/utils/formatters.dart` – `dateLong`, `weekdayNarrow`
- `lib/app/theme.dart` – token `genderFemale`, `genderMale`, metodo `gender()`
- `lib/app/router.dart` – `Routes.activity/masturbation(id, year:)`, lettura della query `year`
- `lib/features/activities/presentation/activities_list_screen.dart`, `activity_form_screen.dart`
- `lib/features/masturbations/presentation/masturbations_list_screen.dart`, `masturbation_form_screen.dart`
- `docs/features/activities.md`, `docs/features/masturbations.md`, `docs/knowledge/design-system.md`, `docs/knowledge/architecture.md`, `docs/knowledge/decisions.md`, `docs/README.md`

## Step

### Step 1 – Dominio puro e preferenza di vista

- [x] `day_events.dart`: `groupByDay(items, dateOf)` → `Map<DateOnly, List<T>>` senza mutare l'input (B4)
- [x] `monthsDescending(first, last)`, `focusMonthOf`, `daysInMonth`, `leadingBlanks`, `weekRows`
- [x] `layout_preference.dart` con `ListLayout { list, calendar }` e persistenza in `prefListLayout`
- [x] Chiave in `AppConfig`
- [x] `dart format .` e `flutter analyze` senza issue

**Checkpoint:** cambio vista, riavvio app (force-stop + avvio), la vista calendario resta – ✅ verificato il 2026-11-13 sull'emulatore

### Step 2 – Provider derivati per il calendario

- [x] `calendar_providers.dart`: combinano le liste per anno di `selectableYears()` e raggruppano per giorno
- [x] Stati: errore se un anno fallisce, caricamento finché manca un anno, poi dati
- [x] Calcolo nel provider (memoizzato), non nel `build`
- [x] Contratto dei notifier invariato; il calendario osserva tutti gli anni, quindi le invalidazioni si propagano
- [x] `dart format .` e `flutter analyze` senza issue

**Checkpoint:** il calendario mostra i record del 2025 e del 2026 con i conteggi per mese coerenti con la lista (Novembre 2026: 3, Ottobre 2026: 10) – ✅ verificato il 2026-11-13. Aggiornamento dopo un salvataggio non provato (nessuna scrittura sul backend).

### Step 3 – Widget condivisi: calendario, cuore, foglio

- [x] `HeartMark` pieno o diviso, disegnato con `Path`, `shouldRepaint` sui due colori
- [x] `SliverEventCalendar`: mesi dal più recente, titolo + conteggio, griglia 7 colonne in una `Tile`, oggi su cerchio tonale, futuri attenuati, cuore sotto il numero
- [x] Un nodo semantico per cella ("Venerdì 20 giugno 2025, 2 attività, 2 scopate"); celle con record = pulsanti
- [x] Tap solo sulle celle con record, con feedback aptico
- [x] `showMonth` con offset esatto (`SliverVariedExtentList` + `precedingScrollExtent` − app bar compressa), animazione via `context.motion`
- [x] Colori solo da `context.appColors` / `colorScheme`, testi da `textTheme`
- [x] `showDayEventsSheet` con `useRootNavigator: true`
- [x] `dart format .` e `flutter analyze` senza issue

**Checkpoint:** scroll fluido, salto a un anno lontano allineato sotto la riga dei giorni, tema chiaro e scuro – ✅ verificato il 2026-11-13 (schermata di prova non necessaria: verificato direttamente sulle schermate reali)

### Step 4 – Vista calendario Attività

- [x] `ListLayoutToggle` (segmented a icone) nell'app bar, accanto alla pillola anno; "Vai a oggi" in vista calendario
- [x] Cuore `accent` nei giorni con attività
- [x] 1 record → form; più record → foglio → form (`Routes.activity(id, year:)`)
- [x] Pillola anno → scorrimento all'anno
- [x] Stato vuoto: `EmptyState` sopra il calendario
- [x] Pull-to-refresh di tutti gli anni nella vista calendario
- [x] `dart format .` e `flutter analyze` senza issue

**Checkpoint:** 8 dicembre 2025 (1 attività, anno selezionato 2025) → form corretto; 20 giugno 2025 (2 attività) → foglio con 2 righe → tocco sulla seconda → form "Pompino, Chiappe" del 20-06-2025; selezione 2025 → calendario su Dicembre 2025 – ✅ verificato il 2026-11-13

### Step 5 – Vista calendario Masturbazioni

- [x] Token `genderFemale` / `genderMale` (chiaro e scuro), contrasti calcolati (≥ 3:1 per elementi grafici)
- [x] `MasturbationHeart.of(items, profile)` puro
- [x] Cuore in base al sesso dal profilo osservato (`requireProfileProvider`)
- [x] Foglio con le righe della lista → `Routes.masturbation(id, year:)`
- [x] Legenda: un cuore per partner con il nome + "Entrambi"
- [x] `dart format .` e `flutter analyze` senza issue

**Checkpoint:** cuori blu nei giorni di Andrea (maschio), legenda con cuore blu, rosso e bicolore – ✅ verificato il 2026-11-13. ⬜ **Cuore bicolore su un giorno reale non verificato**: nei dati (206 masturbazioni dal 2024) non esiste un giorno con entrambi i partner e non ho creato record di prova sul backend di produzione. Il disegno bicolore è verificato nella legenda (stesso widget), la logica in `MasturbationHeart.of` per lettura. ⬜ Cuore rosso su giorno reale: nessuna masturbazione di Daniela nei mesi visti.

### Step 6 – Accessibilità, layout e rifinitura

- [x] Celle ≥ 48 dp: margine 12 dp, righe alte almeno 48 dp e più alte con testo grande
- [x] Testo al 200%: nessun overflow, righe più alte, riga L M M G V S D con scala limitata a 1,6
- [x] "Riduci movimento": `context.motion` → salto senza animazione (per lettura del codice)
- [x] Feedback aptico su tap del giorno e cambio vista
- [x] Tema scuro verificato

**Checkpoint:** emulatore in tema scuro con `font_scale 2.0`, tab Attività e Masturbazioni: nessuna striscia di overflow, nessun errore Flutter in logcat – ✅ verificato il 2026-11-13. ⬜ TalkBack non provato (etichette verificate per lettura del codice).

### Step finale – Documentazione

- [x] `docs/features/calendar-view.md` creato
- [x] `docs/features/activities.md` e `docs/features/masturbations.md` aggiornati
- [x] `docs/knowledge/design-system.md`: token e componenti
- [x] `docs/knowledge/architecture.md`: cartella `features/calendar/`, provider, query `year`
- [x] `docs/knowledge/decisions.md`: sezione "2026-11-13 – Vista calendario"
- [x] `docs/README.md` aggiornato
- [x] `README.md`: nessun nuovo comando, invariato

**Checkpoint:** documentazione coerente con il codice – ✅ verificato il 2026-11-13

## Deviazioni dalla specifica

| Punto | Specifica | Scelta | Motivo |
| --- | --- | --- | --- |
| Colore dei cuori masturbazioni | Colori legati allo slot (`A` celeste, `B` rosa), mai al nome (`AGENTS.md` §2.3) | Colore legato al **sesso** del partner dal profilo: rosso femmina, blu maschio | Richiesta esplicita dell'utente. Il sesso viene dal profilo (ammesso dal vincolo 3), non dal nome. Gli slot restano celeste/rosa nelle altre viste. |
| Calendario oltre l'anno selezionato | Il selettore anno filtra i dati (B5) | Il calendario mostra tutti gli anni; il selettore porta a un anno | Il calendario "a scorrimento verso il passato" non ha senso se limitato a un anno. |
| Token blu | Palette senza blu di genere | Nuovo token `genderMale` | Serve un blu distinguibile dal celeste dello slot A e dal rosso dell'accento. |
| Margine pagina | 16 dp | 12 dp nel calendario | Target tattile di 48 dp su schermi da 360 dp. |

## Rischi / punti aperti

- **Cuore bicolore e rosso su dati reali non verificati** (vedi step 5). Per provarli serve un giorno con masturbazioni di entrambi i partner: basta registrarne una nuova per Daniela nello stesso giorno di una di Andrea.
- ~~Titolo compresso troncato~~: risolto togliendo i titoli delle pagine (piano `2026-11-13-remove-page-titles.md`).
- **Aggiornamento dopo salvataggio/cancellazione** non provato sul calendario (nessuna scrittura sul backend); dipende dalle invalidazioni già esistenti dei notifier, che il calendario osserva.
- **Carico di rete**: in vista calendario si caricano tutti gli anni (oggi 3 × 2 richieste). Accettabile.
- L'offset di `showMonth` assume l'altezza M3 dell'app bar grande compressa (64 dp); se Flutter la cambiasse, il mese finirebbe leggermente sotto o sopra la riga dei giorni.

## Log di avanzamento

| Data | Cosa | Verifica | Prossimo passo |
| --- | --- | --- | --- |
| 2026-11-13 | Piano creato dopo lettura di `AGENTS.md`, feature doc, modelli, provider, `design-system.md`, `backend-api.md`. Nessun codice. | — | Conferma dei punti aperti |
| 2026-11-13 | Utente: "Implementa il piano" (default confermati). Step 1–6: dominio, provider, widget, schermate, token, query `year` nei form. | `dart format .` pulito, `flutter analyze` 0 issue; emulatore Medium Phone API 35 (APK debug): vista calendario su entrambi i tab, salto anno, "Vai a oggi", tap su giorno singolo e multiplo, tema scuro + testo 200%, persistenza dopo riavvio, logcat senza errori | — |
| 2026-11-13 | Documentazione aggiornata; piano chiuso. | Lettura incrociata doc/codice | Verificare cuore bicolore/rosso con dati reali; decidere se spostare il selettore sotto il titolo |
