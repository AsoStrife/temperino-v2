# Studio di usabilità: tablet

Studio del 13/11/2026 per portare Temperino sul tablet del proprietario (Xiaomi Pad 7) senza rifare l'interfaccia. Piano: `docs/plans/2026-11-13-tablet-support.md`. Regole risultanti: `design-system.md` § "Schermi grandi".

## 1. Dispositivo e contesto d'uso

| | Xiaomi Pad 7 |
| --- | --- |
| Schermo | 11,2", 3200 × 2136 px, proporzione 3:2 |
| Spazio logico (densità 320 dpi, default) | **~1068 × 1600 dp** in verticale, **~1600 × 1068 dp** in orizzontale (meno barre di sistema) |
| Altre finestre | HyperOS permette schermo diviso e finestre flottanti: larghezze da ~400 a ~1000 dp |
| Input | Tocco; tastiera/cover e mouse opzionali |

Contesto: app personale, usata a casa. In verticale il tablet si tiene con una mano e si tocca con l'altra; in orizzontale si tiene con due mani (pollici sui bordi laterali, a metà altezza) oppure si appoggia su un tavolo o sulle gambe. Le sessioni tipiche sono: guardare il riepilogo o le statistiche, aggiungere un record, scorrere il calendario.

**Conseguenza:** il layout si decide in base allo **spazio disponibile in dp**, non al tipo di dispositivo. Così funzionano allo stesso modo il Pad 7 con qualsiasi "dimensione display", lo schermo diviso e un telefono in orizzontale.

## 2. Classi di larghezza

Allineate alle *window size classes* di Material 3:

| Classe | Larghezza finestra | Esempi | Comportamento |
| --- | --- | --- | --- |
| Compatta | < 600 dp | Telefono in verticale, metà schermo diviso | **Identico a prima** |
| Media | 600–839 dp | Telefono in orizzontale, tablet in schermo diviso | Margini 24 dp, contenuto centrato, barra centrata |
| Espansa | ≥ 840 dp | Pad 7 verticale (~1068) e orizzontale (~1600) | Margini 32 dp, più colonne; in orizzontale rail laterale |

## 3. Cosa non funziona oggi su tablet

Analisi delle schermate a 1068 dp e 1600 dp di larghezza.

| # | Schermata | Problema | Gravità |
| --- | --- | --- | --- |
| P1 | Shell | La barra flottante si allarga a tutto schermo: 5 icone distanziate ~200 dp, il "+" all'estremo destro; in orizzontale ruba ~90 dp di altezza su 1068 | Alta |
| P2 | Tutte | Tile larghe fino a 1500 dp: righe di testo lunghissime, numeri isolati lontano dall'etichetta, enorme spazio vuoto dentro le tile | Alta |
| P3 | Home, Statistiche | Una colonna sola: su 1600 × 1068 si vedono 2–3 tile per schermata e serve scorrere molto | Media |
| P4 | Liste | Righe da 1500 dp: data a sinistra e conteggi orgasmi a destra separati da metà schermo, lettura difficile | Alta |
| P5 | Calendario | Celle larghe ~210 dp ma alte 60: mese schiacciato e deformato; si vede un mese alla volta in orizzontale | Alta |
| P6 | Heatmap | Celle limitate a 16 dp: il grafico occupa metà della tile, il resto è vuoto | Bassa |
| P7 | Form | Campi, chip e contatori stirati su tutta la larghezza; bottone "Salva" largo 1500 dp; in orizzontale il form richiede scorrimento anche se lo spazio ci sarebbe | Media |
| P8 | SnackBar | A tutta larghezza in basso | Bassa |
| P9 | Onboarding | Campi stirati; in orizzontale serve scorrere | Bassa |
| ok | Fogli dal basso | Material 3 li limita già a 640 dp e li centra | — |
| ok | Dialoghi, DatePicker | Già dimensionati e adattivi (il DatePicker ha un layout orizzontale) | — |

## 4. Decisioni

### D1 – Navigazione

