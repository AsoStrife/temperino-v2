# Piano: rimozione dei titoli grandi delle pagine

- **Stato:** ✅ Completato
- **Inizio:** 2026-11-13
- **Ultimo aggiornamento:** 2026-11-13
- **Feature doc:** `docs/features/activities.md`, `masturbations.md`, `stats.md`, `settings.md`, `app-shell-theme.md`
- **Avanzamento:** 3/3 step

## Obiettivo

Le pagine Attività, Masturbazioni, Statistiche e Impostazioni non mostrano più il titolo grande (`SliverAppBar.large`): la barra in alto contiene solo i comandi (pillola anno, selettore vista, segmented) e il contenuto parte subito sotto. La pagina corrente è già indicata dalla barra di navigazione in basso.

## Ambito

- In ambito: `AppPage` senza titolo grande (parametro `title` rimosso), barra sottile fissa con i comandi; barra di altezza zero (solo sfondo della status bar) quando non ci sono comandi (Impostazioni); offset del pull-to-refresh e dello scorrimento del calendario adeguati alla nuova altezza.
- Fuori ambito: Home (già senza titolo), form (hanno il loro `AppBar` con titolo), contenuti delle pagine.

## File coinvolti

- `lib/shared/widgets/app_page.dart` – modificato
- `lib/shared/widgets/event_calendar.dart` – altezza della barra fissa
- `lib/features/activities/presentation/activities_list_screen.dart`, `lib/features/masturbations/presentation/masturbations_list_screen.dart`, `lib/features/stats/presentation/stats_screen.dart`, `lib/features/settings/presentation/settings_screen.dart` – tolto `title`
- `docs/features/*.md`, `docs/knowledge/design-system.md`, `docs/knowledge/decisions.md`, `docs/README.md`

## Step

### Step 1 – `AppPage` senza titolo

- [x] Rimuovere `title` e il ramo `SliverAppBar.large`
- [x] Barra sottile fissa (`kToolbarHeight`) con i comandi; altezza zero se non ci sono comandi né `bottom`
- [x] `edgeOffset` del `RefreshIndicator` calcolato dall'altezza reale della barra
- [x] Funzione statica `AppPage.barHeight(hasActions:, bottomHeight:)` usata dal calendario per l'offset di `showMonth`
- [x] `dart format .` e `flutter analyze` senza issue

**Checkpoint:** `flutter analyze` pulito – ✅ verificato il 2026-11-13

### Step 2 – Schermate

- [x] Togliere `title` da Attività (lista e calendario), Masturbazioni (lista e calendario), Statistiche, Impostazioni

**Checkpoint:** emulatore: le quattro pagine partono subito con il contenuto; il calendario salta all'anno scelto con il mese allineato sotto la riga dei giorni; pull-to-refresh visibile sotto la barra; tema chiaro e scuro – ✅ verificato il 2026-11-13 (pull-to-refresh: offset calcolato, non provato a mano)

### Step finale – Documentazione

- [x] Feature doc e `design-system.md` aggiornati, voce in `decisions.md`, indice

**Checkpoint:** documentazione coerente con il codice – ✅ verificato il 2026-11-13

## Deviazioni dalla specifica

| Punto | Prima | Scelta | Motivo |
| --- | --- | --- | --- |
| Header delle pagine | `SliverAppBar.large` (redesign del 2026-11-12) | Nessun titolo, barra sottile con i comandi | Richiesta del proprietario: i titoli occupano molto spazio e la pagina è già indicata dalla barra in basso. |

## Rischi / punti aperti

- TalkBack non annuncia più un titolo di pagina; il tab selezionato nella barra in basso resta leggibile.

## Log di avanzamento

| Data | Cosa | Verifica | Prossimo passo |
| --- | --- | --- | --- |
| 2026-11-13 | Piano creato | — | Step 1 |
| 2026-11-13 | `AppPage` senza titolo, `barHeight` usato dal calendario; titoli tolti dalle 4 schermate; doc aggiornata | `dart format .`, `flutter analyze` 0 issue; emulatore: Attività (calendario), Masturbazioni (salto al 2025 allineato sotto la riga dei giorni), Statistiche, Impostazioni, lista Attività in tema scuro | — |
