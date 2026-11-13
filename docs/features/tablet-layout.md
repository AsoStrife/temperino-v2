# Feature: Layout adattivo per tablet

Piani: `docs/plans/2026-11-13-tablet-support.md`, `docs/plans/2026-11-13-tablet-rail-right.md`. Studio di usabilità e motivazioni: `docs/knowledge/tablet-usability.md`. Regole e componenti: `docs/knowledge/design-system.md` § "Schermi grandi".

## Comportamento

L'app si adatta alla **larghezza disponibile in dp** (non al tipo di dispositivo). Sotto 600 dp tutto è identico al layout del telefono.

| Classe | Larghezza | Esempi |
| --- | --- | --- |
| Compatta | < 600 dp | Telefono in verticale |
| Media | 600–839 dp | Telefono in orizzontale, tablet in schermo diviso |
| Espansa | ≥ 840 dp | Xiaomi Pad 7 in verticale (~1068 dp) e orizzontale (~1600 dp) |

### Navigazione

- **Compatta:** barra flottante a tutta larghezza (invariata).
- **Media/espansa:** barra flottante in basso, centrata, larga al massimo 560 dp con il "+".
- **Tablet in orizzontale** (finestra ≥ 840 dp, più larga che alta, alta almeno 480 dp): **rail verticale flottante a destra**, centrata in altezza, con il "+" sotto. Il contenuto sta a sinistra della rail. La rail gestisce l'inset di sistema destro; il contenuto conserva quello sinistro. Stesse icone, tooltip, semantica, "+" contestuale e back Android. In verticale la barra resta in basso.
- Ruotando il dispositivo il passaggio barra ↔ rail non perde lo stato dei tab (scroll, vista lista/calendario).

### Pagine

