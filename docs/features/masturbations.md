# Feature: Masturbazioni (lista e form)

Stile e componenti: `docs/knowledge/design-system.md`.

## Lista – `/masturbations`

- Titolo grande "Masturbazioni" + pillola anno.
- Pillole di riepilogo: "N totali" e una per partner ("Andrea 42") nel colore del partner.
- Gruppi per mese in contenitori arrotondati.
- Riga: giorno, avatar del partner, nome nel colore del partner, pillola "Giocattoli" se `toys`, bolla con il numero di orgasmi.
- Tap → modifica; swipe a sinistra → cancella con conferma; "+" accanto alla barra apre direttamente il form masturbazione.
- Vuoto: "Non sono presenti masturbazioni" con "Aggiungi masturbazione". Pull-to-refresh. Errore con "Riprova".

## Form – `/masturbations/new`, `/masturbations/:id`

Fullscreen dialog. Blocchi:

1. **Chi** – due grandi tile con avatar e nome; quella selezionata ha sfondo tonale e bordo nel colore del partner e un segno di spunta. Default partner 1.
2. **Quando** – `DateQuickPicker` (Oggi / Ieri / Altro giorno), niente date future.
3. **Dettagli** – `ToggleTile` "Giocattoli" (default off, inviato sempre come booleano, B12) e `BigCounter` "Orgasmi" nel colore del partner scelto.

Salva (barra fissa in basso), Cancella (cestino nell'app bar), conferma di uscita con modifiche, SnackBar di successo e di errore (B8), stato unico `FormBusy` (B7): come il form attività.

## Dati e stato

- Modello `Masturbation` (`who: Partner`, `toys`, `orgasms`, `date: DateOnly`).
- `masturbationsProvider(year)`: `add`, `edit`, `remove`, stessa invalidazione delle attività.

## File

- `lib/features/masturbations/domain/masturbation.dart`
- `lib/features/masturbations/data/masturbation_dto.dart`, `masturbations_repository.dart`
- `lib/features/masturbations/presentation/masturbations_providers.dart`, `masturbations_list_screen.dart`, `masturbation_form_screen.dart`

## Verifica manuale

1. Form nuovo dal "+" nel tab Masturbazioni. ✅ emulatore 12/11/2026.
2. Nuova masturbazione per il partner 2 con giocattoli → in lista con avatar rosa e pillola "Giocattoli". ⬜ (scrittura non provata)
3. Errore di rete in salvataggio → SnackBar con messaggio. ⬜
