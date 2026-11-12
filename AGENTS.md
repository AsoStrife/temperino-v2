# AGENTS.md – Regole per chi lavora su Temperino (agenti e persone)

Temperino è un'app Flutter (solo Android) che registra attività sessuali e masturbazioni di due partner su un backend Strapi v4 esistente. Questa app sostituisce la vecchia app Vue/Framework7/Capacitor (`../temperino-fe`). La specifica di partenza è `migration-flutter.md`.

Leggi questo file per intero prima di modificare il progetto.

---

## 1. Regole di documentazione (obbligatorie)

Ogni modifica al codice va documentata. Una modifica non documentata è una modifica non finita.

| Cosa | Dove | Regola |
| --- | --- | --- |
| Feature | `docs/features/<feature>.md` | **Un file per feature.** Descrive comportamento, schermate, provider, file coinvolti, casi limite e verifica manuale. Se modifichi una feature, aggiorni il suo file nello stesso lavoro. Se crei una feature, crei il file. |
| Conoscenza di progetto | `docs/knowledge/<argomento>.md` | Architettura, contratto API del backend, decisioni prese, scoperte (es. comportamento reale del backend), ambiente e versioni, bug storici. Tutto ciò che serve a capire il "perché". |
| Piani di implementazione | `docs/plans/AAAA-MM-GG-<slug>.md` | **Ogni implementazione ha un piano**, creato *prima* di scrivere codice, partendo da `docs/plans/TEMPLATE.md`. |
| Indice | `docs/README.md` | Elenca tutti i file di `features/`, `knowledge/` e `plans/`. Aggiornalo quando aggiungi un file. |
| Istruzioni operative | `README.md` | Build, firma, icone, splash, versioni, aggiornamento librerie. Aggiornalo ogni volta che cambia un comando, una versione o un passo. |

### 1.1 Piani (`docs/plans/`)

Ogni piano deve essere specifico e diviso in step con checkpoint, così lo stato di avanzamento è sempre leggibile:

- Intestazione con stato globale: `Stato: 🟡 In corso | ✅ Completato | ⛔ Bloccato | ⏸️ Sospeso`, data di inizio e di ultimo aggiornamento.
- Obiettivo, ambito, fuori ambito, file toccati.
- Step numerati. Ogni step ha sotto-attività con checkbox (`- [ ]` / `- [x]`) e un **checkpoint di verifica** esplicito (comando o flusso manuale) che dice quando lo step è finito.
- Sezione **Log di avanzamento** in fondo, con una riga datata per ogni sessione di lavoro (cosa fatto, cosa verificato, cosa resta).
- Sezione **Deviazioni** dalla specifica, con motivazione.
- Aggiorna le checkbox e il log **mentre lavori**, non solo alla fine. Se interrompi il lavoro, il piano deve permettere a un altro agente di riprendere da dove sei rimasto.

### 1.2 Lingua

- Documentazione (`docs/`, `README.md`, `AGENTS.md`): italiano.
- Testi dell'interfaccia: italiano.
- Codice, identificatori e commenti nel codice: inglese.

---

## 2. Vincoli di progetto (dalla specifica)

1. **Backend invariato.** Solo gli endpoint documentati in `docs/knowledge/backend-api.md`. Niente nuovi endpoint, niente login, niente modifiche allo schema Strapi.
2. **Un solo file di configurazione:** `lib/core/config/app_config.dart` contiene URL, endpoint, token, parametri di query, etichette di dominio, chiavi di `shared_preferences`. Nessun altro file contiene questi valori. Le stringhe con `$` sono raw string (`r'filters[date][$gte]'`).
3. **Nome e sesso dei partner non stanno nel codice:** vengono dal profilo locale (`profileProvider`). Nel backend i partner sono solo `A` (partner 1, celeste) e `B` (partner 2, rosa). Colori e avatar sono legati allo slot, mai al nome.
4. **Niente test automatici** (unit, widget, integration) e niente pacchetti di test. La verifica è `flutter analyze` + prova manuale con l'app in esecuzione.
5. **Niente migrazioni di dati**, import, export, cache offline.
6. **Solo Android.** iOS fuori ambito.
7. I bug B1–B14 della vecchia app non vanno reintrodotti: vedi `docs/knowledge/bugfixes.md`.
8. **Non committare** se l'utente non lo chiede esplicitamente.

---

## 3. Architettura

```
lib/
  main.dart            bootstrap: edge-to-edge, intl it_IT, SharedPreferences, ProviderScope
  app/                 MaterialApp.router, tema, router (go_router), shell con NavigationBar
  core/                config, rete (dio), errori, storage, utilità pure (DateOnly, formatter)
  features/<nome>/
    domain/            modelli immutabili (freezed) e logica pura, NESSUN import di Flutter
    data/              DTO (mapping JSON) e repository (unici a usare ApiClient)
    presentation/      provider Riverpod, schermate, widget della feature
  shared/widgets/      widget riusabili fra feature
```

