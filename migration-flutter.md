# Temperino – Riscrittura in Flutter: specifica e piano implementativo

12 novembre 2026 · versione 3

## 1. Sintesi

Temperino è un'app ibrida (Vue 3, Framework7, Capacitor 5) con 11 schermate. Registra attività sessuali e masturbazioni per due partner e salva i dati su uno Strapi backend.

La riscrittura in Flutter è una nuova interfaccia sullo stesso backend. Il risultato è una UI Material 3 colorata, con più grafici e statistiche, gestione della status bar e navigazione moderna. Non cambia il backend, non si migrano dati e non si scrivono test automatici.

Al primo avvio un onboarding chiede nome e sesso dei due partner. Le etichette dell'app si adattano di conseguenza. Nel backend i partner restano `A` (partner 1) e `B` (partner 2), come oggi.

## 2. Ambito e vincoli

- Backend: lo stesso Strapi, nessuna modifica. Si usano solo gli endpoint che l'app attuale già usa.
- Autenticazione: nessun login. L'app usa il token fisso definito nel file di configurazione, come oggi.
- Configurazione: URL, endpoint, token e costanti stanno in un solo file (sezione 4.1). Il nome e il sesso dei partner non stanno nel codice: vengono dal profilo locale (sezione 4.2).
- Dati: nessuna migrazione, nessun import, nessun backup a carico della riscrittura.
- Test: nessun test automatico (unit, widget, integration). La verifica è manuale, con l'app in esecuzione.
- Piattaforma: Android. iOS è fuori ambito.
- Lingua: italiano.

## 3. Funzionalità da mantenere

L'app attuale ha 11 schermate più un menu laterale. La riscrittura mantiene tutte le funzioni e le riorganizza nella navigazione della sezione 9. Si aggiunge l'onboarding dei partner.

| # | Schermata attuale (route) | Funzione da mantenere |
| --- | --- | --- |
| 1 | Home `/` | Riepilogo dell'anno: numero di scopate, orgasmi totali per partner (attività e masturbazioni), accesso alle dashboard. Pull-to-refresh. |
| 2 | Dashboard attività `/sexualActivitiesDashboard/` | Orgasmi per partner, numero di scopate, orgasmi durante le scopate, rapporto D/A (totale e quando D viene), conteggio per pratica. |
| 3 | Dashboard masturbazioni `/masturbationDashboard/` | Per partner: numero di masturbazioni, quante con giocattoli, orgasmi totali. L'etichetta del conteggio dipende dal sesso (sezione 4.2). |
| 4 | Grafici `/chartsDashboard/` | Area: orgasmi per mese per partner. Barre: sborrate per zona. |
| 5 | Lista attività `/sexualActivitiesList/` | Elenco dell'anno con badge Scopata e Anal, zona della sborrata, orgasmi. Aggiunta con pulsante +. |
| 6 | Lista masturbazioni `/masturbationList/` | Elenco con avatar del partner, data e nome. Aggiunta con pulsante +. |
| 7 | Aggiungi attività `/addSexualActivities/` | Interruttori per sesso, pompino, sega, anal, ditalino, leccata, spagnola. Zona della sborrata, data, orgasmi A e B. |
| 8 | Modifica attività `/editSexualActivities/` | Stessi campi, precompilati. Salva o cancella con conferma. |
| 9 | Aggiungi masturbazione `/addMasturbation/` | Chi (partner 1 o 2), giocattoli sì o no, data, orgasmi. |
| 10 | Modifica masturbazione `/editMasturbation/` | Stessi campi, precompilati. Salva o cancella con conferma. |
| 11 | Impostazioni `/settings/` | Selezione dell'anno, da 2024 all'anno corrente. Si aggiungono nome e sesso dei partner. |
| - | Onboarding (nuovo) | Primo avvio: nome e sesso dei due partner. |

Comportamenti trasversali da mantenere:

- Tutte le schermate mostrano un solo anno. Il default è l'anno corrente. La scelta viene salvata.
- Cancellazione con finestra di conferma. Ogni salvataggio dà un feedback.
- Tasto indietro Android: chiude prima i modali, poi torna indietro.
- Tema automatico chiaro o scuro.

## 4. Configurazione

### 4.1 Configurazione statica

Tutti i valori fissi stanno in un unico file: `lib/core/config/app_config.dart`. Nessun altro file del progetto contiene URL, endpoint, token o etichette. Il file è una classe con costanti Dart, così i valori sono verificati dal compilatore e disponibili senza caricamenti asincroni.

Il valore di `apiToken` si copia da `src/js/constants.js`, campo `_c.apiToken`. Il token è nel repository per scelta del proprietario.

