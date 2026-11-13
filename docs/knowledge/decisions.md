# Decisioni e deviazioni dalla specifica

Registro delle scelte tecniche. Aggiungi una voce datata quando prendi una decisione non ovvia o ti discosti da `migration-flutter.md`.

## 2026-11-12 – Riscrittura iniziale

| Tema | Specifica | Scelta | Motivo |
| --- | --- | --- | --- |
| Versione Flutter | 3.50 | **3.47.1** (Dart 3.13.1), quella installata | Non si aggiorna l'SDK della macchina senza chiedere. Il codice non usa API specifiche di 3.50. Per aggiornare: `flutter upgrade`, poi `flutter pub upgrade` e verifica (vedi README). |
| Posizione progetto | `flutter create … temperino` (sottocartella) | Progetto nella radice del repository `temperino-v2` | Il repository è dedicato all'app. |
| `riverpod_annotation` / generator | Elencati | **Non usati**: provider scritti a mano | Meno codegen e meno dipendenze; l'API manuale di Riverpod 3 è sufficiente e più leggibile. |
| `json_annotation` / `json_serializable` | Elencati | **Non usati**: mapping manuale nei DTO | La forma Strapi `{id, attributes}` e la lettura tollerante (0/1/null) sono più chiare a mano. `freezed` resta per i modelli. |
| `ShellRoute` | `ShellRoute` | `StatefulShellRoute.indexedStack` | Ogni tab conserva stato e scroll; è l'evoluzione di `ShellRoute` in go_router. |
| Nomi dei metodi dei notifier | `add`, `update`, `delete` | `add`, `edit`, `remove` | `update` è già un metodo di `AsyncNotifier` in Riverpod. |
| Barre orizzontali (sborrate, pratiche) | fl_chart | Widget custom `HorizontalBars` | Etichette italiane lunghe ("Niente (no sborrata)") che vanno a capo e scalano al 200%; `BarChart` di fl_chart ruotato gestisce male le etichette. Linee, ciambella e confronto anni usano fl_chart. |
| Confronto anni: misura | "stesse misure" | Selettore Scopate / Orgasmi totali per mese | Una linea per anno su 12 mesi resta leggibile solo con una misura alla volta. |
| Rapporto D/A quando B viene | `orgasm_b > 0` | `sex == true` e `orgasm_b > 0` | Coerente con "orgasmi durante il sesso quando B viene" (sezione 6 della specifica). |
| Etichette di dominio extra | — | `practiceLabels`, `genderLabel*`, chiavi preferenze, parametri di query in `AppConfig` | Regola "nessun altro file contiene etichette/URL/parametri". |
| Analisi statica | `flutter analyze` pulito | In più: `strict-casts`, `strict-inference`, `strict-raw-types` e lint extra | Qualità del codice. |
| Codice generato | — | `*.freezed.dart` versionati | Il progetto compila subito dopo il clone. |
| `versionCode` | — | `2.0.0+1` in `pubspec.yaml` | **Da verificare**: deve essere maggiore dell'ultimo `versionCode` caricato sul Play Store dalla vecchia app Capacitor, altrimenti l'upload fallisce. |
| Icona adattiva | — | Sfondo `#33BEF9` (colore del bordo di `web-icon.png`), foreground con inset 16% | L'icona sorgente è un quadrato pieno: con questo sfondo la maschera non taglia il disegno. |
| Splash | `flutter_native_splash` "se serve" | Generata con `flutter_native_splash` (sfondo chiaro/scuro del tema + icona) | Coerenza fra Android < 12 e ≥ 12. |
| Back Android | modali prima, poi indietro | In più: dai tab diversi da Home il back porta a Home prima di uscire | Comportamento standard delle app con bottom bar. |

## 2026-11-12 – Redesign della UI

Richiesta del proprietario: la prima UI riprendeva troppo la vecchia app; rifarla in stile moderno, form compresi. Dettagli in `design-system.md` e nel piano `docs/plans/2026-11-12-ui-redesign.md`.