| Schermata | Tablet |
| --- | --- |
| Home | Saluto, poi due colonne: hero + orgasmi totali │ metriche + "Aggiungi" + statistiche. Larghezza massima 1200 dp. |
| Statistiche – Attività | Le 4 metriche in una riga, i due confronti affiancati, grafici a coppie (orgasmi per mese │ rapporto D/A; zone │ pratiche), heatmap e "Negli anni" a tutta larghezza. Selettore Attività/Masturbazioni centrato e largo al massimo 480 dp. |
| Statistiche – Masturbazioni | Tile dei due partner affiancate; confronto e ciambella affiancati. |
| Attività, Masturbazioni (lista) | Righe centrate, larghezza massima 760 dp. |
| Attività, Masturbazioni (calendario) | Griglia di mesi: 2 colonne in verticale, 3 in orizzontale (1 sotto ~720 dp di contenuto). Ogni mese ha la sua riga L M M G V S D e 6 righe di settimane; la riga fissa sotto la barra c'è solo con una colonna. "Vai a oggi" e la pillola anno scorrono alla riga del mese. |
| Form attività / masturbazione | A tutto schermo; da ~780 dp di contenuto due colonne (Attività: Quando + Com'è andata │ Orgasmi + Zona; Masturbazione: Chi + Quando │ Dettagli + Orgasmi). In orizzontale il form sta in una schermata. Bottone "Salva" centrato, largo al massimo 480 dp. |
| Onboarding | Larghezza 760 dp, i due partner affiancati. |
| Impostazioni | Larghezza 760 dp. |
| Fogli dal basso | Invariati: Material 3 li limita a 640 dp e li centra. |
| SnackBar | Da 600 dp larghe 480 dp e centrate. |

Con testo di sistema ingrandito le soglie delle colonne crescono in proporzione (si torna a meno colonne).

## Componenti e file

- `lib/shared/widgets/adaptive.dart` – nuovo: `AppLayout` (breakpoint, margini 16/24/32, larghezze 760/1200, `columns`, `useRail`), `SliverPageWidth`, `PageListView`, `ResponsiveGrid`, `ResponsiveColumns`, `textScaleOf`.
- `lib/app/shell_scaffold.dart` – barra centrata / rail (`_FloatingNavBar` con `axis`).
- `lib/app/app.dart` – larghezza delle SnackBar (`Theme` sempre presente nel `builder`).
- `lib/shared/widgets/app_page.dart` – `PageSection(maxWidth:)`.
- `lib/shared/widgets/month_grouped_list.dart` – `SliverMonthGroups`, `SummaryPills` a larghezza leggibile.
- `lib/shared/widgets/event_calendar.dart` – griglia di mesi (`columnsFor`, `insetFor`, `_WeekdayInitials`).
- `lib/shared/widgets/form_widgets.dart` – `SaveBar` centrata, `formColumnMinWidth`, `formColumnGap`.
- `lib/features/home/presentation/home_screen.dart`, `lib/features/stats/presentation/stats_screen.dart`, `stats/presentation/widgets/calendar_heatmap.dart` (celle fino a 24 dp, centrata).
- `lib/features/activities/presentation/activities_list_screen.dart`, `activity_form_screen.dart`, `lib/features/masturbations/presentation/masturbations_list_screen.dart`, `masturbation_form_screen.dart`, `lib/features/onboarding/presentation/onboarding_screen.dart`.

## Casi limite

- **Telefono in orizzontale** (~914 × 411 dp): classe espansa ma altezza < 480 dp → niente rail (non ci starebbe), barra in basso centrata; Home e Statistiche a due colonne.
- **Schermo diviso / finestra flottante:** decide la larghezza della finestra; a metà schermo il tablet si comporta come un telefono.
- **Rotazione con form aperto:** le modifiche non salvate restano (verificato).
- **Densità diversa** ("dimensione display" di HyperOS): cambiano i dp disponibili, i breakpoint si adattano.

## Verifica manuale

Emulatore `Pad7_API_35` (2136 × 3200, 320 dpi = 1068 × 1600 dp, vedi `README.md`) e telefono `Medium_Phone_API_35`, 13/11/2026.

1. Onboarding sul tablet: partner affiancati, "Continua" centrato. ✅
2. Home verticale (barra centrata, due colonne) e orizzontale (rail). ✅ chiaro e scuro
3. Statistiche verticale e orizzontale: 4 metriche in riga, grafici a coppie, heatmap centrata; selettore centrato. ✅ chiaro e scuro
4. Lista attività centrata a 760 dp. ✅
5. Calendario attività: 2 colonne in verticale, 3 in orizzontale; "Vai a oggi" dopo aver scorso. ✅ Calendario masturbazioni con legenda allineata. ✅ scuro
6. Rotazione verticale ↔ orizzontale: tab, vista calendario e form con modifiche non salvate conservati. ✅
7. Form attività (orizzontale e verticale) e modifica masturbazione (orizzontale, scuro) a due colonne; conferma di uscita con modifiche. ✅ **Salvataggio non provato**: il backend è quello reale e non si creano record di prova; la logica di salvataggio non è cambiata.
8. Foglio "Cosa aggiungi?" dalla rail: centrato. ✅
9. Impostazioni in orizzontale, scuro. ✅
10. Telefono: Home, Statistiche, lista e calendario identici a prima; telefono in orizzontale con barra centrata e Home a due colonne. ✅
11. Dispositivo reale Pad 7: ⬜ da fare.

### Verifica spostamento rail a destra (13/11/2026)

- `dart format .`: 69 file, nessuna variazione; `flutter analyze`: zero issue.
- App debug in esecuzione su `Pad7_API_35`: Home in orizzontale, rail a destra e "+" sotto; Statistiche in tema scuro con la stessa posizione. ✅
- Rotazione da Statistiche in orizzontale a verticale: tab conservato e barra in basso; verificati entrambi i temi. ✅
- Home su `Medium_Phone_API_35` in verticale, tema chiaro e scuro: barra in basso e layout invariati. ✅
- Breakpoint e condizioni di `AppLayout.useRail` invariati. Nessuna modifica ai form o ai dati del backend; dispositivo reale non verificato.
