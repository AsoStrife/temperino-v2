# Piano: Riscrittura Flutter di Temperino (M0–M8)

- **Stato:** 🟡 In corso – M0–M7 completati; M8 parziale (manca la firma con il keystore di release e il giro dei flussi di scrittura sul dispositivo)
- **Inizio:** 2026-11-12
- **Ultimo aggiornamento:** 2026-11-12
- **Specifica:** `migration-flutter.md` (versione 3)
- **Feature doc:** tutti i file in `docs/features/`
- **Avanzamento:** 8/9 milestone complete

## Obiettivo

Nuova app Flutter Android, sullo stesso backend Strapi, con tutte le funzioni della vecchia app (11 schermate) più onboarding dei partner, statistiche e grafici, Material 3, status bar ed edge-to-edge, senza reintrodurre i bug B1–B14.

## Ambito

- In ambito: sezioni 3–12 della specifica.
- Fuori ambito: iOS, login, modifiche al backend, migrazione dati, test automatici, cache offline, export.

## Step

### M0 – Progetto

- [x] `flutter create --org com.strifelab --project-name temperino --platforms android .` (nella radice del repo)
- [x] `applicationId` / `namespace` = `com.strifelab.temperino`
- [x] Dipendenze aggiunte (vedi `docs/knowledge/environment.md`; deviazioni in `decisions.md`)
- [x] Struttura cartelle della sezione 8
- [x] Immagini in `assets/images/` (`temperinoA.jpg`, `temperinoD.jpg`, `sexual-activities.jpg`) e `assets-src/web-icon.png`
- [x] `minSdk 24`, `targetSdk 36`, `compileSdk >= 36`, label "Temperino", solo `INTERNET`, no cleartext
- [x] Icone generate con `flutter_launcher_icons`
- [x] `.gitignore` con `android/key.properties`, `*.jks`, `*.keystore`
- [x] Firma release da `key.properties` con fallback debug

**Checkpoint:** `flutter analyze` pulito, `flutter build apk --debug` ok – ✅ verificato il 2026-11-12

### M1 – Configurazione e rete

- [x] `app_config.dart` con token copiato da `src/js/constants.js`
- [x] `ApiClient` (dio, timeout, interceptor `Authorization`)
- [x] `AppException` (sealed) e conversione degli errori dio
- [x] `fetchAllPages` + `yearQuery`
- [x] `DateOnly`

**Checkpoint:** una lista dell'anno torna dal backend – ✅ verificato il 2026-11-12 (GET 2025: 128 attività, 85 masturbazioni; scoperto che il backend ignora `sort` e `pageSize`, vedi `docs/knowledge/backend-api.md`)

### M2 – Modelli e repository

- [x] `SexualActivity`, `Masturbation`, `CumshotZone`, `Practice`, `PartnerProfile`, `Gender`, `Partner` (freezed)
- [x] DTO con null → 0, 0/1 → bool, `DateOnly`
- [x] Body `{ "data": { ... } }` con booleani veri
- [x] `ActivitiesRepository`, `MasturbationsRepository` (`listForYear`, `create`, `update`, `delete`), ordinamento locale su copia
- [x] `stats_models.dart`, `stats_calculator.dart` (funzioni pure)

**Checkpoint:** statistiche coerenti con le liste – ✅ verificato il 2026-11-12 sull'emulatore (Home 2026: 69 scopate su 98 attività; totali per partner = attività + masturbazioni, es. partner 1: 97 + 42 = 139)

### M3 – Profilo e stato

- [x] `ProfileStore` con lettura tollerante
- [x] `profileProvider`, `isOnboardedProvider`, `requireProfileProvider`
- [x] `yearProvider` persistito e limitato (B6), `themeModeProvider`
- [x] `activitiesProvider(year)`, `masturbationsProvider(year)` con `add` / `edit` / `remove`
- [x] Provider derivati e `yearlyProvider` con max 5 richieste parallele

**Checkpoint:** cambio anno senza riavvio; profilo letto/scritto – ✅ profilo verificato sull'emulatore (onboarding → riavvio → Home). Cambio anno: ⬜ da verificare a mano

### M4 – Shell, navigazione e tema

- [x] `MaterialApp.router`, locale `it_IT`, tema chiaro/scuro da preferenza
- [x] `theme.dart` (seed `#E4572E`, `AppColors`, ritorno predittivo)
- [x] `router.dart` con `StatefulShellRoute`, route dei form fuori shell, redirect onboarding
- [x] `shell_scaffold.dart` con `NavigationBar` e back verso Home

**Checkpoint:** profilo vuoto → onboarding; profilo completo → cinque destinazioni – ✅ verificato il 2026-11-12

### M5 – Onboarding e schermate