```dart
// lib/core/config/app_config.dart
// Unica fonte di verità per URL, endpoint, token e costanti fisse.

abstract final class AppConfig {
  // ---- App ----
  static const appName = 'Temperino';
  static const appVersion = '1.2.0';
  static const androidPackage = 'com.strifelab.temperino';

  // ---- Backend (Strapi v4, lo stesso dell'app attuale) ----
  static const baseUrl = 'https://strapi.andreacorriga.com/api/';
  static const apiToken = '<COPIA _c.apiToken DA src/js/constants.js>';
  static const requestTimeout = Duration(seconds: 20);

  // ---- Endpoint (path relativi a baseUrl) ----
  static const sexualActivitiesPath = 'sexual-activities';
  static const masturbationsPath = 'masturbations';

  // ---- Paginazione (Strapi v4: pagination[page], pagination[pageSize]) ----
  static const pageSize = 100;

  // ---- Query (Strapi v4: filters, sort) ----
  static const dateField = 'date';
  static const sortParam = 'date:desc';

  // ---- Dominio ----
  static const startYear = 2024;

  // Valore API del partner -> chiave del profilo. Il nome e il sesso
  // vengono dal profilo locale (sezione 4.2), non da qui.
  static const partnerApiValues = ['A', 'B'];     // A = partner 1, B = partner 2
  static const partnerAvatarA = 'assets/images/temperinoA.jpg';
  static const partnerAvatarB = 'assets/images/temperinoD.jpg';

  // Etichetta del conteggio masturbazioni per sesso del partner
  static const masturbationLabelMale = 'Seghe';
  static const masturbationLabelFemale = 'Ditalini';

  // Valore API -> etichetta italiana (le 12 zone del campo cumshot)
  static const cumshotLabels = <String, String>{
    'mouth': 'Bocca',
    'butts': 'Chiappe',
    'ass': 'Culo',
    'face': 'Faccia',
    'hips': 'Fianchi',
    'pussy-inside': 'Figa (dentro)',
    'pussy-condom': 'Figa (ghindolo)',
    'belly': 'Pancia',
    'feet': 'Piedi',
    'back': 'Schiena',
    'tits': 'Tette',
    'none': 'Niente (no sborrata)',
  };
}
```

Regole d'uso:

- Le stringhe con `$` (per esempio `filters[date][$gte]`) vanno scritte come raw string, `r'filters[date][$gte]'`, altrimenti Dart interpola la variabile.
- Il file non legge variabili d'ambiente e non usa `--dart-define`. Per cambiare ambiente si modifica il file.
- Le immagini `assets/images/` si generano copiando `public/icons/temperinoA.jpg`, `public/icons/temperinoD.jpg` e `public/icons/sexual-activities.jpg`.

### 4.2 Profilo partner

Il profilo contiene nome e sesso dei due partner. Vive solo sul dispositivo, in `shared_preferences`. Non va nel backend e non cambia nessun dato esistente.

Campi:

| Chiave in `shared_preferences` | Tipo | Valori |
| --- | --- | --- |
| `profile.onboarded` | bool | `true` dopo il completamento dell'onboarding |
| `partner.a.name` | stringa | 1-30 caratteri, senza spazi iniziali e finali |
| `partner.a.gender` | stringa | `male` oppure `female` |
| `partner.b.name` | stringa | come sopra |
| `partner.b.gender` | stringa | come sopra |

Mappatura: `A` del backend è il partner 1, `B` è il partner 2. Il backend non sa nulla di nomi e sessi.

Regole di uso del profilo:

- Ogni testo che nel documento dice "Andrea" o "Daniela" usa il nome del profilo. Ogni etichetta di conteggio masturbazioni usa `masturbationLabelMale` o `masturbationLabelFemale` in base al sesso del partner.
- I colori e gli avatar restano legati al partner 1 e al partner 2, non al nome. Il partner 1 è blu, il partner 2 è arancio, in tutta l'app.
- La legenda dei grafici mostra il nome del profilo.
- Se il profilo non è completo, l'app mostra l'onboarding (sezione 9).

## 5. Backend e API

Il backend non cambia. Tutte le chiamate usano `AppConfig.baseUrl` più un endpoint di `AppConfig`.

### Endpoint usati

| Operazione | Metodo e path | Dettagli |
| --- | --- | --- |
| Lista attività dell'anno | GET `sexual-activities` | Query con i parametri sotto. Paginata. |
| Lista masturbazioni dell'anno | GET `masturbations` | Stessi parametri. Paginata. |
| Crea attività | POST `sexual-activities` | Body `{ "data": { ... } }` |
| Modifica attività | PUT `sexual-activities/{id}` | Body `{ "data": { ... } }` |
| Cancella attività | DELETE `sexual-activities/{id}` | |
| Crea masturbazione | POST `masturbations` | Body `{ "data": { ... } }` |
| Modifica masturbazione | PUT `masturbations/{id}` | Body `{ "data": { ... } }` |
| Cancella masturbazione | DELETE `masturbations/{id}` | |

### Query della lista

Per l'anno `Y`, la richiesta è:

```
GET {baseUrl}{path}
  ?filters[date][$gte]=Y-01-01
  &filters[date][$lte]=Y-12-31
  &sort=date:desc
  &pagination[page]=N
  &pagination[pageSize]=100
```

