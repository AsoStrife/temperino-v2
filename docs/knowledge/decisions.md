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
| `versionCode` | — | `1.2.0+1` in `pubspec.yaml` | **Da verificare**: deve essere maggiore dell'ultimo `versionCode` caricato sul Play Store dalla vecchia app Capacitor, altrimenti l'upload fallisce. |
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

## Punti aperti (default applicati)

- `minSdk` 24: confermare con la distribuzione dei dispositivi in Play Console.
- Profilo locale: su un nuovo telefono l'onboarding va rifatto.
- Cumshot di default `none`; i record vecchi con valore vuoto vengono letti come `none` (e contati nella zona "Niente").
- Sort Strapi: **risolto** – il backend ignora `sort`, l'ordinamento è nel client (vedi `backend-api.md`).