| Tema | Prima | Ora | Motivo |
| --- | --- | --- | --- |
| Palette | `fromSeed(#E4572E)` puro (toni marroni/salmone) | Superfici neutre custom sopra `fromSeed`, corallo solo per azioni, varianti `…Ink` per il testo colorato | Aspetto pulito e contrasto AA |
| Card | `Card.outlined` / `Card.filled` | `Tile` senza bordo, raggio 24, layout bento | Stile moderno |
| Barra di navigazione | `NavigationBar` M3 | Barra flottante a pillola custom + pulsante "+" | Stile moderno, inserimento rapido da ogni tab |
| Pulsante + | FAB nelle due liste | "+" globale contestuale accanto alla barra | Un solo punto di inserimento sempre visibile |
| Header | `AppBar` | `SliverAppBar.large` (titolo grande che si comprime) | Gerarchia più chiara |
| Statistiche | `TabBar` + `TabBarView` | Segmented a pillola che cambia il contenuto della stessa pagina | Un solo scroll, header coerente con le altre pagine |
| Form attività: ordine | interruttori → zona → data → orgasmi | data → sesso → pratiche → orgasmi → zona | Prima il contesto, poi il dato principale |
| Form: pratiche | 7 `SwitchListTile` | `ToggleTile` "Sesso" + griglia di tile selezionabili | Scansione visiva più rapida, target grandi |
| Form: zona | `DropdownMenu` | Chip selezionabili ("Niente" prima) | Un tocco invece di due, tutte le opzioni visibili |
| Form: data | Riga che apre il DatePicker | Chip Oggi / Ieri / Altro giorno | I due casi più frequenti con un tocco |
| Form: orgasmi | Riga con − n + | `BigCounter` affiancati per partner | Target più grandi, numero leggibile |
| Form: masturbazione "chi" | `SegmentedButton` | Due grandi tile con avatar | Scelta più evidente |
| Form: salvataggio | Pulsanti in fondo alla lista | `SaveBar` fissa + cestino nell'app bar | Azione principale sempre visibile |
| Form: uscita | Nessuna protezione | Conferma se ci sono modifiche non salvate | Evita perdite accidentali |
| Liste | Card con bordo per elemento | Gruppi per mese "inset grouped", righe compatte, pillole di riepilogo | Densità e leggibilità |
| Cancellazione | Solo dal form | Anche con swipe nella lista (sempre con conferma) | Usabilità |
| Modifica partner | Dialogo | Foglio dal basso | Più comodo con la tastiera |
| Icona giocattoli | `Icons.toys` (macchinina) | `Icons.vibration_rounded` | Pertinenza |

## 2026-11-12 – Palette rosa/rosso e celeste

Richiesta del proprietario: colori più sul rosa/rosso e celeste, per richiamare la sessualità; l'arancione non piace. **Deviazione dalla specifica** (sezione 10: partner 1 blu #2F80ED, partner 2 arancio #F2994A, accento #E4572E).

| Ruolo | Specifica | Ora |
| --- | --- | --- |
| Partner 1 (A) | Blu #2F80ED | Celeste #38B6F2 (testo #0A72B0) |
| Partner 2 (B) | Arancio #F2994A | Rosa #F0569B (testo #C2185B) |
| Accento / seed | Rosso #E4572E | Rosso lampone #E5304D (testo e bottoni #D21E45) |
| Gradiente hero e "+" | — | #E5304D → #F0569B |

Nello stesso giro: tolto il titolo "Il vostro {anno}" dalla Home (il saluto fa da intestazione) e i fogli dal basso (anno, partner, "Cosa aggiungi?") si aprono sul navigator principale (`useRootNavigator: true`), così non finiscono sotto la barra flottante.

## 2026-11-13 – Vista calendario

Richiesta del proprietario: una variante a calendario delle liste, "come le app del ciclo", con un cuore nei giorni con record; nelle masturbazioni cuore rosso per una donna, blu per un uomo, bicolore se entrambi. Piano: `docs/plans/2026-11-13-calendar-view.md`, feature: `docs/features/calendar-view.md`.

