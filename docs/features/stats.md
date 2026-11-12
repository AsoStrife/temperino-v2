# Feature: Statistiche e grafici

Route `/stats`, due tab: **Attività** e **Masturbazioni**. `YearSelector` nella barra superiore. Pull-to-refresh su entrambi i tab.

## Definizioni (A = partner 1, B = partner 2)

Implementate in `StatsCalculator` (funzioni pure, nessun import Flutter, input mai modificati).

| Misura | Definizione |
| --- | --- |
| Scopate | attività con `sex == true` |
| Orgasmi nelle attività | somma `orgasm_a` / `orgasm_b` su tutte le attività |
| Orgasmi durante il sesso | come sopra, solo `sex == true` |
| … quando B viene | `sex == true` e `orgasm_b > 0` |
| Orgasmi totali | attività + `n_orgasms` delle masturbazioni del partner |
| Rapporto D/A | B durante il sesso / A durante il sesso; `null` → "—" se A = 0 (B1) |
| Rapporto D/A quando B viene | stessa formula sulle attività con `orgasm_b > 0` |
| Pratiche | numero di attività per `blowjob`, `handjob`, `fingering`, `lick`, `tits_fuck`, `anal` |
| Sborrate per zona | conteggio per tutte le 12 zone, `none` compresa (B2), ordinate decrescenti |
| Orgasmi per mese | 12 valori per partner (attività + masturbazioni) |
| Rapporto D/A per mese | 12 valori, `null` per i mesi senza dati |
| Masturbazioni per partner | numero, con giocattoli, somma orgasmi |
| Calendario | per giorno: numero di attività e masturbazioni |
| Confronto anni | per ogni anno da `startYear` a oggi: scopate e orgasmi totali per mese |

## Layout

Titolo grande "Statistiche" con pillola anno; sotto, fisso anche quando il titolo si comprime, un segmented a pillola **Attività / Masturbazioni** che cambia il contenuto della pagina (un solo scroll, niente `TabBarView`). Stile: `docs/knowledge/design-system.md`.

## Sezione Attività

1. Bento di riepilogo: `MetricTile` Scopate (su N attività) e Orgasmi totali; `PartnerSplitTile` "Orgasmi nelle attività" e "Orgasmi durante il sesso"; due `MetricTile` con i rapporti D/A ("durante il sesso" e "quando {nome partner 2} viene").
2. **Andamento**: orgasmi per mese (fl_chart, due linee con area sfumata nei colori dei partner, legenda con i nomi, tooltip; i mesi futuri dell'anno corrente non si disegnano) e rapporto D/A per mese (linea con riferimento tratteggiato a 1,0, mesi senza dati non disegnati).
3. **Dettagli**: sborrate per zona (tutte le 12, barre orizzontali, la più frequente in rosso) e pratiche (barre celesti).
4. **Calendario**: `CustomPainter`, 12 righe × 31 giorni, intensità di rosso; tap su una cella mostra "12 marzo: N attività, M masturbazioni".
5. **Negli anni**: una linea per anno sui 12 mesi (anno corrente più spesso e con area), selettore Scopate / Orgasmi, caricamento finché gli anni non sono pronti.

## Sezione Masturbazioni

- Una tile per partner: avatar, nome, pillola con l'etichetta del sesso ("Seghe"/"Ditalini"); conteggio, con giocattoli, orgasmi; barra con la percentuale con giocattoli.
- `PartnerSplitTile` "Chi si tocca di più" (numero di masturbazioni).
- Ciambella (fl_chart `PieChart`): con/senza giocattoli per partner, al centro "con giocattoli / totale".

## Accessibilità

Ogni grafico è dentro `ChartCard` (una `Tile`) con un `semanticsLabel` che riassume il valore principale (letto da TalkBack); il disegno è escluso dall'albero semantico. Animazioni con `ChartStyle.duration(context)` (zero con "riduci movimento").

## Provider

`summaryProvider`, `monthlyProvider`, `monthlyRatioProvider`, `cumshotProvider`, `calendarProvider`, `masturbationSummaryProvider` (tutti `family` sull'anno) e `yearlyProvider`. `yearlyProvider` riusa le liste dell'anno corrente e scarica gli altri anni con al massimo `AppConfig.maxParallelRequests` (5) richieste contemporanee.

## File

- `lib/features/stats/domain/stats_calculator.dart`, `stats_models.dart`
- `lib/shared/widgets/partner_split.dart`, `tiles.dart`
- `lib/features/stats/presentation/stats_providers.dart`, `stats_screen.dart`
- `lib/features/stats/presentation/widgets/` – `chart_card.dart`, `chart_style.dart`, `monthly_orgasms_chart.dart`, `ratio_chart.dart`, `horizontal_bars.dart`, `calendar_heatmap.dart`, `year_comparison_chart.dart`, `toys_donut.dart`

## Verifica manuale

1. Le 12 zone compaiono tutte nel grafico sborrate (B2).
2. Anno senza scopate → rapporti "—" (B1), grafico rapporto "Nessun dato".
3. Somma dei valori mensili del grafico orgasmi = orgasmi totali della Home.
4. Tap su un giorno del calendario con un'attività nota → conteggio corretto (data senza slittamenti, B11).
5. Confronto anni mostra una linea per ogni anno da 2024.
6. TalkBack legge la descrizione di ogni grafico.
7. Layout ridisegnato verificato su emulatore il 12/11/2026 (sezioni Attività e Masturbazioni).
