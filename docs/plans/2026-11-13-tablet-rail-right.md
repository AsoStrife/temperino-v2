# Piano: Barra tablet a destra in orizzontale

- **Stato:** ✅ Completato
- **Inizio:** 2026-11-13
- **Ultimo aggiornamento:** 2026-11-13
- **Feature doc:** `docs/features/tablet-layout.md`, `docs/features/app-shell-theme.md`
- **Avanzamento:** 2/2 step

## Obiettivo

Spostare a destra la rail del tablet in orizzontale, con il pulsante "+" sotto. In verticale la barra resta in basso; telefono e condizioni di attivazione della rail restano invariati.

## Ambito

- In ambito: posizione della rail, inset di sistema, conservazione dello stato in rotazione, documentazione.
- Fuori ambito: breakpoint, orientamenti di attivazione, pagine, form, backend.

## File coinvolti

- `lib/app/shell_scaffold.dart`
- `docs/features/tablet-layout.md`
- `docs/features/app-shell-theme.md`
- `docs/knowledge/design-system.md`
- `docs/knowledge/architecture.md`
- `docs/knowledge/tablet-usability.md`
- `docs/README.md`
- `docs/plans/2026-11-13-tablet-rail-right.md`

## Step

### Step 1 – Posizione e verifica

- [x] Inserire la rail dopo il contenuto, senza cambiare i wrapper del navigator.
- [x] Specchiare margini e gestione degli inset di sistema.
- [x] `dart format .` e `flutter analyze` senza issue.
- [x] Verifica manuale: tablet verticale/orizzontale, chiaro/scuro, rotazione con tab aperto; telefono invariato.

**Checkpoint:** ✅ verificato il 2026-11-13: `flutter analyze` senza issue; `flutter run -d emulator-5554` su `Pad7_API_35`, rail a destra solo in orizzontale; Statistiche conservate ruotando in verticale, barra in basso; entrambi i temi. APK debug installato su `Medium_Phone_API_35`, Home con barra in basso invariata in chiaro e scuro.

### Step 2 – Documentazione

- [x] Aggiornare feature, design system, architettura e decisione di usabilità.
- [x] Aggiornare l'indice con questo piano.
- [x] Registrare verifiche, eventuali limiti e chiudere il piano.
- [x] Verificare se serve aggiornare `README.md`: non necessario, nessuna istruzione operativa cambia.

**Checkpoint:** ✅ verificato il 2026-11-13: documentazione corrente coerente con lato destro, soli orientamenti orizzontali e gestione degli inset; verifiche riportate nelle feature e nel piano.

## Deviazioni dalla specifica

| Punto | Specifica | Scelta | Motivo |
| --- | --- | --- | --- |
| Lato della rail | Sinistra | Destra, solo in orizzontale | Richiesta esplicita dell'utente |

## Rischi / punti aperti

- Nessun punto aperto per la modifica. Dispositivo reale non verificato; verifica svolta sugli emulatori tablet e telefono.

## Log di avanzamento

| Data | Cosa | Verifica | Prossimo passo |
| --- | --- | --- | --- |
| 2026-11-13 | Letti regole, feature e knowledge; chiarito che cambia solo il lato della rail in orizzontale | Working tree pulito; nessuna modifica al codice precedente al piano | Spostare la rail e verificare |
| 2026-11-13 | Rail spostata dopo il contenuto, inset specchiati; documentazione aggiornata | `dart format .`: 69 file, nessuna variazione; `flutter analyze`: zero issue | Verifica visiva sull'emulatore tablet avviato |
| 2026-11-13 | Completate verifiche visive e documentazione; nessuna modifica ai breakpoint | Tablet orizzontale/verticale e telefono, chiaro/scuro; tab Statistiche conservato in rotazione | Completato; nessun commit richiesto |
