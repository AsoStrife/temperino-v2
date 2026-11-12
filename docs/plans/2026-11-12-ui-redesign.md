# Piano: Redesign completo della UI

- **Stato:** ✅ Completato
- **Inizio:** 2026-11-12
- **Ultimo aggiornamento:** 2026-11-12
- **Feature doc:** tutti i file in `docs/features/`, nuovo `docs/knowledge/design-system.md`
- **Avanzamento:** 8/8 step

## Obiettivo

La UI della prima versione riprendeva troppo la vecchia app (card con bordo, palette marrone/salmone da `fromSeed`, form a lista di interruttori). Va rifatta con uno stile moderno in ogni schermata, e i form vanno ripensati per essere più rapidi da compilare. Dati, provider, rete e logica non cambiano.

## Direzione di design

- **Superfici neutre e pulite**: sfondo grigio chiarissimo (`#F4F4F6`) / quasi nero (`#0B0B0D`), tile bianche / grafite senza bordo, raggio 24. Niente tinte salmone.
- **Colore usato con intenzione**: corallo per le azioni e l'hero, blu e arancio solo per i dati dei partner. Varianti "ink" più scure per il testo colorato, così il contrasto resta AA.
- **Tipografia**: titoli grandi e pesanti con tracking stretto, numeri in cifre tabulari, etichette piccole e attenuate.
- **Layout bento**: tile di dimensioni diverse in griglia, hero con gradiente, barre di confronto fra partner.
- **Navigazione**: barra flottante a pillola con le cinque destinazioni (solo icone) e un pulsante "+" rotondo accanto, sempre a portata di pollice. Il contenuto scorre sotto la barra.
- **Header**: `SliverAppBar.large` che si comprime durante lo scroll, con il selettore anno a pillola.
- **Liste**: gruppi per mese in stile "inset grouped" (un contenitore arrotondato per mese, righe compatte), swipe per cancellare (con conferma).
- **Form a schermo intero con barra di salvataggio fissa in basso**, campi più rapidi:
  - data con scorciatoie "Oggi" / "Ieri" / "Altro giorno";
  - "Scopata" come grande interruttore in evidenza;
  - pratiche come griglia di tile selezionabili con icona;
  - orgasmi come contatori grandi affiancati per partner;
  - zona della sborrata come chip selezionabili (niente menu a tendina);
  - masturbazione: scelta del partner con due grandi tile con avatar;
  - conferma se si esce con modifiche non salvate.

## Ambito

- In ambito: `lib/app/theme.dart`, `lib/app/shell_scaffold.dart`, `lib/shared/widgets/*`, tutte le schermate in `features/*/presentation/`, widget dei grafici.
- Fuori ambito: modelli, repository, provider, rete, logica statistica, route (i path restano uguali).

## Step

### Step 1 – Design system

- [x] Palette: `AppPalette` + `AppColors` con superfici, testo attenuato, varianti ink, gradiente hero
- [x] `ThemeData` custom: `ColorScheme` sopra `fromSeed(#E4572E)` con superfici neutre, tipografia, forme (raggio 24/16/pill), componenti (bottoni, chip, snackbar, dialog, bottom sheet, input, switch)
- [x] Contrasto WCAG AA verificato con il calcolo (testo normale ≥ 4,5:1)

**Checkpoint:** `flutter analyze` pulito – ✅ 2026-11-12

### Step 2 – Componenti condivisi

- [x] `AppScaffold`/pagina con `SliverAppBar.large`, pull-to-refresh, padding per la barra flottante
- [x] `Tile`, `MetricTile`, `HeroTile`, `PartnerSplitBar`, `SectionTitle`, `InsetGroup`
- [x] `YearPill`, `EmptyState`, `AsyncBody` ridisegnati
- [x] Componenti form: `DateQuickPicker`, `ToggleTile`, `SelectableTile`, `BigCounter`, `ChoiceChipsWrap`, `SaveBar`

**Checkpoint:** `flutter analyze` pulito – ✅ 2026-11-12

### Step 3 – Shell e navigazione