Regole di dipendenza (non violarle):

- `presentation` → `data` → `core`. `domain` non dipende da nessun altro livello applicativo.
- Le schermate **non** usano dio né `ApiClient`: leggono provider.
- I provider **non** conoscono i widget (niente `BuildContext` nei provider).
- Le statistiche sono funzioni pure in `features/stats/domain/stats_calculator.dart`; non modificano mai le liste in input (B4).
- Ogni errore che arriva alla UI è un `AppException` con messaggio in italiano.

Dettagli: `docs/knowledge/architecture.md`.

---

## 4. Linee guida Flutter / Dart

### 4.1 Stile e analisi

- `dart format .` prima di chiudere ogni lavoro. Nessuna modifica manuale allo stile prodotto dal formatter.
- `flutter analyze` deve riportare **zero issue**. `analysis_options.yaml` ha `strict-casts`, `strict-inference`, `strict-raw-types` e lint aggiuntivi: non disattivarli per far passare il codice; correggi il codice.
- Niente `print`/`debugPrint` nel codice consegnato. Log temporanei solo durante lo sviluppo e rimossi prima di chiudere lo step.
- Preferisci `final`, costruttori `const`, classi `abstract final` per contenitori di costanti/funzioni statiche, `sealed` per gerarchie chiuse (vedi `AppException`).
- Usa i pattern di Dart 3 (record, switch esaustivi, null-aware elements `?x`) dove migliorano la leggibilità.
- Niente `dynamic` implicito; cast espliciti e tolleranti nei DTO (`JsonReaders`).
- Import relativi all'interno di `lib/`, ordinati (`directives_ordering`).
- Un widget pubblico per file quando il widget è riusato; widget privati (`_Nome`) nello stesso file della schermata.

### 4.2 Stato (Riverpod 3)

- Provider scritti a mano (niente `riverpod_generator`): `Provider`, `NotifierProvider`, `AsyncNotifierProvider`, `FutureProvider`, con `.family` per l'anno.
- I notifier "family" ricevono l'argomento nel costruttore (`ActivitiesNotifier(this.year)`), come richiesto da Riverpod 3.
- Non chiamare `update`, `state` ecc. come nomi di metodi custom nei notifier: collidono con l'API di `AsyncNotifier` (per questo i metodi sono `add`, `edit`, `remove`).
- `ref.watch` nel `build`, `ref.read` nei callback. Mai `ref.watch` dentro callback o dopo un `await` nei notifier.
- Dopo ogni mutazione: ricarica la lista dell'anno e invalida i provider che ne dipendono (`yearlyProvider`, l'anno di origine se la data cambia anno).
- `ProviderScope(retry: ...)` disattiva i retry automatici: gli errori mostrano il pulsante "Riprova".
- `SharedPreferences` è caricato in `main` e iniettato con override di `sharedPreferencesProvider`: le letture sono sincrone.

### 4.3 Modelli e codegen

- Modelli di dominio con `freezed` (`@freezed abstract class X with _$X`). Il mapping JSON è manuale nei DTO (la forma Strapi `{id, attributes}` non si presta a `json_serializable`).
- Dopo aver modificato un modello: `dart run build_runner build`. I file `*.freezed.dart` **sono versionati**.
- Le date del backend sono `DateOnly` (mai `DateTime.parse` su `AAAA-MM-GG`, B11).

### 4.4 UI e UX

Il design system è documentato in **`docs/knowledge/design-system.md`**: leggilo prima di toccare qualunque schermata. Regole essenziali:

