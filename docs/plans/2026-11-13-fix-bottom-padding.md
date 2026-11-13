# Piano: Padding in fondo alle pagine sotto la barra flottante

- **Stato:** ✅ Completato
- **Inizio:** 2026-11-13
- **Ultimo aggiornamento:** 2026-11-13
- **Feature doc:** `docs/features/app-shell-theme.md`
- **Avanzamento:** 2/2 step

## Obiettivo

Scorrendo una pagina dei tab fino in fondo, l'ultimo elemento si ferma sopra la barra flottante (nessun contenuto nascosto o non cliccabile sotto la barra).

## Ambito

- In ambito: causa del padding mancante in `ShellScaffold`, verifica della misura, documentazione.
- Fuori ambito: `AppPage` e le singole schermate (il loro padding era già corretto), tablet/rail, form.

## File coinvolti

- `lib/app/shell_scaffold.dart` – modificato
- `docs/features/app-shell-theme.md`
- `docs/knowledge/bugfixes.md`
- `docs/knowledge/design-system.md`
- `docs/README.md`
- `docs/plans/2026-11-13-fix-bottom-padding.md`

## Step

### Step 1 – Causa e correzione

- [x] Riprodurre il problema misurando la posizione dell'ultimo elemento rispetto alla barra.
- [x] Individuare la causa: `MediaQuery.removePadding(context: context, …)` in `ShellScaffold.build` usa il `context` sopra lo `Scaffold`, quindi sovrascrive il `MediaQuery` del body che contiene l'altezza della barra (`extendBody`).
- [x] Avvolgere la chiamata in un `Builder` per usare il `context` interno al body.
- [x] `dart format .` e `flutter analyze` senza issue.

**Checkpoint:** ✅ verificato il 2026-11-13: test widget temporaneo (poi rimosso, il progetto non ha test) con shell reale e `AppPage` di 40 elementi su finestra 360×800 dp con inset di sistema 24 dp in basso. Prima: `padding.bottom` 24, ultimo elemento a 752 dp, barra a 712 dp (39 dp coperti). Dopo: `padding.bottom` 88, ultimo elemento a 688 dp, 24 dp sopra la barra. `flutter analyze`: zero issue.

### Step finale – Documentazione

- [x] `docs/features/app-shell-theme.md` aggiornato
- [x] `docs/knowledge/bugfixes.md` e `design-system.md` aggiornati
- [x] `docs/README.md` aggiornato
- [x] `README.md`: non serve, nessuna istruzione operativa cambia

**Checkpoint:** ✅ verificato il 2026-11-13: documentazione coerente con il codice.

## Deviazioni dalla specifica

| Punto | Specifica | Scelta | Motivo |
| --- | --- | --- | --- |
| Piano prima del codice | Il piano si crea prima di scrivere codice | Creato dopo la correzione | La causa è emersa solo riproducendo il problema; la modifica è di poche righe |

## Rischi / punti aperti

- Regressione introdotta dal commit "Add adaptive tablet layouts" (`removePadding` aggiunto per la rail).
- Non verificato su dispositivo o emulatore Android (nessuno collegato): verifica fatta con un test di layout. Da controllare a mano sul telefono: scorrere fino in fondo Home, Attività, Masturbazioni, Statistiche, Impostazioni.

## Log di avanzamento

| Data | Cosa | Verifica | Prossimo passo |
| --- | --- | --- | --- |
| 2026-11-13 | Riprodotto il bug, trovata la causa, aggiunto il `Builder` in `ShellScaffold`; documentazione aggiornata | Misura prima/dopo con test temporaneo rimosso; `flutter analyze` pulito | Prova manuale sul telefono; nessun commit richiesto |
