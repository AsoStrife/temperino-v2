# Piano: Supporto tablet (verticale e orizzontale)

- **Stato:** ✅ Completato
- **Inizio:** 2026-11-13
- **Ultimo aggiornamento:** 2026-11-13
- **Feature doc:** `docs/features/tablet-layout.md`
- **Studio di usabilità:** `docs/knowledge/tablet-usability.md`
- **Avanzamento:** 7/7 step

## Obiettivo

L'app si usa bene su un tablet (riferimento: Xiaomi Pad 7, ~1068 × 1600 dp) in verticale e in orizzontale, senza cambiare l'aspetto su smartphone: su larghezze < 600 dp ogni schermata resta identica a prima.

## Ambito

- In ambito: breakpoint e componenti adattivi condivisi; navigazione (barra centrata / rail laterale); larghezza massima e margini delle pagine; layout a più colonne di Home, Statistiche, form, onboarding; calendario a griglia di mesi; SnackBar e SaveBar su schermi larghi; documentazione (studio, design system, AGENTS.md).
- Fuori ambito: vista lista-dettaglio con il form in un pannello laterale (valutata e scartata, vedi studio); iOS; nuove funzioni; modifiche al backend.

## File coinvolti

- `lib/shared/widgets/adaptive.dart` – nuovo: `AppLayout` (breakpoint, margini, larghezze), `SliverPageWidth`, `PageWidth`, `ResponsiveGrid`, `ResponsiveColumns`
- `lib/app/shell_scaffold.dart` – barra centrata con larghezza massima; rail verticale in orizzontale
- `lib/app/app.dart` – SnackBar a larghezza fissa su schermi larghi
- `lib/shared/widgets/app_page.dart` – `PageSection` con larghezza massima
- `lib/shared/widgets/month_grouped_list.dart`, `event_calendar.dart`, `form_widgets.dart` (`SaveBar`)
- `lib/features/home/…/home_screen.dart`, `stats/…/stats_screen.dart`, `stats/…/widgets/calendar_heatmap.dart`
- `lib/features/activities/…`, `masturbations/…` (liste e form), `settings/…`, `onboarding/…`
- `docs/knowledge/tablet-usability.md` (nuovo), `docs/features/tablet-layout.md` (nuovo), `docs/knowledge/design-system.md`, `docs/knowledge/decisions.md`, `docs/knowledge/architecture.md`, `docs/features/*.md` toccati, `docs/README.md`, `AGENTS.md`, `README.md`

## Step

### Step 1 – Studio di usabilità

- [x] Analisi delle schermate attuali su larghezze tablet (cosa si rompe o spreca spazio)
- [x] Decisioni: breakpoint, navigazione, larghezze, layout per schermata
- [x] `docs/knowledge/tablet-usability.md`

**Checkpoint:** il documento copre ogni schermata e ogni decisione ha una motivazione – ✅ verificato il 2026-11-13

### Step 2 – Fondamenta adattive

- [x] `adaptive.dart` con `AppLayout` e i widget responsive
- [x] `PageSection`, `SummaryPills`, `SliverMonthGroups` rispettano larghezza massima e margine adattivo
- [x] SnackBar a larghezza fissa da 600 dp
- [x] `dart format .` e `flutter analyze` senza issue

**Checkpoint:** su telefono nulla cambia (margine 16, stessa disposizione); su tablet le liste sono centrate – ✅ verificato il 2026-11-13 (telefono e `Pad7_API_35`)

### Step 3 – Navigazione

- [x] Barra flottante centrata e limitata in larghezza da 600 dp
- [x] Rail verticale flottante a sinistra con "+" quando la finestra è ≥ 840 dp e orizzontale
- [x] Stato dei tab conservato ruotando il dispositivo

**Checkpoint:** rotazione verticale ↔ orizzontale su tablet senza perdita di stato, "+" contestuale funzionante in entrambe le modalità – ✅ verificato il 2026-11-13

### Step 4 – Home e Statistiche