L'app attuale usa `orderBy[date]=desc`. La nuova app usa `sort`, che è la sintassi Strapi v4.

### Header

Ogni richiesta ha `Authorization: Bearer <apiToken>`. Il client dio aggiunge l'header in un interceptor, così nessuna schermata lo gestisce.

### Risposte

Le risposte hanno la forma `{ "data": [ { "id": 1, "attributes": { ... } } ], "meta": { "pagination": { "page", "pageSize", "pageCount", "total" } } }`.

Il client scarica tutte le pagine finché `page < pageCount`. La paginazione del backend funziona: il proprietario l'ha verificato.

### Formato dei dati

- `date`: stringa `AAAA-MM-GG`. Va letta come data senza ora e senza fuso (vedi B11).
- Campi booleani: l'API accetta true, false, 0 e 1. La nuova app invia sempre true o false.
- `cumshot`: uno dei 12 valori di `AppConfig.cumshotLabels`. Nell'app attuale può essere vuoto. La nuova app usa `none` come valore di default.
- `orgasm_a`, `orgasm_b`, `n_orgasms`: interi. Possono essere null nei record vecchi. Il parser li converte in 0.
- `who`: `A` oppure `B`.
- `toys`: booleano.

## 6. Logica di calcolo

Le statistiche si calcolano nel client a partire dalle liste dell'anno, come oggi. Il calcolo sta in funzioni pure in `lib/features/stats/domain/stats_calculator.dart`, senza dipendenze da Flutter.

Definizioni (A è il partner 1, B è il partner 2):

- Scopate: numero di attività con `sex == true`.
- Orgasmi in attività: somma di `orgasm_a` (per A) e di `orgasm_b` (per B) su tutte le attività.
- Orgasmi durante il sesso: come sopra, ma solo sulle attività con `sex == true`.
- Orgasmi durante il sesso quando B viene: come sopra, ma solo se `sex == true` e `orgasm_b > 0`.
- Orgasmi totali per partner: orgasmi in attività più orgasmi in masturbazioni (`n_orgasms` per il partner indicato in `who`).
- Rapporto D/A: `orgasmi di B durante il sesso / orgasmi di A durante il sesso`. Se il denominatore è zero, il risultato è null e la UI mostra "—" (B1).
- Rapporto D/A quando B viene: stessa formula, sulle attività con `orgasm_b > 0`.
- Conteggio per pratica: numero di attività con il booleano a true, per `blowjob`, `handjob`, `fingering`, `lick`, `tits_fuck`, `anal`.
- Sborrate per zona: numero di attività per ogni valore di `cumshot`. Si contano tutte le 12 zone, compresa `none` (B2).
- Orgasmi per mese: raggruppati per mese della data, 12 valori per l'anno. Ogni valore ha orgasmi A e orgasmi B, totali (attività più masturbazioni).
- Masturbazioni per partner: numero totale, numero con `toys == true`, somma di `n_orgasms`.
- Calendario: per ogni giorno dell'anno, numero di attività e masturbazioni.
- Confronto anni: stesse misure per ogni anno da `startYear` all'anno corrente. Le richieste per gli anni diversi dall'anno corrente si fanno in parallelo, al massimo cinque alla volta.

## 7. Bug da non replicare

Questi bug esistono nell'app attuale. La nuova app li corregge. Ogni voce è un requisito di implementazione.

Voci rimosse rispetto alla versione 2:

- Ex B3, etichetta "Dittalini": non è un bug. L'etichetta dipende dal sesso del partner ed è gestita dal profilo (sezione 4.2).
- Ex B9, paginazione: il proprietario conferma che la paginazione Strapi funziona. Il client scarica comunque tutte le pagine (sezione 5).

| # | Bug attuale | Requisito nella nuova app |
| --- | --- | --- |
| B1 | Il rapporto D/A divide per zero e mostra `Infinity` o `NaN`. | Se il denominatore è zero, mostra "—". |
| B2 | Il grafico delle sborrate conta solo 8 zone su 12. | Conta tutte le 12 zone, compresa `none`. |
| B4 | `reverse()` modifica l'array dello store a ogni montaggio. | I dati si ordinano in una copia, mai in place. |
| B5 | Il cambio anno non ricarica i dati. | Il cambio anno invalida le liste e ricarica. |
| B6 | L'anno selezionato non viene salvato. | L'anno si salva in `shared_preferences` e si ripristina all'avvio. |
| B7 | Lo spinner di cancellazione non si ferma per un typo nel nome della variabile. | Lo stato di caricamento è unico per ogni operazione e si resetta sempre (`finally`). |
| B8 | Il toast di errore nel salvataggio masturbazione non viene mai mostrato. | Ogni errore di salvataggio mostra uno SnackBar con messaggio. |
| B10 | Il parametro `orderBy` non è la sintassi Strapi v4. | Si usa `sort=date:desc`. |
| B11 | `new Date('AAAA-MM-GG')` interpreta la data come UTC: il giorno può slittare. | Le date si parsano come `DateOnly`, senza ora e senza fuso. |
| B12 | `toys` viene inviato come 0 invece di false. | `toys` è sempre booleano, default false. |
| B13 | I totali sommano valori null. | Il parser converte null in 0. |
| B14 | Nomi delle pratiche diversi tra form e statistiche. | Un solo nome per pratica nelle attività (per esempio "Ditalino" nel form e nelle statistiche). L'etichetta della masturbazione dipende dal sesso (sezione 4.2). |

