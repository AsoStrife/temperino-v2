# Temperino

App Android (Flutter, Material 3) per registrare attività sessuali e masturbazioni di due partner, con statistiche e grafici. Usa lo stesso backend Strapi della vecchia app Vue/Capacitor (`../temperino-fe`), senza modificarlo.

- Specifica: [`migration-flutter.md`](migration-flutter.md)
- Regole per chi sviluppa (persone e agenti): [`AGENTS.md`](AGENTS.md)
- Documentazione: [`docs/`](docs/README.md)

## Requisiti

| Strumento | Versione usata | Note |
| --- | --- | --- |
| Flutter | 3.47.1 stable (Dart 3.13.1) | `flutter --version`. La specifica indica 3.50: vedi "Aggiornare Flutter". |
| JDK | 17 o superiore (usato 21) | |
| Android SDK | Platform 36, build-tools recenti | Gradle scarica i pacchetti mancanti al primo build. |
| Dispositivo | Android 7.0+ (API 24) | Emulatore o telefono con debug USB. |

Verifica l'ambiente con `flutter doctor`.

## Primo avvio

```bash
flutter pub get
flutter run                  # sceglie emulatore/dispositivo collegato
```

Al primo avvio l'app chiede nomi e sesso dei due partner (salvati solo sul dispositivo).

Il codice generato da `freezed` (`*.freezed.dart`) è versionato: non serve lanciare `build_runner` dopo il clone.

## Debug live su emulatore (hot reload)

```bash
flutter emulators                                   # elenca gli emulatori disponibili
flutter emulators --launch Medium_Phone_API_35      # avvia l'emulatore (id dall'elenco sopra)
flutter devices                                     # attendi che compaia "emulator-5554"
flutter run -d emulator-5554                        # build debug, installa e avvia con hot reload
```

Mentre `flutter run` è attivo, nel terminale:

