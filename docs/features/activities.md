# Feature: Attività sessuali (lista e form)

Stile e componenti: `docs/knowledge/design-system.md`.

## Lista – `/activities`

- Nessun titolo (la pagina è indicata dalla barra in basso); nella barra sottile in alto a destra il selettore **Lista / Calendario** (`ListLayoutToggle`) e la pillola anno. La vista calendario è descritta in `calendar-view.md`.
- Pillole di riepilogo: "N attività", "N scopate", "N anal".
- Gruppi per mese ("Novembre 2026" + numero di elementi), ciascuno in un contenitore arrotondato con righe separate da divisori.
- Riga: giorno e giorno della settimana a sinistra; pillola "Scopata" (rosso) e "Anal" se attivi, altre pratiche come testo ("Pompino · Leccata"), zona della sborrata con icona goccia ("Nessuna sborrata" se `none`); a destra due bolle con gli orgasmi del partner 1 (celeste) e 2 (rosa). TalkBack legge tutto con i nomi del profilo.
- Tap → modifica (`/activities/:id?year=AAAA`). **Swipe a sinistra → cancella** (con dialogo di conferma); la riga sparisce subito e torna se la richiesta fallisce (SnackBar di errore).
- Nuovo inserimento: pulsante "+" accanto alla barra di navigazione (su questo tab apre direttamente il form attività).
- Vuoto: "Non sono presenti attività sessuali" con pulsante "Aggiungi attività". Pull-to-refresh. Errore con "Riprova".

## Form – `/activities/new`, `/activities/:id`

Pagina a schermo intero aperta come "fullscreen dialog" (icona X). Blocchi in ordine:

1. **Quando** – `DateQuickPicker`: data estesa ("Giovedì 12 novembre 2026") e chip "Oggi", "Ieri", "Altro giorno" (DatePicker Material 3, niente date future). Default oggi.
2. **Com'è andata** – `ToggleTile` "Sesso" (il dato principale, tutta la tile è toccabile), poi `SelectableGrid` con le altre sei pratiche (Pompino, Sega, Anal, Ditalino, Leccata, Spagnola) come tile con icona e segno di spunta. Etichette da `AppConfig.practiceLabels` (B14).
3. **Orgasmi** – due `BigCounter` affiancati, uno per partner con avatar e nome, numero grande e pulsanti − / +.
4. **Zona della sborrata** – `ChoiceChipsWrap` con le 12 zone, "Niente (no sborrata)" per prima e selezionata di default.

Azioni:

- **Salva** nella `SaveBar` fissa in basso ("Salva attività" / "Salva modifiche"), con indicatore di caricamento. SnackBar "Attività salvata" e chiusura; errore → SnackBar "Salvataggio non riuscito: …" (B8) e si resta nel form.
- **Cancella** (solo modifica): icona cestino nell'app bar, dialogo di conferma, SnackBar "Attività cancellata".
- **Uscita con modifiche non salvate** (X, back, gesto predittivo): dialogo "Uscire senza salvare?" (Resta / Esci).
- Un solo stato `FormBusy` resettato in `finally` (B7); durante un'operazione i campi sono disabilitati.
- Feedback aptico su selezioni e contatori.

In modifica il record viene dalla lista già caricata dell'anno indicato dalla query `year` (dalla lista o dal calendario; senza query: anno selezionato) ed è memorizzato nello stato della schermata. Salvataggio e cancellazione passano dal notifier dell'anno del record. Se non esiste: "Attività non trovata".

## Dati e stato

- Modello `SexualActivity` (immutabile, freezed): il form lavora su una copia e confronta con lo stato iniziale per sapere se ci sono modifiche.
- `activitiesProvider(year)`: `add`, `edit(previousYear:)`, `remove`; dopo ogni mutazione ricarica la lista e invalida l'anno toccato e `yearlyProvider`.

## File

- `lib/features/activities/domain/sexual_activity.dart`
- `lib/features/activities/data/activity_dto.dart`, `activities_repository.dart`
- `lib/features/activities/presentation/activities_providers.dart`, `activities_list_screen.dart`, `activity_form_screen.dart`, `practice_icons.dart`
- `lib/shared/widgets/form_widgets.dart`, `month_grouped_list.dart`
- Vista calendario: vedi `calendar-view.md`

## Verifica manuale

1. "+" sul tab Attività → form nuovo; selezioni, contatori e chip rispondono; back con modifiche → dialogo; "Esci" chiude. ✅ emulatore 12/11/2026.
2. Form in modifica precompilato. ✅
3. Nuova attività con "Ieri" → compare nella lista sotto la data giusta. ⬜ (scrittura sul backend non provata)
4. Swipe per cancellare → conferma → sparisce; Annulla → la riga torna. ⬜
5. Modalità aereo + Salva → SnackBar di errore, form ancora modificabile. ⬜