## 8. Architettura e struttura del progetto

Architettura a livelli: schermate, provider di stato, repository, client API. Le schermate non chiamano mai dio direttamente. I provider non conoscono i widget.

Struttura delle cartelle:

```
lib/
  main.dart                          // runApp, inizializzazione shared_preferences
  app/
    app.dart                         // MaterialApp.router, tema, locale it_IT
    router.dart                      // go_router con redirect verso l'onboarding
    theme.dart                       // ColorScheme, colori partner, transizioni
  core/
    config/app_config.dart           // sezione 4.1
    network/api_client.dart          // dio, header Authorization, timeout
    network/strapi_pagination.dart   // scarica tutte le pagine
    error/app_exception.dart         // errori di rete e di parsing
    utils/date_only.dart             // tipo DateOnly
    utils/formatters.dart            // dd-MM-yyyy, mesi in italiano
  features/
    onboarding/
      presentation/onboarding_screen.dart
    profile/
      domain/partner_profile.dart    // modello e enum Gender
      data/profile_store.dart        // lettura e scrittura di shared_preferences
      presentation/profile_providers.dart
    activities/
      domain/sexual_activity.dart    // modello e enum CumshotZone
      data/activity_dto.dart         // mapping JSON <-> modello
      data/activities_repository.dart
      presentation/activities_providers.dart
      presentation/activities_list_screen.dart
      presentation/activity_form_screen.dart
    masturbations/                   // stessa struttura di activities
    stats/
      domain/stats_calculator.dart   // funzioni pure, sezione 6
      domain/stats_models.dart
      presentation/stats_providers.dart
      presentation/stats_screen.dart
      presentation/widgets/          // grafici
    home/presentation/home_screen.dart
    settings/
      data/year_preference.dart      // shared_preferences
      presentation/settings_screen.dart
  shared/widgets/
    partner_avatar.dart
    empty_state.dart
    async_body.dart                  // loading, errore, contenuto
    confirm_dialog.dart
```

Stato con Riverpod, con questi provider:

- `profileProvider`: profilo dei partner. Legge da `shared_preferences` all'avvio. Espone se l'onboarding è completo.
- `yearProvider`: anno selezionato. Legge e scrive in `shared_preferences`.
- `activitiesProvider(year)`: `AsyncNotifier` con la lista dell'anno e i metodi `add`, `update`, `delete`. Ogni metodo ricarica la lista al termine.
- `masturbationsProvider(year)`: come sopra.
- `summaryProvider(year)`, `monthlyProvider(year)`, `cumshotProvider(year)`, `calendarProvider(year)`, `yearlyProvider`: derivati da liste e `StatsCalculator`.

## 9. Navigazione e schermate

### Navigazione

Il router ha un redirect: se `profile.onboarded` è falso, ogni route porta a `/onboarding`. Completato l'onboarding, si va a `/`.

La barra inferiore (`NavigationBar`, Material 3) ha cinque destinazioni:

| Destinazione | Route | Schermata | Sostituisce |
| --- | --- | --- | --- |
| Home | `/` | HomeScreen | Home |
| Attività | `/activities` | ActivitiesListScreen | Lista attività |
| Masturbazioni | `/masturbations` | MasturbationsListScreen | Lista masturbazioni |
| Statistiche | `/stats` | StatsScreen, con due tab: Attività e Masturbazioni | Dashboard e grafici |
| Impostazioni | `/settings` | SettingsScreen | Impostazioni |

Route fuori dalla shell, a tutto schermo, senza barra:

- `/onboarding`: OnboardingScreen.
- `/activities/new` e `/activities/:id`: ActivityFormScreen. In modifica, la schermata riceve l'id e recupera il record dalla lista già caricata.
- `/masturbations/new` e `/masturbations/:id`: MasturbationFormScreen.

### Onboarding

Compare al primo avvio, o se il profilo non è completo.

- Titolo: "Chi siete?". Sottotitolo: "Ci servono solo nomi e sesso. Puoi cambiarli in Impostazioni."
- Card "Partner 1": campo Nome, selettore a due valori Maschio e Femmina. Default: Maschio.
- Card "Partner 2": campo Nome, selettore a due valori Maschio e Femmina. Default: Femmina.
- Validazione: entrambi i nomi non vuoti, 1-30 caratteri dopo il trim. Il pulsante "Continua" è attivo solo se entrambi sono validi.
- Nessun vincolo sul sesso: due valori uguali sono ammessi.
- Al "Continua" salva il profilo e `profile.onboarded = true`, poi va alla Home.