- **Compatta:** invariata.
- **Media e espansa in verticale:** la barra flottante resta in basso (familiare, raggiungibile col pollice della mano che tocca) ma è **centrata e larga al massimo 560 dp** (barra + "+"). Le icone tornano vicine come sul telefono. *(P1)*
- **Espansa in orizzontale** (larghezza ≥ 840 e maggiore dell'altezza, altezza ≥ 480 dp): **rail verticale flottante a destra**, stessa pillola sfocata e stesse icone, con il "+" sotto, centrati in altezza. Libera ~90 dp di altezza, che in orizzontale è la dimensione scarsa. Il lato destro sostituisce la scelta iniziale del lato sinistro su richiesta esplicita del proprietario del 13/11/2026 (piano `docs/plans/2026-11-13-tablet-rail-right.md`). Il contenuto sta a sinistra della rail e non scorre sotto. *(P1)*
- Etichette solo in tooltip e semantica anche nella rail: "Masturbazioni" e "Impostazioni" non stanno in 64 dp e la coerenza col telefono vale più delle etichette.
- Scartata la rail anche in verticale: in verticale l'altezza non scarseggia e la barra in basso resta più vicina al pollice.

### D2 – Larghezza e margini del contenuto

- Margine laterale adattivo: 16 / 24 / 32 dp (compatta / media / espansa).
- Due larghezze massime, contenuto centrato, scroll e pull-to-refresh su tutta la larghezza (si può trascinare anche sui margini vuoti):
  - **Leggibile, 760 dp:** liste, impostazioni, onboarding. Righe con data, dettagli e conteggi vicini. *(P2, P4)*
  - **Ampia, 1200 dp:** pagine a più colonne (Home, Statistiche, calendario, form a due colonne). *(P2)*
- Su telefono il margine resta 16 e le larghezze massime non intervengono.

### D3 – Più colonne dove i contenuti sono indipendenti *(P3)*

- **Home:** saluto a tutta larghezza; sotto due colonne: hero + confronto orgasmi | metriche + "Aggiungi" + link alle statistiche. Impilando le colonne si ottiene esattamente l'ordine del telefono.
- **Statistiche – Attività:** le 4 metriche in una riga, i due confronti fra partner affiancati, i grafici a coppie (andamento orgasmi | rapporto D/A; zone | pratiche); heatmap e confronto fra anni a tutta larghezza.
- **Statistiche – Masturbazioni:** le tile dei due partner affiancate; confronto e ciambella affiancati.
- Le colonne si attivano in base alla larghezza disponibile (componenti `ResponsiveGrid` / `ResponsiveColumns`), quindi anche in schermo diviso degradano bene.

### D4 – Calendario a griglia di mesi *(P5)*

- Mesi in griglia: **1 colonna** sotto 720 dp di contenuto (come ora), **2 colonne** fino a 1200, **3 colonne** oltre. Pad 7: 2 in verticale (6 mesi visibili), 3 in orizzontale (6 mesi visibili).
- Ordine invariato (più recente in alto a sinistra, poi verso destra e in basso).
- In griglia ogni mese ha la sua riga L M M G V S D (la riga fissa sotto la barra vale solo per una colonna) e 6 righe di settimane, così tutti i mesi di una riga hanno la stessa altezza e la griglia resta ordinata.
- "Vai a oggi" e la pillola anno scorrono alla riga del mese.

### D5 – Liste

- Righe a larghezza leggibile (760 dp) centrate. Valutate e scartate: righe su due colonne (spezzerebbe l'ordine cronologico e lo swipe per cancellare) e lista-dettaglio con il form in un pannello (cambia la navigazione, il ritorno predittivo e la conferma di uscita dei form: un rifacimento, fuori dalla richiesta). Su tablet la vista consigliata per esplorare è il calendario a griglia.

### D6 – Form *(P7)*

- Restano a tutto schermo (stessa navigazione, ritorno predittivo, conferma di uscita).
- Da ~780 dp di contenuto i blocchi vanno su **due colonne**: Attività = Quando + Com'è andata | Orgasmi + Zona; Masturbazione = Chi + Quando | Dettagli + Orgasmi. In orizzontale il form sta in una schermata senza scorrere.
- `SaveBar`: il bottone resta in basso, centrato e largo al massimo 480 dp.
- Valutato e scartato il form in dialog centrato: su telefono e tablet si comporterebbero in modo diverso, e la rotazione con un dialog aperto è più fragile.

### D7 – Dettagli *(P6, P8, P9)*

- Heatmap: celle fino a 24 dp (prima 16) e grafico centrato nella tile.
- SnackBar: larghezza fissa 480 dp, centrata, da 600 dp.
- Onboarding: larghezza leggibile, i due partner affiancati quando c'è spazio.
- Fogli dal basso: nessuna modifica (Material 3 li limita a 640 dp). Restano con `useRootNavigator: true`; con la rail compaiono centrati sulla finestra.

## 5. Principi da mantenere

1. Il telefono non cambia: ogni layout a colonne, impilato, deve dare l'ordine attuale.
2. Spazio disponibile, non dispositivo: niente `isTablet`; si misura la larghezza (`LayoutBuilder` / `SliverLayoutBuilder`) o la finestra (`MediaQuery.sizeOf`) solo per la navigazione.
3. Testo ingrandito: le soglie delle colonne si dividono per il fattore di scala del testo (come `ResponsivePair`), così con caratteri grandi si torna a una colonna.
4. Target ≥ 48 dp, contrasto e animazioni invariati.
5. La rotazione non perde stato (tab, scroll, form aperti).

## 6. Verifica

Emulatore `Pad7_API_35` (2136 × 3200, 320 dpi → 1068 × 1600 dp), creato a mano in `~/.android/avd` copiando la configurazione del telefono. Esito per schermata nel piano e in `docs/features/tablet-layout.md`.
