# Design system

Stile introdotto con il redesign del 12/11/2026 (piano `docs/plans/2026-11-12-ui-redesign.md`). Obiettivo: un'interfaccia moderna e pulita, lontana dalla vecchia app Framework7 (card con bordo, liste di interruttori, menu a tendina).

Tutto è definito in `lib/app/theme.dart` e nei widget di `lib/shared/widgets/`. **Nelle schermate non si scrivono colori, raggi o stili a mano**: si usano i token e i componenti qui sotto.

## Principi

1. **Superfici neutre, colore con intenzione.** Sfondo grigio chiarissimo / quasi nero, tile bianche / grafite senza bordo. Il rosso lampone (con gradiente verso il rosa) è riservato ad azioni ed elementi principali; celeste e rosa solo ai dati dei partner. Palette scelta dal proprietario per richiamare la sessualità; niente arancione.
2. **Numeri protagonisti.** Valori grandi e pesanti con cifre tabulari, etichette piccole e attenuate.
3. **Un tocco dove possibile.** Scorciatoie (Oggi/Ieri), chip e tile selezionabili invece di menu; "+" sempre raggiungibile.
4. **Accessibile.** Contrasto AA per il testo, target ≥ 48 dp, layout che reggono testo grande, `Semantics` su tile e grafici, animazioni che rispettano "riduci movimento".

## Token di colore (`AppColors`, via `context.appColors`)

| Token | Chiaro | Scuro | Uso |
| --- | --- | --- | --- |
| `partnerA` | #38B6F2 (celeste) | #5CC6F7 | Riempimenti partner 1 (grafici, anelli, barre) |
| `partnerB` | #F0569B (rosa) | #FF6FAE | Riempimenti partner 2 |
| `partnerAInk` | #0A72B0 | #7CCBF7 | **Testo** colorato partner 1 (AA) |
| `partnerBInk` | #C2185B | #FF8CC1 | **Testo** colorato partner 2 (AA) |
| `accent` | #E5304D (rosso lampone) | #FF4D6A | Riempimenti accento (barra più frequente, calendario); seed del tema |
| `accentInk` | #D21E45 | #FF6B85 | Testo accento e `colorScheme.primary` (bottoni) |
| `heroStart` → `heroEnd` | #E5304D → #F0569B | #D9294A → #E8508F | Gradiente rosso → rosa di hero e pulsante "+" |
| `genderFemale` | #E5304D | #FF4D6A | Cuore del calendario masturbazioni per una donna (riempimento, non testo) |
| `genderMale` | #2563EB | #60A5FA | Cuore del calendario masturbazioni per un uomo (riempimento, non testo) |
| `muted` | #6B6B76 | #9A9AA5 | Testo secondario |
| `tile` | #FFFFFF | #161619 | Superficie delle tile |
| `tileHigh` | #F1F1F4 | #212126 | Superficie annidata (chip, campi, tracce) |
| `hairline` | #E6E6EC | #2A2A31 | Divisori e griglie dei grafici |
| `positive`, `warning`, `neutral` | dalla specifica | | Stati e dati neutri |

Sfondo pagina (`colorScheme.surface`): #F4F4F6 / #0B0B0D.

Contrasti verificati (WCAG): `accentInk` su bianco 5,23:1; bianco su `accentInk` 5,23:1; `partnerAInk` su bianco 5,19:1; `partnerBInk` su bianco 5,87:1; `muted` su bianco 5,26:1; nel tema scuro tutte le varianti ink superano 6,6:1 sulle tile. Il bianco sull'hero (#E5304D, 4,3:1) è usato solo per testo grande/bold, conforme AA per testo grande.

Cuori del calendario (elementi grafici, soglia WCAG 3:1), calcolati: `genderFemale` 4,32:1 su `tile` chiara e 3,93:1 sullo sfondo pagina; `genderMale` 5,17:1 e 4,71:1; nel tema scuro 5,61:1 (rosso) e 7,10:1 (blu) su `tile`. I token di genere sono l'unica eccezione alla regola "colori legati allo slot": servono solo ai cuori delle masturbazioni (vedi `decisions.md`).

Regola: **mai** usare `partnerA`/`partnerB`/`accent` per testo piccolo su tile chiare: usare le varianti `…Ink`.

## Forme e spaziature

| Token | Valore | Uso |
| --- | --- | --- |
| `AppRadii.tile` | 24 | Tile, card, gruppi |
| `AppRadii.inner` | 16 | Campi, snackbar, menu |
| `AppRadii.small` | 12 | Icon badge |
| Pillola | `StadiumBorder` | Bottoni, chip, segmented, selettore anno |
| Margine pagina | 16 | Orizzontale |
| Gap fra tile | 12 | Verticale e orizzontale |
| Spazio prima di una sezione | 28 (`SectionTitle`) | |

## Tipografia

