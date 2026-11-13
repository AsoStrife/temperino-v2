# Feature: Home

Route `/`, primo tab della barra flottante. Stile: vedi `docs/knowledge/design-system.md`.

## Contenuto (dall'alto)

1. Barra sottile con la sola pillola `YearSelector` (nessun titolo: `AppPage` senza `title`).
2. Saluto grande "Ciao {nome 1} e {nome 2}" come intestazione.
3. `HeroTile` con gradiente rosso → rosa: numero di **scopate** (attività con `sex == true`) e "su N attività nel {anno}", illustrazione `sexual-activities.jpg`.
4. `PartnerSplitTile` "Orgasmi totali" (attività + masturbazioni): nomi, numeri e barra divisa nei colori dei partner.
5. Due `MetricTile`: Rapporto D/A durante il sesso ("—" se indefinito, B1) e numero di masturbazioni dell'anno (tap → tab Masturbazioni).
6. Sezione "Aggiungi": due tile "Nuova attività" / "Nuova masturbazione".
7. Tile "Vedi tutte le statistiche" → tab Statistiche.

Pull-to-refresh: ricarica le due liste dell'anno (`HomeScreen.refreshYear`). Caricamento ed errore (con "Riprova") tramite `asyncSlivers`.

## Dati

`summaryProvider(year)` e `masturbationSummaryProvider(year)`.

## File

- `lib/features/home/presentation/home_screen.dart`

## Verifica manuale

1. Scopate = attività con pillola "Scopata" nella lista; orgasmi totali = attività + masturbazioni del partner.
2. Cambio anno dalla pillola → valori aggiornati senza riavvio.
3. Senza rete → stato di errore con "Riprova".
4. Verificato su emulatore il 12/11/2026 (chiaro e scuro, testo ingrandito).

## Tablet

Sui tablet: saluto, poi due colonne (hero + orgasmi totali │ metriche, "Aggiungi", statistiche), larghezza massima 1200 dp. Dettagli in `tablet-layout.md`.