- [x] Barra flottante a pillola + pulsante "+" contestuale (tab Attività → nuova attività, tab Masturbazioni → nuova masturbazione, altrove → foglio di scelta)
- [x] `extendBody`, status bar invariata, back verso Home invariato

**Checkpoint:** navigazione fra i cinque tab e "+" su emulatore – ✅ 2026-11-12

### Step 4 – Onboarding e Home

- [x] Onboarding: hero con icona, due tile partner, pulsante "Continua" fisso in basso
- [x] Home: header grande, hero con gradiente (scopate), confronto orgasmi con barra divisa, tile rapide, scorciatoie di inserimento

**Checkpoint:** screenshot chiaro e scuro – ✅ 2026-11-12

### Step 5 – Liste e form

- [x] Liste attività e masturbazioni: riepilogo in pillole, gruppi per mese inset, righe compatte, swipe per cancellare con conferma, stato vuoto con azione
- [x] Form attività e masturbazione con i nuovi campi, barra di salvataggio fissa, cancella nell'app bar, conferma uscita con modifiche

**Checkpoint:** apertura form nuovo, interazioni senza salvare, conferma di uscita – ✅ 2026-11-12 (salvataggio e swipe-cancella non provati per non scrivere sui dati reali)

### Step 6 – Statistiche

- [x] Tab come controllo segmentato a pillola
- [x] Riepilogo bento, rapporti D/A, grafici ristilizzati (griglie leggere, aree sfumate, barre arrotondate)
- [x] Tab masturbazioni ridisegnato

**Checkpoint:** screenshot delle due sezioni – ✅ 2026-11-12

### Step 7 – Impostazioni

- [x] Gruppi inset, righe partner con avatar, anno e tema in fogli/segmentati

**Checkpoint:** screenshot chiaro e scuro – ✅ 2026-11-12

### Step 8 – Documentazione

- [x] `docs/knowledge/design-system.md` (nuovo)
- [x] `docs/features/*.md` aggiornati
- [x] `docs/knowledge/decisions.md` (deviazioni: ordine dei campi dei form, swipe, "+" globale)
- [x] `AGENTS.md` (regole UI) e `docs/README.md`

**Checkpoint:** documentazione coerente con il codice – ✅ 2026-11-12

## Deviazioni dalla specifica

| Punto | Specifica | Scelta | Motivo |
| --- | --- | --- | --- |
| Ordine campi form attività | interruttori → zona → data → orgasmi | data → scopata → pratiche → orgasmi → zona | Richiesta del proprietario di migliorare l'usabilità: prima il contesto (quando), poi il dato principale. |
| Zona della sborrata | menu a tendina | chip selezionabili | Un tocco invece di due, tutte le opzioni visibili. |
| Pulsante + | in basso a destra nelle liste | "+" fisso accanto alla barra di navigazione, contestuale al tab | Inserimento rapido da qualunque schermata. |
| Barra inferiore | `NavigationBar` | barra flottante a pillola custom | Stile moderno richiesto. |
| Cancellazione | dal form | dal form e con swipe nella lista (sempre con conferma) | Usabilità. |

## Log di avanzamento

| Data | Cosa | Verifica | Prossimo passo |
| --- | --- | --- | --- |
| 2026-11-12 | Piano creato | — | Step 1 |
| 2026-11-12 | Step 1–8 completati | `flutter analyze` 0 issue; emulatore API 35: onboarding, Home, liste, form attività e masturbazione, conferma uscita, foglio "+", statistiche (entrambe le sezioni), impostazioni; tema chiaro e scuro; font scale 2.0 senza overflow | Corretti durante la verifica: titolo grande dell'app bar sovrascritto dal tema, barra divisa invisibile (altezza 0), parola spezzata nelle scorciatoie, colore dei segmenti non selezionati, titolo grafici troppo grande, icona giocattoli |
| 2026-11-12 | Ritocchi richiesti dal proprietario: palette rosa/rosso e celeste, Home senza titolo, fogli dal basso sopra la barra flottante | Emulatore: Home e foglio anni ✅ | — |
| — | Da fare a mano | Salvataggio, modifica e swipe-cancella su record di prova | — |