### Home

- Titolo con l'anno selezionato.
- Card con numero di scopate.
- Due card con gli orgasmi totali per partner (attività più masturbazioni), con il nome del profilo e il colore del partner.
- Pulsante per le statistiche.
- Pull-to-refresh che ricarica le liste dell'anno.

### Lista attività

- Intestazione con il numero di elementi.
- Elementi raggruppati per mese, con intestazione del mese.
- Ogni elemento: data, badge "Scopata" e "Anal" se attivi, zona della sborrata, orgasmi di ciascun partner con il nome del profilo.
- Tap sull'elemento apre la modifica.
- Pulsante + in basso a destra apre il nuovo inserimento.
- Stato vuoto: "Non sono presenti attività sessuali".

### Form attività

Campi, in quest'ordine:

1. Sette interruttori: Sesso, Pompino, Sega, Anal, Ditalino, Leccata, Spagnola. Default off.
2. Zona della sborrata: menu con le 12 voci di `AppConfig.cumshotLabels`. Default `none`.
3. Data: DatePicker di Material 3. Default oggi. Non si accettano date future.
4. Orgasmi del partner 1: stepper, minimo 0, default 0. Etichetta con il nome del profilo.
5. Orgasmi del partner 2: stepper, minimo 0, default 0. Etichetta con il nome del profilo.

Pulsante Salva. In modifica, pulsante Cancella con finestra di conferma. Durante il salvataggio il pulsante mostra un indicatore di caricamento. Un errore mostra uno SnackBar (B8).

### Lista masturbazioni

- Come la lista attività, con avatar del partner al posto del badge.
- Stato vuoto: "Non sono presenti masturbazioni".

### Form masturbazione

Campi, in quest'ordine:

1. Chi: due opzioni con i nomi del profilo. Default partner 1.
2. Giocattoli: interruttore. Default off (B12).
3. Data: DatePicker, default oggi, senza date future.
4. Orgasmi: stepper, minimo 0, default 0.

Salva e Cancella con le stesse regole del form attività.

### Statistiche

Due tab, Attività e Masturbazioni. Il selettore dell'anno è nella barra superiore, uguale in tutte le schermate.

Tab Attività:

- Card con orgasmi per partner.
- Card con numero di scopate.
- Card con orgasmi durante il sesso per partner.
- Card con i due rapporti D/A (sezione 6).
- Grafico orgasmi per mese (sezione 10).
- Grafico sborrate per zona (sezione 10).
- Grafico pratiche (sezione 10).
- Calendario dell'anno (sezione 10).
- Grafico confronto anni (sezione 10).

Tab Masturbazioni:

- Per ogni partner: numero di masturbazioni, quante con giocattoli, orgasmi totali. Il conteggio ha l'etichetta del sesso (`masturbationLabelMale` o `masturbationLabelFemale`).
- Ciambella con la quota di masturbazioni con giocattoli.

### Impostazioni

- Sezione Partner: nome e sesso di ciascun partner, modificabili. Un tap apre un dialogo con gli stessi campi dell'onboarding. Il cambio aggiorna le etichette subito.
- Selettore anno, da `startYear` all'anno corrente.
- Tema: sistema, chiaro, scuro.
- Versione dell'app (`AppConfig.appVersion`).

## 10. UI, tema e grafici

### Colori

Il colore è legato al partner 1 e al partner 2, non al nome. Il partner 1 è blu, il partner 2 è arancio.

| Ruolo | Colore |
| --- | --- |
| Partner 1 (`A`) | Blu #2F80ED |
| Partner 2 (`B`) | Arancio #F2994A |
| Accento (azioni, FAB) | Rosso #E4572E |
| Positivo | Verde #2EB67D |
| Attenzione | Ambra #F2C94C |
| Dati neutri | Grigio #8E8E93 |

Il tema Material 3 parte da un `ColorScheme.fromSeed` con seed `#E4572E`. I colori dei partner e i colori semantici si applicano sopra il seed. Il tema scuro usa lo stesso schema, con le varianti dark. Il contrasto deve rispettare WCAG AA in entrambi i temi: verificare a occhio con l'app in esecuzione.

### Tipografia e icone

- Font di sistema Material 3, nessun font da CDN.
- Icone Material Symbols, arrotondate.
- Testo scalabile fino al 200 per cento senza tagli di layout.

### Grafici

Libreria: `fl_chart` per linee, barre e ciambelle. Il calendario è un widget `CustomPainter`.