| Tasto | Effetto |
| --- | --- |
| `r` | Hot reload (applica le modifiche al codice mantenendo lo stato) |
| `R` | Hot restart (riavvia l'app da zero) |
| `d` | Stacca il terminale lasciando l'app in esecuzione |
| `q` | Chiude l'app e termina |

Il primo avvio in debug sull'emulatore richiede qualche secondo (splash prolungata): è normale.

Comandi utili con `adb` (in `%LOCALAPPDATA%\Android\Sdk\platform-tools`):

```bash
adb shell pm clear com.strifelab.temperino          # azzera i dati: riparte dall'onboarding
adb shell "cmd uimode night yes"                     # tema scuro di sistema (no = chiaro)
adb shell settings put system font_scale 2.0         # testo ingrandito (1.0 = normale)
adb emu kill                                         # spegne l'emulatore
```

Se manca un emulatore, crealo da Android Studio → Device Manager (immagine con API 35 o 36).

### Emulatore tablet (Xiaomi Pad 7)

Per provare i layout tablet c'è l'AVD `Pad7_API_35`: 2136 × 3200 px a 320 dpi (= 1068 × 1600 dp, come il Pad 7). È stato creato a mano in `%USERPROFILE%\.android\avd\` (`Pad7_API_35.ini` + `Pad7_API_35.avd\config.ini`, copia della configurazione del telefono con `hw.lcd.width = 2136`, `hw.lcd.height = 3200`, `hw.lcd.density = 320`), perché senza `cmdline-tools` non c'è `avdmanager`. In alternativa: Android Studio → Device Manager → "Pixel Tablet".

```bash
flutter emulators --launch Pad7_API_35
flutter run -d emulator-5556                         # l'id dipende dagli emulatori già accesi
adb -s emulator-5556 shell settings put system accelerometer_rotation 0
adb -s emulator-5556 shell settings put system user_rotation 1   # orizzontale (0 = verticale)
```

Ogni modifica visiva va provata sul tablet in verticale **e** orizzontale, oltre che sul telefono (regole in `docs/knowledge/design-system.md` § "Schermi grandi").

## Configurazione

Tutto ciò che è fisso (URL del backend, token, endpoint, parametri di query, etichette, chiavi delle preferenze) è in **`lib/core/config/app_config.dart`**. Per puntare a un altro backend si modifica quel file; non ci sono variabili d'ambiente né `--dart-define`.

## Comandi di sviluppo

```bash
dart format .                        # formattazione (obbligatoria prima di chiudere un lavoro)
flutter analyze                      # deve dare "No issues found!"
dart run build_runner build          # dopo aver modificato un modello @freezed
dart run build_runner watch          # rigenerazione continua durante lo sviluppo
```

Non ci sono test automatici per scelta di progetto: la verifica è `flutter analyze` più prova manuale (i flussi da provare sono nelle sezioni "Verifica manuale" di `docs/features/*.md`).

## Build

### Debug

```bash
flutter build apk --debug
# output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release (Play Store)

1. Metti il keystore di release **fuori dal repository** (es. `C:\keys\temperino.jks`).
2. Crea `android/key.properties` (è in `.gitignore`, non va mai committato):

   ```properties
   storePassword=<password del keystore>
   keyPassword=<password della chiave>
   keyAlias=<alias>
   storeFile=C:/keys/temperino.jks
   ```

   Per creare un nuovo keystore (solo per un'app nuova; per aggiornare quella esistente serve il keystore originale o la Play App Signing upload key):

   ```bash
   keytool -genkey -v -keystore C:/keys/temperino.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

3. Aggiorna la versione (vedi sotto).
4. Genera il bundle:

   ```bash
   flutter build appbundle --release
   # output: build/app/outputs/bundle/release/app-release.aab
   ```

   Per un APK installabile a mano: `flutter build apk --release`.

Senza `android/key.properties` la build release viene firmata con la chiave di debug (utile per provarla in locale, **non** caricabile sul Play Store).

L'`applicationId` è `com.strifelab.temperino`, lo stesso della vecchia app: il bundle aggiorna l'app esistente sul Play Store se firmato con la chiave giusta.

## Versione dell'app

La versione è in due posti, da tenere allineati:

| Dove | Esempio | Significato |
| --- | --- | --- |
| `pubspec.yaml` → `version:` | `2.0.0+1` | `versionName+versionCode` usati da Android |
| `lib/core/config/app_config.dart` → `appVersion` | `'2.0.0'` | Versione mostrata in Impostazioni |

Il `versionCode` (numero dopo il `+`) deve crescere a ogni upload e deve essere **maggiore dell'ultimo caricato dalla vecchia app Capacitor** (controllalo in Play Console prima del primo rilascio).

Si può anche forzare da riga di comando: `flutter build appbundle --build-name=1.2.1 --build-number=5`.

## Icona e splash

- Sorgente: `assets-src/web-icon.png` (512×512, quadrato pieno con sfondo azzurro).
- Configurazione in `pubspec.yaml`, sezioni `flutter_launcher_icons` e `flutter_native_splash`.

```bash
dart run flutter_launcher_icons          # rigenera mipmap e icona adattiva
dart run flutter_native_splash:create    # rigenera la splash (Android < 12 e 12+)
```

Per cambiare icona: sostituisci `assets-src/web-icon.png` (stesse dimensioni consigliate), aggiorna se serve `adaptive_icon_background` (colore del bordo dell'immagine) e rilancia i due comandi. Dopo la rigenerazione disinstalla l'app dall'emulatore per vedere la nuova icona (il launcher la mette in cache).

Le immagini degli avatar (`assets/images/temperinoA.jpg`, `temperinoD.jpg`) e della Home (`sexual-activities.jpg`) vengono da `temperino-fe/public/icons/`.

## Librerie e aggiornamenti

Dipendenze principali (vincoli completi in `pubspec.yaml`, versioni risolte in `pubspec.lock`, tabella in [`docs/knowledge/environment.md`](docs/knowledge/environment.md)):

| Pacchetto | Uso |
| --- | --- |
| `flutter_riverpod` | Stato |
| `go_router` | Navigazione |
| `dio` | HTTP |
| `freezed` / `freezed_annotation` | Modelli immutabili |
| `fl_chart` | Grafici |
| `shared_preferences` | Anno, tema, profilo |
| `intl`, `flutter_localizations` | Italiano |
| `flutter_launcher_icons`, `flutter_native_splash` | Icona e splash |

Aggiornare le librerie:

```bash
flutter pub outdated                 # cosa è aggiornabile
flutter pub upgrade                  # aggiorna entro i vincoli di pubspec.yaml
flutter pub upgrade --major-versions # aggiorna anche le major (poi controlla i changelog)
dart run build_runner build          # se è cambiato freezed
dart format . && flutter analyze
flutter run                          # prova manuale dei flussi principali
```

Dopo ogni aggiornamento aggiorna la tabella in `docs/knowledge/environment.md`. `intl` è fissato dalla versione di `flutter_localizations` inclusa nell'SDK: si aggiorna insieme a Flutter.

## Aggiornare Flutter

```bash
flutter upgrade
flutter --version
flutter pub upgrade
dart run build_runner build
flutter analyze
```

Se cambia la versione minima di Dart, aggiorna `environment.sdk` in `pubspec.yaml`. Aggiorna anche `docs/knowledge/environment.md`.

## Problemi noti

- **"Release app bundle failed to strip debug symbols from native libraries"**: manca il componente *Android SDK Command-line Tools*. Installalo da Android Studio → SDK Manager → SDK Tools → "Android SDK Command-line Tools (latest)", poi `flutter doctor --android-licenses`. `flutter doctor` non deve più segnalare problemi nella sezione Android toolchain.
- **Icona non aggiornata sull'emulatore**: disinstalla l'app e reinstallala.

## Android: parametri principali

| Parametro | Valore | File |
| --- | --- | --- |
| `applicationId` / `namespace` | `com.strifelab.temperino` | `android/app/build.gradle.kts` |
| `minSdk` | 24 | idem |
| `targetSdk` | 36 (minimo richiesto da Google Play) | idem |
| `compileSdk` | ≥ 36 | idem |
| Permessi | solo `INTERNET`, niente HTTP in chiaro | `android/app/src/main/AndroidManifest.xml` |
| Ritorno predittivo | abilitato | idem |

## Struttura

```
lib/
  main.dart
  app/            tema, router, shell con barra inferiore
  core/           config, rete, errori, storage, utilità
  features/       onboarding, profile, home, activities, masturbations, stats, settings
  shared/widgets/ widget riusabili
assets/images/    avatar e immagini
assets-src/       sorgente dell'icona
docs/             feature, knowledge, piani
```

Dettagli in [`docs/knowledge/architecture.md`](docs/knowledge/architecture.md).
