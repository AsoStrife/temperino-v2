# Ambiente, toolchain e versioni

Ultimo aggiornamento: 12 novembre 2026.

## Toolchain usata per lo sviluppo

| Strumento | Versione |
| --- | --- |
| Flutter | 3.47.1 (stable) |
| Dart | 3.13.1 |
| JDK | Temurin 21 |
| Gradle wrapper | 9.3.1 |
| Android Gradle Plugin | 9.1.0 |
| Kotlin Gradle Plugin | 2.4.0 |

Stato della macchina al 12/11/2026: `flutter doctor` segnala **cmdline-tools mancanti** e licenze non accettate; il build funziona ma l'AAB di release non viene ripulito dai simboli di debug (vedi README, "Problemi noti").

La specifica indica Flutter 3.50 (uscita l'11 novembre 2026). Vedi `decisions.md` per come aggiornare.

## Android

| Parametro | Valore | Dove |
| --- | --- | --- |
| `applicationId` / `namespace` | `com.strifelab.temperino` | `android/app/build.gradle.kts` |
| `minSdk` | 24 | idem |
| `targetSdk` | 36 (requisito Google Play da agosto 2026) | idem |
| `compileSdk` | `max(flutter.compileSdkVersion, 36)` | idem |
| Permessi | `INTERNET` | `AndroidManifest.xml` |
| Cleartext | disabilitato | idem |
| Ritorno predittivo | `enableOnBackInvokedCallback="true"` | idem |

## Dipendenze (vincoli in `pubspec.yaml`)

| Pacchetto | Vincolo | Uso |
| --- | --- | --- |
| `flutter_riverpod` | ^3.5.0 | Stato |
| `go_router` | ^18.1.4 | Navigazione |
| `dio` | ^5.11.1 | HTTP |
| `freezed_annotation` | ^3.1.0 | Modelli |
| `fl_chart` | ^1.3.1 | Grafici |
| `shared_preferences` | ^2.5.6 | Anno, tema, profilo |
| `intl` | ^0.20.3 (fissato da `flutter_localizations`) | Date e numeri in italiano |
| `flutter_localizations` | SDK | Localizzazione Material |
| dev: `freezed` | ^4.0.3 | Codegen |
| dev: `build_runner` | ^2.17.1 | Codegen (l'opzione `-d` non esiste più) |
| dev: `flutter_launcher_icons` | ^0.14.4 | Icone |
| dev: `flutter_native_splash` | ^2.4.8 | Splash |
| dev: `flutter_lints` | ^6.0.0 | Lint |

Le versioni esatte risolte sono in `pubspec.lock` (versionato).