- [x] `OnboardingScreen`
- [x] `HomeScreen` con pull-to-refresh
- [x] Liste raggruppate per mese, stato vuoto, FAB
- [x] `ActivityFormScreen`, `MasturbationFormScreen` (salva, cancella con conferma, SnackBar, `FormBusy`)
- [x] `SettingsScreen` (partner, anno, tema, versione)
- [x] `AsyncBody` ovunque

**Checkpoint:** onboarding, inserimento/modifica/cancellazione, valori in Home e liste – 🟡 parziale: onboarding, Home, liste e form precompilato in modifica verificati sull'emulatore. **Salvataggio e cancellazione NON provati** per non scrivere sui dati reali del backend: ⬜ da verificare a mano (vedi `docs/features/activities.md` e `masturbations.md`)

### M6 – Statistiche e grafici

- [x] `StatsScreen` con due tab e `YearSelector`
- [x] Card di riepilogo e rapporti D/A con "—"
- [x] Orgasmi per mese, rapporto D/A per mese, sborrate per zona (12), pratiche, calendario, confronto anni
- [x] Tab masturbazioni con etichetta per sesso e ciambella
- [x] `Semantics` per ogni grafico
- [x] Caricamento del confronto anni

**Checkpoint:** grafici con i dati dell'anno; 12 zone nel grafico sborrate – ✅ verificato il 2026-11-12 (corretti in corsa: etichetta spuria in cima all'asse Y, separatore decimale italiano, mesi futuri dell'anno corrente non più disegnati a 0)

### M7 – Rifinitura

- [x] Edge-to-edge e status bar che segue il tema
- [x] Back Android: dialoghi prima, poi navigazione; dai tab verso Home
- [x] Layout con testo ingrandito – ✅ verificato sull'emulatore (font scale 2.0) dopo il redesign UI
- [x] Icona adattiva e splash nativa
- [x] Nessun log di debug nel codice

**Checkpoint:** `flutter analyze` senza issue, nessun `print` – ✅ verificato il 2026-11-12; tema scuro con icone chiare verificato sull'emulatore

### M8 – Build

- [x] `flutter build appbundle --release` compila (firma debug di fallback, AAB ~60 MB)
- [ ] Installare `cmdline-tools` dell'Android SDK e accettare le licenze: senza, Flutter avvisa "failed to strip debug symbols from native libraries" (AAB più grande del necessario) – ⬜ azione sulla macchina di sviluppo
- [ ] Build firmata con il keystore di release (`android/key.properties`) – ⬜ richiede il keystore del proprietario
- [ ] Installazione su dispositivo reale e giro completo dei flussi – ⬜
- [ ] `versionCode` maggiore dell'ultimo caricato sul Play Store – ⬜ da verificare

**Checkpoint:** AAB firmato installato e flussi percorsi – ⬜ non verificato

### Documentazione

- [x] `AGENTS.md` (+ `CLAUDE.md` che lo importa)
- [x] `docs/features/*.md` (8 file)
- [x] `docs/knowledge/*.md` (architettura, API, bug, decisioni, ambiente)
- [x] `docs/README.md`
- [x] `README.md`

**Checkpoint:** documentazione coerente con il codice – ✅ 2026-11-12

## Bug B1–B14

Tutti risolti nel codice: dettaglio e file in `docs/knowledge/bugfixes.md`.

## Deviazioni dalla specifica

Vedi `docs/knowledge/decisions.md` (Flutter 3.47.1 invece di 3.50, niente riverpod_generator/json_serializable, `StatefulShellRoute`, metodi `edit`/`remove`, barre orizzontali custom, ecc.).

## Rischi / punti aperti

- `versionCode` del Play Store sconosciuto.
- Flussi di scrittura (POST/PUT/DELETE) non ancora provati contro il backend reale.
- `minSdk 24` da confermare con Play Console.

## Log di avanzamento

| Data | Cosa | Verifica | Prossimo passo |
| --- | --- | --- | --- |
| 2026-11-12 | M0–M7 implementati, documentazione scritta | `flutter analyze` 0 issue; `flutter build apk --debug` ok; GET reali sul backend; app provata su emulatore API 35 (onboarding, Home, liste, statistiche, form in modifica, impostazioni in tema scuro); corretti tre difetti dei grafici | Provare salvataggio/cancellazione su un record di prova, testo al 200%, installare cmdline-tools, build firmata (M8) |
| 2026-11-12 | UI rifatta da capo (piano `2026-11-12-ui-redesign.md`) | Vedi quel piano | — |
| 2026-11-12 | M8 parziale | `flutter build appbundle --release` ok con firma debug; avviso strip simboli dovuto a `cmdline-tools` mancanti (`flutter doctor`) | Keystore di release e versionCode |