| Grafico | Dati | Tipo | Note |
| --- | --- | --- | --- |
| Orgasmi per mese | 12 mesi, due serie (partner 1 e partner 2) | Linea con area | Legenda con i nomi del profilo. Tooltip con i due valori del mese. |
| Sborrate per zona | 12 zone | Barre orizzontali | Ordinate dalla più frequente. Colore neutro, la zona più frequente in accento. |
| Pratiche | 6 pratiche | Barre orizzontali | Un colore solo. |
| Rapporto D/A per mese | 12 mesi | Linea con riferimento a 1,0 | Mesi senza dati non si disegnano. |
| Calendario | 365 giorni | Griglia a intensità colore | Una cella per giorno. Tap mostra il conteggio del giorno. |
| Confronto anni | Anni da `startYear` a oggi, una linea per anno | Linee sovrapposte sui mesi | Indicatore di caricamento finché gli anni non sono pronti. |
| Masturbazioni con giocattoli | Due partner | Ciambella | Centro con il totale. |

Ogni grafico ha una descrizione testuale per TalkBack e VoiceOver, con il valore principale (`Semantics`).

### Animazioni

Transizioni brevi. Si rispetta la preferenza "riduci movimento" del sistema.

## 11. Stack, versioni e Android

### Versioni verificate il 12 novembre 2026

