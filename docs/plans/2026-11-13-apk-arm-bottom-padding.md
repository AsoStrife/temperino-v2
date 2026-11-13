# Piano: Aggiornamento APK ARM dopo il fix del padding

- **Stato:** ✅ Completato
- **Inizio:** 2026-11-13
- **Ultimo aggiornamento:** 2026-11-13
- **Feature doc:** `docs/features/app-shell-theme.md` (nessuna modifica funzionale)
- **Avanzamento:** 2/2 step

## Obiettivo

Rigenerare gli APK release ARM (32 e 64 bit, combinato e split) con il fix del padding in fondo alle pagine (`docs/plans/2026-11-13-fix-bottom-padding.md`).

## Ambito

- In ambito: build e verifica degli artefatti.
- Fuori ambito: modifiche al codice, incremento versione (resta `2.0.0+1`), nuova firma, pubblicazione.

## File coinvolti

- `build/app/outputs/flutter-apk/*.apk` – artefatti generati, non versionati.
- `docs/README.md`, `docs/plans/2026-11-13-apk-arm-bottom-padding.md`.

## Step

### Step 1 – Build e verifica

- [x] `dart format .` e `flutter analyze` senza issue.
- [x] `flutter build apk --release --target-platform android-arm,android-arm64`.
- [x] `flutter build apk --release --target-platform android-arm,android-arm64 --split-per-abi`.
- [x] Verificare data/dimensione, ABI e firma degli APK.

**Checkpoint:** ✅ verificato il 2026-11-13: `dart format .` e `flutter analyze` senza issue; build combinata e split riuscite. `aapt dump badging`: `versionName=2.0.0`; ABI `arm64-v8a` (versionCode 2001) e `armeabi-v7a` (1001) isolate negli split, combinato con `arm64-v8a`, `armeabi-v7a` e `x86_64` di dipendenze (versionCode 1). `apksigner verify`: firma v2 valida, Android Debug, per tutti e tre. `app.so` ricompilato alle 18:12, dopo la modifica a `shell_scaffold.dart` (17:08). Dimensioni: ARM64 23.538.697 byte, ARM32 21.242.229, combinato 41.060.795 (uguali alla build precedente: la differenza di codice è di pochi byte, assorbita dall'allineamento delle librerie nello zip).

### Step 2 – Documentazione

- [x] Indice aggiornato; `README.md` invariato (i comandi non cambiano).

**Checkpoint:** ✅ verificato il 2026-11-13: indice aggiornato, nessun comando cambiato nel `README.md`.

## Deviazioni dalla specifica

Nessuna.

## Rischi / punti aperti

- Nessun dispositivo ARM collegato: gli APK non vengono eseguiti.

## Log di avanzamento

| Data | Cosa | Verifica | Prossimo passo |
| --- | --- | --- | --- |
| 2026-11-13 | Piano creato | — | Build |
| 2026-11-13 | Build combinata e split generate e verificate; piano chiuso | ABI, versione e firma con `aapt`/`apksigner`; nessuna esecuzione su dispositivo ARM | Completato; nessun commit richiesto |