- **Niente stile scritto a mano nelle schermate.** Colori solo da `context.appColors` / `Theme.of(context).colorScheme`, raggi da `AppRadii`, testi da `textTheme`. Se serve un nuovo token o componente, aggiungilo a `theme.dart` / `lib/shared/widgets/` e documentalo in `design-system.md`.
- **Componenti condivisi prima di tutto**: `AppPage` per le pagine principali, `Tile`/`MetricTile`/`PartnerSplitTile`/`InsetGroup` per i contenuti, componenti di `form_widgets.dart` per i form. Non reintrodurre `Card.outlined`, `NavigationBar`, `DropdownMenu` o liste di `SwitchListTile`: è lo stile della vecchia app che il redesign ha eliminato.
- **Testo colorato**: usa `partnerInk` / `accentInk`, mai i colori di riempimento (`partnerA`, `partnerB`, `accent`) su testo piccolo. Contrasto AA verificato con il calcolo, non a occhio.
- **Form**: azione principale in `SaveBar` fissa in basso, cancellazione nell'app bar con conferma, conferma di uscita con modifiche non salvate (`PopScope` + `confirmDiscard`), un tocco dove possibile (chip, tile selezionabili, scorciatoie data).
- **Navigazione**: barra flottante + "+" contestuale in `ShellScaffold`; le pagine con `AppPage` gestiscono già il padding sotto la barra. Usa le costanti di `Routes`, `context.push` per i form, `context.go` per i tab.
- Fogli dal basso (`showModalBottomSheet`) sempre con `useRootNavigator: true`: le schermate dei tab vivono in navigator annidati e senza questo flag il foglio finisce sotto la barra flottante.
- Icone Material arrotondate (`Icons.*_rounded`).
- Edge-to-edge: `SafeArea` / `MediaQuery.padding`; la status bar segue il tema (`systemOverlayFor`).
- Accessibilità: `semanticsLabel` su tile e grafici (`ChartCard`), target touch ≥ 48dp, layout che reggono testo ingrandito (niente altezze fisse su contenitori di testo; `ResponsivePair`, `Wrap`, `SelectableGrid` si adattano).
- Animazioni brevi e sempre tramite `context.motion(...)` o `ChartStyle.duration(context)` (rispettano "riduci movimento"); feedback aptico leggero su selezioni.
- Stati asincroni con `asyncSlivers` / `AsyncBody` (caricamento / errore con Riprova / contenuto) ed `EmptyState` con azione.
- Feedback: ogni salvataggio o cancellazione mostra uno SnackBar; ogni errore mostra uno SnackBar con il messaggio (B8). Stato di caricamento unico per operazione, resettato in `finally` (B7).
- Cancellazioni (anche via swipe) sempre con `showConfirmDialog`.
- Prima di usare un `BuildContext` dopo un `await`, controlla `mounted` / `context.mounted`; cattura `ScaffoldMessenger.of(context)` prima dell'`await`.
- Ogni modifica visiva va verificata con l'app in esecuzione, in tema chiaro **e** scuro.

### 4.5 Rete

- Solo `ApiClient` (dio) con `Authorization: Bearer` aggiunto dall'interceptor.
- Le liste usano `fetchAllPages` + `yearQuery(year)`; i repository riordinano sempre in locale su una copia (il backend ignora `sort`: vedi `docs/knowledge/backend-api.md`).
- I body di POST/PUT sono sempre `{ "data": { ... } }` con booleani veri.
- Le richieste in parallelo usano `mapWithConcurrency` con `AppConfig.maxParallelRequests`.

### 4.6 Performance

- Liste lunghe con `ListView.builder`.
- Calcoli statistici nei provider derivati (memoizzati da Riverpod), non nel `build` dei widget.
- `const` ovunque possibile; `CustomPainter.shouldRepaint` preciso.

### 4.7 Android

- `applicationId`/`namespace` `com.strifelab.temperino` (aggiorna l'app esistente sul Play Store: non cambiarlo).
- `minSdk 24`, `targetSdk 36`, `compileSdk >= 36`. Solo permesso `INTERNET`, niente cleartext.
- Ritorno predittivo abilitato (`enableOnBackInvokedCallback` + `PredictiveBackPageTransitionsBuilder`).
- Firma release da `android/key.properties` (mai versionato).

---

## 5. Flusso di lavoro per ogni modifica

1. Leggi `docs/README.md`, il file della feature interessata e la knowledge pertinente.
2. Crea (o riprendi) il piano in `docs/plans/` dal template. Stato `🟡 In corso`.
3. Implementa uno step alla volta. A fine step: `dart format .`, `flutter analyze` pulito, checkpoint verificato, checkbox e log aggiornati.
4. Aggiorna `docs/features/*.md`, `docs/knowledge/*.md`, `docs/README.md` e `README.md` se serve.
5. Chiudi il piano (`✅ Completato`) con il riepilogo di cosa è stato verificato e cosa no.
6. Riporta all'utente: cosa è fatto, cosa è verificato (e come), punti aperti, deviazioni.

Per consultare la vecchia app (`../temperino-fe`) leggi solo il file che serve: la specifica e `docs/knowledge/` coprono già quasi tutto.

---

## 6. Comandi utili

```bash
flutter pub get
dart run build_runner build          # dopo modifiche ai modelli freezed
dart format .
flutter analyze
flutter run                          # debug su emulatore/dispositivo
flutter build apk --debug
flutter build appbundle --release    # richiede android/key.properties
dart run flutter_launcher_icons      # rigenera le icone
dart run flutter_native_splash:create
flutter pub outdated                 # controlla aggiornamenti delle librerie
```

Dettagli in `README.md`.