Font di sistema (Roboto). Titoli e display con peso 700–800 e tracking negativo; numeri con `tabularFigures`. Le pagine principali non hanno titolo (la barra di navigazione indica dove si è); la Home apre con il saluto. Gerarchia tipica: `SectionTitle` (titleLarge) → titolo tile (titleMedium) → etichetta (titleSmall) → didascalia (bodySmall, `muted`).

## Componenti (`lib/shared/widgets/`)

| Componente | File | Quando usarlo |
| --- | --- | --- |
| `AppPage` | `app_page.dart` | Ogni schermata principale: nessun titolo, barra sottile fissa con i comandi (alta zero se non ce ne sono), `bottom` opzionale, pull-to-refresh, padding per la barra flottante. `AppPage.barHeight` dà l'altezza della barra |
| `PageSection`, `asyncSlivers` | `app_page.dart` | Contenuto a lista nel `CustomScrollView`; stati caricamento/errore |
| `Tile` | `tiles.dart` | Superficie base (anche con gradiente, tap e semantica) |
| `MetricTile` | `tiles.dart` | Numero grande + etichetta + didascalia, icon badge |
| `HeroTile` | `tiles.dart` | Dato principale della Home, gradiente |
| `PartnerSplitTile`, `SplitBar` | `partner_split.dart` | Confronto di un valore fra i due partner |
| `SectionTitle` | `tiles.dart` | Titolo di sezione |
| `InsetGroup` | `tiles.dart` | Righe in un unico contenitore con divisori (impostazioni, liste) |
| `ResponsivePair` | `tiles.dart` | Due tile affiancate, impilate se manca spazio |
| `Pill`, `IconBadge` | `tiles.dart` | Etichette e icone tonali |
| `YearSelector` | `year_selector.dart` | Pillola anno in alto a destra, apre un foglio |
| `EmptyState` | `empty_state.dart` | Stato vuoto/errore con azione |
| `SliverMonthGroups`, `DayBadge`, `CountBubble`, `SummaryPills` | `month_grouped_list.dart` | Liste per mese con swipe per cancellare |
| `SliverEventCalendar`, `CalendarDay`, `CalendarWeekdayHeader` | `event_calendar.dart` | Calendario verticale a mesi (più recente in alto) con marcatore per i giorni con record; la riga L M M G V S D va nel `bottom` di `AppPage`. Margine laterale 12 dp (celle ≥ 48 dp) |
| `HeartMark` | `heart_mark.dart` | Cuore pieno o diviso a metà in due colori, decorativo |
| `showDayEventsSheet` | `day_events_sheet.dart` | Foglio con i record di un giorno; restituisce quello toccato |
| `ListLayoutToggle` | `layout_toggle.dart` | Segmented a icone Lista / Calendario nell'app bar delle due liste |
| `DateQuickPicker` | `form_widgets.dart` | Data con Oggi / Ieri / Altro giorno |
| `ToggleTile` | `form_widgets.dart` | Interruttore importante a tutta larghezza |
| `SelectableGrid` | `form_widgets.dart` | Scelta multipla a tile con icona (2–3 colonne) |
| `ChoiceChipsWrap` | `form_widgets.dart` | Scelta singola fra molte opzioni brevi |
| `BigCounter` | `form_widgets.dart` | Contatore grande con − / + |
| `SaveBar` | `form_widgets.dart` | Azione principale fissa in fondo ai form |
| `FormLabel`, `confirmDiscard` | `form_widgets.dart` | Etichette dei blocchi, conferma uscita con modifiche |
| `showConfirmDialog` | `confirm_dialog.dart` | Conferme (cancellazioni sempre) |
| `PartnerAvatar` | `partner_avatar.dart` | Avatar con anello nel colore del partner |

## Navigazione

- Barra flottante a pillola (`lib/app/shell_scaffold.dart`) con 5 icone (etichetta in tooltip e semantica) e sfocatura dello sfondo; a fianco il pulsante "+" circolare con gradiente.
- "+" contestuale: tab Attività → nuova attività; tab Masturbazioni → nuova masturbazione; altrove → foglio "Cosa aggiungi?".
- Il contenuto scorre sotto la barra (`extendBody`): le pagine aggiungono `MediaQuery.paddingOf(context).bottom` in fondo (già fatto da `AppPage`).
- I form si aprono come "fullscreen dialog" (icona X), con `SaveBar` in basso e cancellazione nell'app bar.

## Grafici

- Contenuti in `ChartCard` (una `Tile` con titolo titleMedium, sottotitolo `muted`, `semanticsLabel`).
- Griglia orizzontale tratteggiata `hairline`, niente bordi.
- Linee con estremi arrotondati e area sfumata (`ChartStyle.area`).
- Barre orizzontali custom (`HorizontalBars`) spesse 12 con traccia `tileHigh`.
- Etichette degli assi con `Formatters.axis` (virgola decimale).

## Movimento

Durate 150–500 ms, curve `easeOutCubic`, sempre tramite `context.motion(...)` (zero con "riduci movimento"). Feedback aptico leggero su selezioni, contatori e "+".
