# Feature: Shell, navigazione, tema e status bar

Token, componenti e regole visive: `docs/knowledge/design-system.md`.

## Navigazione

- `go_router` con `StatefulShellRoute.indexedStack`: cinque rami (Home `/`, Attività `/activities`, Masturbazioni `/masturbations`, Statistiche `/stats`, Impostazioni `/settings`), ognuno conserva il proprio stato.
- **Barra flottante a pillola** (`ShellScaffold`): cinque icone (outline → piena con cerchio tonale quando selezionata), etichette in tooltip e semantica, sfondo semitrasparente con sfocatura, ombra morbida. Il contenuto scorre sotto (`extendBody`).
- **Pulsante "+"** circolare con gradiente accanto alla barra: sul tab Attività apre il form attività, sul tab Masturbazioni il form masturbazione, altrove un foglio "Cosa aggiungi?" con le due opzioni.
- **Tablet**: barra centrata (max 560 dp) da 600 dp; con finestra ≥ 840 dp, orizzontale e alta almeno 480 dp, **rail verticale flottante a destra** con il "+" sotto. In verticale la barra resta in basso. SnackBar larghe 480 dp e centrate da 600 dp. Dettagli in `tablet-layout.md`.
- Ritoccare il tab attivo riporta alla radice del tab.
- Form a tutto schermo fuori dalla shell, aperti come fullscreen dialog (icona X): `/activities/new`, `/activities/:id`, `/masturbations/new`, `/masturbations/:id`.
- Redirect: profilo incompleto → `/onboarding`; profilo completo e `/onboarding` → `/`.
- Costanti di route in `Routes` (`lib/app/router.dart`).

## Tasto indietro Android

- Dialoghi, fogli e DatePicker si chiudono per primi.
- Nei form: se ci sono modifiche non salvate chiede conferma ("Uscire senza salvare?"), altrimenti chiude.
- Su un tab diverso da Home: va a Home (`PopScope` in `ShellScaffold`); da Home esce dall'app.
- Ritorno predittivo: `android:enableOnBackInvokedCallback="true"` + `PredictiveBackPageTransitionsBuilder`.

## Tema

- `ColorScheme.fromSeed(#E5304D)` con superfici, primary e testo sostituiti da valori neutri ad alto contrasto (`AppTheme._scheme`).
- Token di ruolo in `AppColors` (ThemeExtension) letti con `context.appColors`; tabella completa in `design-system.md`.
- Componenti Material ristilizzati nel tema: bottoni a pillola, chip senza bordo, segmented a pillola, campi riempiti senza bordo, snackbar flottanti arrotondate, dialog e fogli con raggio 28, switch senza contorno.
- Font di sistema con pesi 700–800 e tracking stretto sui titoli, cifre tabulari sui numeri.
- Locale `it_IT`.

## Status bar ed edge-to-edge

- `SystemUiMode.edgeToEdge` in `main`.
- Status bar e barra di sistema trasparenti; icone scure su tema chiaro e chiare su tema scuro (`systemOverlayFor`), applicate in `MaterialApp.builder` e in `AppBarTheme.systemOverlayStyle`.

## Icona e splash

- Icona da `assets-src/web-icon.png` con `flutter_launcher_icons` (adattiva, sfondo `#33BEF9`).
- Splash nativa con `flutter_native_splash`.

## File

- `lib/app/app.dart`, `router.dart`, `shell_scaffold.dart`, `theme.dart`, `lib/main.dart`, `lib/shared/widgets/adaptive.dart`
- `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`

## Verifica manuale

1. Le cinque destinazioni funzionano e mantengono lo scroll. ✅ emulatore 12/11/2026.
2. "+" contestuale (form attività dal tab Attività, foglio dalla Home). ✅
3. Back da Statistiche → Home → uscita.
4. Tema scuro di sistema → app scura, icone status bar chiare. ✅
5. Testo di sistema ingrandito → nessun overflow; la griglia delle pratiche passa a 2 colonne. ✅ (font scale 2.0 sull'emulatore)
6. Tablet: barra centrata in verticale, rail in orizzontale, rotazione senza perdita di stato. ✅ emulatore `Pad7_API_35` 13/11/2026.
7. Rail spostata a destra solo in orizzontale: Home e Statistiche sul tablet, barra in basso in verticale con tab conservato; temi chiaro e scuro. Home sul telefono invariata in entrambi i temi. ✅ emulatori `Pad7_API_35` e `Medium_Phone_API_35`, 13/11/2026; `flutter analyze` senza issue. Dettagli in `tablet-layout.md`.