- Flutter 3.50, rilasciata l'11 novembre 2026. Fonte: [Novità di Flutter](https://docs.flutter.dev/release/whats-new). La pagina non indica la versione di Dart: si usa quella inclusa in Flutter 3.50.
- Google Play richiede target API 36 (Android 16) per nuove app e aggiornamenti dal 31 agosto 2026. La proroga per le app esistenti è scaduta il 1° novembre 2026. Fonte: [Requisiti target SDK](https://developer.android.com/google/play/requirements/target-sdk).
- Android 17 (API 37) è in beta nelle note ufficiali, ultima versione elencata Beta 4.1 di giugno 2026. Fonte: [Note di rilascio Android 17](https://developer.android.com/about/versions/17/release-notes).

### Pacchetti

Usare `flutter pub add` per ottenere la versione più recente compatibile con Flutter 3.50. Verificare su pub.dev.

| Pacchetto | Uso |
| --- | --- |
| `flutter_riverpod`, `riverpod_annotation` | Stato |
| `go_router` | Navigazione e redirect dell'onboarding |
| `dio` | Client HTTP |
| `freezed_annotation`, `json_annotation` | Modelli immutabili |
| `freezed`, `json_serializable`, `build_runner` (dev) | Generazione del codice dei modelli |
| `fl_chart` | Grafici |
| `shared_preferences` | Anno, tema e profilo dei partner |
| `intl` | Formattazione date e numeri in italiano |
| `flutter_launcher_icons` (dev) | Icona dell'app da `assets-src/web-icon.png` |

Niente `flutter_secure_storage`: il token è in `AppConfig`. Niente Drift: nessuna cache offline. Niente pacchetti di test.

### Configurazione Android

- `applicationId` e `namespace`: `com.strifelab.temperino`, come l'app attuale. Così la nuova app aggiorna quella esistente sul Play Store.
- `minSdk`: 24 (Android 7.0). Default scelto, vedi sezione 14.
- `targetSdk`: 36, come minimo richiesto da Google Play.
- `compileSdk`: il valore più recente installato con Flutter 3.50, almeno 36.
- Permesso: solo `INTERNET`. Nessun traffico in chiaro: solo HTTPS.
- Edge-to-edge: obbligatorio con target 35 o superiore. Il layout usa `SafeArea` e `MediaQuery.padding`.
- Ritorno predittivo: `PredictiveBackPageTransitionsBuilder` in `ThemeData.pageTransitionsTheme` per Android.
- Firma: il keystore di release resta fuori dal repository. Il file `android/key.properties` va in `.gitignore`.

### Status bar

- Android: `SystemUiMode.edgeToEdge`. Gli stili della status bar seguono il tema: icone chiare su tema scuro, scure su tema chiaro. Si imposta con `SystemChrome.setSystemUIOverlayStyle` a ogni cambio di tema.
- La status bar è trasparente. Il contenuto va sotto di lei, con padding gestito dal layout.

### Splash

Splash nativa con il colore di sfondo del tema e l'icona. Si genera con `flutter_native_splash`, se serve, oppure con la configurazione di default di Android 12 e successivi.

## 12. Piano implementativo per Opus

Il piano è diviso in milestone. Ogni milestone finisce con l'app che compila, `flutter analyze` senza errori, e il lavoro committato solo se richiesto. Non si scrivono test automatici. La verifica è manuale: si avvia l'app su emulatore o dispositivo e si percorrono i flussi indicati.

### M0 · Progetto

1. Creare il progetto: `flutter create --org com.strifelab --project-name temperino --platforms android temperino`. Verificare che l'`applicationId` risultante sia `com.strifelab.temperino`.
2. Aggiungere le dipendenze della sezione 11 con `flutter pub add`.
3. Creare la struttura di cartelle della sezione 8, anche con file vuoti dove serve.
4. Copiare le immagini in `assets/images/` e dichiararle in `pubspec.yaml`.
5. Impostare `minSdk`, `targetSdk`, `namespace` e il nome visibile dell'app "Temperino" in `android/app/build.gradle` e `AndroidManifest.xml`.
6. Configurare `flutter_launcher_icons` con `assets-src/web-icon.png` e generare le icone.
7. Aggiungere a `.gitignore`: `android/key.properties`, `*.jks`, `*.keystore`.

Fine M0: `flutter analyze` pulito, app che si avvia su una schermata vuota.

### M1 · Configurazione e rete

1. Creare `lib/core/config/app_config.dart` come nella sezione 4.1. Copiare il token da `src/js/constants.js`.
2. Creare `api_client.dart`: istanza dio con `baseUrl`, timeout da `AppConfig.requestTimeout`, interceptor che aggiunge `Authorization: Bearer <apiToken>`.
3. Creare `app_exception.dart`: tipi di errore (rete, timeout, risposta non valida, server). Ogni errore di dio si converte in `AppException`.
4. Creare `strapi_pagination.dart`: funzione che chiama un endpoint con i parametri di query, legge `meta.pagination` e restituisce la lista completa di `data`.
5. Creare `date_only.dart`: valore con anno, mese, giorno; costruttore da stringa `AAAA-MM-GG` senza fuso; `toJson` che restituisce `AAAA-MM-GG`; confronto e uguaglianza.

Fine M1: una chiamata di lista per l'anno corrente restituisce dati dal backend. Verifica manuale con un log temporaneo che stampa il numero di record.

### M2 · Modelli e repository

1. Creare `SexualActivity`, `Masturbation`, `CumshotZone` (enum con valore API e etichetta da `AppConfig`) e `PartnerProfile` con `Gender` (`male`, `female`).
2. Creare i DTO e il mapping JSON. Il mapping legge `attributes`, converte null in 0, legge le date con `DateOnly`.
3. Serializzazione in uscita: il body è sempre `{ "data": { ... } }`, con booleani veri e falsi, la data in `AAAA-MM-GG`, `cumshot` come stringa, `toys` booleano.
4. Creare `ActivitiesRepository` e `MasturbationsRepository` con i metodi: `listForYear(year)`, `create`, `update(id)`, `delete(id)`. Ogni metodo usa `AppConfig` per path e query.
5. Creare `stats_models.dart` e `stats_calculator.dart` con le funzioni della sezione 6. Ogni funzione è pura: riceve liste e restituisce il risultato.

Fine M2: il calcolo delle statistiche sulla lista dell'anno corrente mostra valori coerenti: il totale degli orgasmi è la somma delle due liste.

### M3 · Profilo e stato

1. `profile_store.dart`: lettura e scrittura del profilo in `shared_preferences`, con le chiavi della sezione 4.2. Lettura tollerante: chiave assente significa profilo non completo.
2. `profileProvider`: espone il profilo e se l'onboarding è completo.
3. `yearProvider`: legge l'anno da `shared_preferences` all'avvio, default anno corrente, scrittura al cambio. Il valore è sempre fra `startYear` e l'anno corrente (B6).
4. `activitiesProvider(year)` e `masturbationsProvider(year)`: `AsyncNotifier` con `add`, `update`, `delete`. Ogni metodo invalida e ricarica la lista (B5).
5. Provider derivati per statistiche, mesi, zone, calendario, confronto anni. Il confronto anni chiama il repository per ogni anno con al massimo cinque richieste in parallelo.

Fine M3: cambiando l'anno nelle impostazioni, le liste si aggiornano senza riavvio. Il profilo si legge e si scrive correttamente.

### M4 · Shell, navigazione e tema

1. `app.dart`: `MaterialApp.router`, locale `it_IT`, tema chiaro e scuro, modalità da preferenza.
2. `theme.dart`: `ColorScheme.fromSeed` con seed `#E4572E`, colori partner e semantici come estensione del tema, `pageTransitionsTheme` con ritorno predittivo.
3. `router.dart`: `ShellRoute` con `NavigationBar` a cinque destinazioni (sezione 9), route di dettaglio fuori dalla shell, redirect verso `/onboarding` se il profilo non è completo.
4. `shell_scaffold.dart`: scaffold con la barra inferiore e la gestione dello stato selezionato.

Fine M4: all'avvio con profilo vuoto si va all'onboarding. Con profilo completo si naviga fra le cinque destinazioni, con schermate vuote come segnaposto.

### M5 · Onboarding e schermate

1. `OnboardingScreen`: due card, campi nome, selettore sesso con default come da sezione 9, validazione, salvataggio del profilo.
2. `HomeScreen`: card e pull-to-refresh della sezione 9.
3. `ActivitiesListScreen` e `MasturbationsListScreen`: raggruppamento per mese, stato vuoto, pull-to-refresh, pulsante + che apre il form.
4. `ActivityFormScreen`: campi della sezione 9, validazione data futura, salvataggio, cancellazione con `confirm_dialog`. Modifica precompilata da un record della lista.
5. `MasturbationFormScreen`: come sopra, con i campi masturbazione.
6. `SettingsScreen`: sezione Partner (modifica di nome e sesso), anno, tema, versione.
7. Stato di caricamento, errore e vuoto in tutte le schermate con `async_body.dart`.

Fine M5: si completa l'onboarding, si inseriscono, modificano e cancellano attività e masturbazioni, e i valori compaiono nella Home e nelle liste con i nomi del profilo.

### M6 · Statistiche e grafici

1. `StatsScreen` con le due tab e il selettore dell'anno nella barra superiore.
2. Tab Attività: card di riepilogo, rapporti D/A, grafici orgasmi per mese, sborrate per zona, pratiche, calendario, confronto anni.
3. Tab Masturbazioni: card per partner con l'etichetta del sesso e ciambella.
4. Descrizioni `Semantics` per ogni grafico.
5. Stati di caricamento per il confronto anni.

Fine M6: tutti i grafici mostrano dati dell'anno selezionato. Le 12 zone compaiono nel grafico delle sborrate (B2).

### M7 · Rifinitura

1. Status bar e edge-to-edge (sezione 11), con stili che seguono il tema.
2. Tasto indietro Android: verificare a mano che i modali si chiudano prima della navigazione.
3. Controllo dei layout su schermi piccoli e con testo al 200 per cento.
4. Icona e splash.
5. Rimozione del codice di debug e dei log temporanei.

Fine M7: nessun errore di analisi, nessun log di debug nel codice.

### M8 · Build

1. `flutter build appbundle --release` con il keystore di release configurato fuori dal repository.
2. Installare la build su un dispositivo Android e percorrere i flussi della sezione 13, punto 6.

## 13. Prompt di avvio per Opus

Usare questo testo come primo messaggio all'agente che implementa:

> Implementa la riscrittura Flutter di Temperino seguendo `migration-flutter.md` in questa cartella. Leggi tutto il documento prima di scrivere codice. Regole:
>
> 1. Il backend non cambia. Usa solo gli endpoint della sezione 5. Non inventare endpoint, non aggiungere login.
> 2. I valori fissi (URL, endpoint, token, etichette, costanti) stanno in `lib/core/config/app_config.dart`. Nome e sesso dei partner non stanno nel codice: vengono dal profilo locale (sezione 4.2). Non scrivere altri valori hardcoded.
> 3. Non scrivere test automatici. Verifica con `flutter analyze` e con l'app in esecuzione.
> 4. Non fare migrazioni dei dati e non modificare il backend.
> 5. Lavora milestone per milestone, M0 → M8, nell'ordine della sezione 12. Dopo ogni milestone, fermati e riporta cosa è stato fatto e cosa hai verificato.
> 6. Ogni bug della sezione 7 è un requisito. Al termine, elenca per ciascun B1–B14 come è stato risolto.
> 7. Non committare senza che l'utente lo chieda.
> 8. Testi dell'interfaccia in italiano.
> 9. Se un punto è aperto (sezione 14), usa il default indicato e segnalalo nel riepilogo.

## 14. Punti aperti e fuori ambito

Punti aperti, con il default scelto nel documento:

- Sort di Strapi (B10): il documento usa `sort=date:desc`. Verificare con la prima chiamata reale. Se il backend non ordina, l'ordinamento si fa nel client.
- `minSdk`: default 24. Confermare dopo aver visto la distribuzione dei dispositivi nella Play Console.
- Profilo locale: nome e sesso dei partner sono salvati sul dispositivo. Installando su un altro telefono, l'onboarding va rifatto. Se serve un profilo condiviso, va previsto un campo nel backend, fuori da questo perimetro.
- Due partner dello stesso sesso: l'onboarding li accetta. Le etichette di conteggio masturbazioni sono le stesse per entrambi.
- Cumshot di default: `none`. Nell'app attuale il valore può essere vuoto.

Fuori ambito:

- iOS.
- Login, account, utenti multipli e sincronizzazione tra dispositivi diversi dal backend attuale.
- Modifica di backend, schema Strapi o endpoint.
- Migrazione o import dei dati.
- Test automatici.
- Cache offline.
- Esportazione dei dati.

## 15. Fonti

- [Novità di Flutter](https://docs.flutter.dev/release/whats-new), consultata il 12 novembre 2026.
- [Requisiti target SDK di Google Play](https://developer.android.com/google/play/requirements/target-sdk), consultata il 12 novembre 2026.
- [Note di rilascio di Android 17](https://developer.android.com/about/versions/17/release-notes), consultata il 12 novembre 2026.
- Codice di riferimento: repository `temperino-fe`, branch `main`, commit `8c29122`. File analizzati: `src/js/constants.js`, `src/js/utils.js`, `src/stores/*.js`, `src/utils/aggregator.js`, `src/pages/*.vue`, `src/components/**/*.vue`, `src/index.html`, `package.json`, `capacitor.config.json`, `.gitignore`.