- [x] Home a due colonne
- [x] Statistiche: metriche in griglia da 4, confronti e grafici affiancati, heatmap più grande
- [x] Masturbazioni (statistiche): tile dei partner affiancate

**Checkpoint:** Home e Statistiche senza overflow in verticale e orizzontale, chiaro e scuro, testo ×2 – ✅ verificato il 2026-11-13

### Step 5 – Liste e calendario

- [x] Liste centrate a larghezza leggibile
- [x] Calendario a griglia di mesi (2 colonne in verticale, 3 in orizzontale) con i giorni della settimana dentro ogni mese
- [x] "Vai a oggi" e pillola anno funzionano anche nella griglia

**Checkpoint:** calendario a griglia scorre e salta al mese giusto – ✅ verificato il 2026-11-13 (2 colonne in verticale, 3 in orizzontale, "Vai a oggi")

### Step 6 – Form, onboarding, impostazioni

- [x] Form attività e masturbazione a due colonne da ~780 dp di contenuto
- [x] `SaveBar` con bottone centrato a larghezza massima
- [x] Onboarding con i due partner affiancati; impostazioni a larghezza leggibile

**Checkpoint:** form attività e modifica masturbazione a due colonne in orizzontale e verticale; modifiche non salvate conservate alla rotazione; conferma di uscita – ✅ verificato il 2026-11-13. Salvataggio **non** provato: il backend è quello reale (vedi Deviazioni).

### Step 7 – Documentazione

- [x] `docs/features/tablet-layout.md`
- [x] `docs/knowledge/design-system.md` (sezione "Schermi grandi"), `decisions.md`, `architecture.md`
- [x] `docs/features/*.md` toccati, `docs/README.md`, `README.md` (emulatore tablet)
- [x] `AGENTS.md` (regole per layout adattivi)

**Checkpoint:** documentazione coerente con il codice – ✅ verificato il 2026-11-13

## Deviazioni dalla specifica

| Punto | Specifica | Scelta | Motivo |
| --- | --- | --- | --- |
| Dispositivi | La specifica considera solo smartphone | Layout adattivo per tablet (≥ 600 dp) | Richiesta del proprietario (Xiaomi Pad 7) |
| Checkpoint step 6 | Salvare record dal tablet | Solo layout, rotazione e conferma di uscita | Il backend è di produzione: niente record di prova senza il permesso del proprietario. La logica di salvataggio non è cambiata. |
| Selettore Statistiche | Non previsto nel piano | Centrato, max 480 dp | Emerso in verifica: a 1500 dp il segmented era larghissimo. |

## Rischi / punti aperti

- La densità reale del Pad 7 dipende dalle impostazioni di HyperOS ("dimensione display"): i breakpoint sono per larghezza in dp, non per dispositivo, quindi si adattano.
- Verifica su emulatore che imita il Pad 7 (2136 × 3200, 320 dpi), non sul dispositivo reale: da provare sul Pad 7.
- Telefono in orizzontale: la barra in basso occupa ~90 dp su ~411 (come prima); la rail è esclusa perché non ci starebbe in altezza.

## Log di avanzamento

| Data | Cosa | Verifica | Prossimo passo |
| --- | --- | --- | --- |
| 2026-11-13 | Analisi del codice, studio di usabilità, piano; creato AVD `Pad7_API_35` | — | Step 2 |
| 2026-11-13 | Step 2–6: `adaptive.dart`, shell (barra centrata / rail), SnackBar, Home, Statistiche, heatmap, liste, calendario a griglia, form, onboarding | `flutter analyze` pulito; prova su `Pad7_API_35` (verticale/orizzontale, chiaro/scuro, testo ×2) e su `Medium_Phone_API_35` (verticale/orizzontale). Trovato e corretto un vincolo invalido (`minWidth: infinity`) sul selettore delle Statistiche | Step 7 |
| 2026-11-13 | Step 7: documentazione (feature, studio, design system, decisioni, architettura, calendario, README, AGENTS.md) | Rilettura | Prova sul Pad 7 reale |