| Tema | Regola / prima | Scelta | Motivo |
| --- | --- | --- | --- |
| Colore dei cuori masturbazioni | Colori legati allo slot (A celeste, B rosa) | Colore dal **sesso** nel profilo: `genderFemale` rosso, `genderMale` blu nuovo (#2563EB / #60A5FA) | Richiesta esplicita. Il sesso viene dal profilo (ammesso dal vincolo 3 di `AGENTS.md`), mai dal nome. Il blu è distinto dal celeste dello slot A per non confondere i due significati. Usati solo dai cuori. |
| Cuore bicolore | — | Metà sinistra = partner 1, metà destra = partner 2, ciascuna nel colore del proprio sesso; stesso sesso → metà uguali | Coerente con l'ordine degli slot; TalkBack legge comunque i nomi. |
| Cuore attività | — | Un solo colore (`accent`) | Nessuna richiesta di distinguere le pratiche; il dettaglio è nel foglio. |
| Anni nel calendario | Il selettore anno filtra le liste (B5) | Il calendario mostra tutti gli anni da `startYear`; la pillola anno porta il calendario a quell'anno | Un calendario "a scorrimento verso il passato" limitato a un anno non avrebbe senso. |
| Preferenza vista | — | Una sola preferenza per i due tab (`settings.listLayout`) | Chi preferisce il calendario lo vuole ovunque. |
| Margine laterale del calendario | 16 dp | 12 dp | Con 16 dp, su 360 dp la cella è ~47 dp (< 48 dp di target minimo); con 12 dp è 48 dp. |
| Form da un altro anno | Il form cercava il record solo nell'anno selezionato | Query `?year=AAAA` sulle route di modifica; salvataggio e cancellazione via notifier dell'anno del record | Dal calendario si aprono record di qualsiasi anno; senza questo il form diceva "non trovata". |
| Settimana | — | Da lunedì, iniziali da `intl` (`EEEEE`, it_IT) | Convenzione italiana. |

## 2026-11-13 – Pagine senza titolo

Richiesta del proprietario: i titoli grandi di Attività, Masturbazioni, Statistiche e Impostazioni occupano molto spazio e non servono, perché la barra in basso indica già la pagina. Piano: `docs/plans/2026-11-13-remove-page-titles.md`.

| Tema | Prima | Ora | Motivo |
| --- | --- | --- | --- |
| Header delle pagine | `SliverAppBar.large` con titolo che si comprime (redesign 2026-11-12) | `AppPage` senza parametro `title`: barra sottile fissa con i soli comandi; alta zero (solo sfondo della status bar) se non ci sono comandi, come in Impostazioni | Più spazio per i contenuti; risolve anche il titolo compresso troncato ("Masturba…") della vista calendario. |

## 2026-11-13 – Supporto tablet

Richiesta del proprietario: usare l'app anche sullo Xiaomi Pad 7, in verticale e in orizzontale, senza rifare l'interfaccia. Studio: `tablet-usability.md`; piano: `docs/plans/2026-11-13-tablet-support.md`; feature: `docs/features/tablet-layout.md`.

| Tema | Prima | Scelta | Motivo |
| --- | --- | --- | --- |
| Criterio | Solo telefono | Breakpoint per larghezza in dp (600 / 840), mai per tipo di dispositivo | Regge schermo diviso, finestre flottanti, "dimensione display" di HyperOS e telefono in orizzontale. |
| Telefono | — | Sotto 600 dp nulla cambia; i layout a colonne impilati danno l'ordine del telefono | Il layout del telefono è considerato definitivo dal proprietario. |
| Navigazione tablet verticale | Barra a tutta larghezza | Barra centrata, max 560 dp | Icone vicine come sul telefono, raggiungibili col pollice. |
| Navigazione tablet orizzontale | Barra in basso | Rail verticale a sinistra con "+" | Libera altezza (dimensione scarsa), sotto il pollice sinistro, pattern Material 3. Condizione `altezza ≥ 480` per escludere il telefono in orizzontale. |
| Etichette nella rail | — | Solo tooltip, come sulla barra | "Masturbazioni"/"Impostazioni" non stanno in 64 dp; coerenza col telefono. |
| Larghezza contenuti | Tutta la larghezza | 760 dp per liste/impostazioni/onboarding, 1200 dp per pagine a colonne; scroll a tutta larghezza | Righe leggibili; numeri vicini alle etichette. |
| Liste | — | Solo centrate, nessuna lista-dettaglio | La lista-dettaglio cambierebbe navigazione, ritorno predittivo e conferma di uscita dei form: un rifacimento, non richiesto. |
| Calendario | Una colonna | Griglia di 2–3 mesi con 6 settimane fisse | Celle proporzionate e 6 mesi visibili; mesi della stessa riga allineati. |
| Form | Una colonna, tutto schermo | Tutto schermo, due colonne da ~780 dp, "Salva" centrato max 480 | Il form sta in una schermata in orizzontale; restano ritorno predittivo e conferma di uscita. Scartato il dialog centrato (comportamento diverso fra telefono e tablet, rotazione più fragile). |
| SnackBar | Tutta la larghezza | 480 dp centrate da 600 dp, via `Theme` sempre presente in `MaterialApp.builder` | Un wrapper condizionale ricreerebbe l'albero dell'app alla rotazione. |
| Verifica | — | AVD `Pad7_API_35` creato a mano (2136 × 3200, 320 dpi) | Nessun emulatore tablet disponibile; `cmdline-tools` assenti, quindi niente `avdmanager`. |

## Punti aperti (default applicati)

- `minSdk` 24: confermare con la distribuzione dei dispositivi in Play Console.
- Profilo locale: su un nuovo telefono (o sul tablet) l'onboarding va rifatto.
- Tablet: layout verificato su emulatore che imita il Pad 7, non ancora sul dispositivo reale.
- Cumshot di default `none`; i record vecchi con valore vuoto vengono letti come `none` (e contati nella zona "Niente").
- Sort Strapi: **risolto** – il backend ignora `sort`, l'ordinamento è nel client (vedi `backend-api.md`).
