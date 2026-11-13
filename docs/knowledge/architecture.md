# Architettura

## Livelli

```
Schermate (ConsumerWidget)  ──watch──▶  Provider Riverpod  ──▶  Repository  ──▶  ApiClient (dio)  ──▶  Strapi
        │                                   │
        └── widget condivisi                └── StatsCalculator (funzioni pure)
```

- **Schermate**: solo UI. Leggono provider, chiamano i metodi dei notifier, mostrano SnackBar e dialoghi.
- **Provider**: stato e derivazioni. Non conoscono widget.
- **Repository**: unici a usare `ApiClient`. Convertono JSON ↔ modelli tramite i DTO.
- **ApiClient**: dio con base URL, timeout, header `Authorization`; ogni errore diventa `AppException`.

## Mappa dei file

| Percorso | Ruolo |
| --- | --- |
| `lib/main.dart` | Edge-to-edge, `initializeDateFormatting('it_IT')`, `SharedPreferences`, `ProviderScope` (retry disattivato). |
| `lib/app/app.dart` | `MaterialApp.router`, temi, locale `it_IT`, stile della status bar. |
| `lib/app/router.dart` | `routerProvider` (go_router), costanti `Routes`, redirect onboarding. |
| `lib/app/shell_scaffold.dart` | Barra flottante a pillola (centrata sui tablet) o rail laterale (tablet in orizzontale), pulsante "+" contestuale, back Android verso Home. |
| `lib/app/theme.dart` | `AppPalette`, `AppColors` (ThemeExtension), `AppTheme`, `systemOverlayFor`, `context.motion`. |
| `lib/core/config/app_config.dart` | Unica fonte di URL, endpoint, token, etichette, chiavi preferenze. |
| `lib/core/network/` | `ApiClient`, `fetchAllPages`, `yearQuery`. |
| `lib/core/error/app_exception.dart` | Gerarchia `sealed` di errori con messaggi in italiano. |
| `lib/core/storage/preferences_provider.dart` | `sharedPreferencesProvider` (override in `main`). |
| `lib/core/utils/` | `DateOnly`, `Formatters`, `JsonReaders`, `mapWithConcurrency`. |
| `lib/features/profile/` | `Partner`, `Gender`, `PartnerProfile`, `ProfileStore`, `profileProvider`, `PartnerFields`. |
| `lib/features/onboarding/` | `OnboardingScreen`. |
| `lib/features/activities/` | `SexualActivity`, `Practice`, `CumshotZone`, DTO, repository, `activitiesProvider`, lista, form. |
| `lib/features/masturbations/` | `Masturbation`, DTO, repository, `masturbationsProvider`, lista, form. |
| `lib/features/calendar/` | Logica pura del calendario (`CalendarDays`, `MasturbationHeart`) e provider derivati `activityDaysProvider` / `masturbationDaysProvider` (tutti gli anni). |
| `lib/features/stats/` | `StatsCalculator`, modelli statistici, provider derivati, `StatsScreen`, grafici. |
| `lib/features/home/` | `HomeScreen`. |
| `lib/features/settings/` | `yearProvider`, `themeModeProvider`, `listLayoutProvider`, `SettingsScreen`. |
| `lib/shared/widgets/` | Componenti del design system: `AppPage`, `Tile`, `MetricTile`, `HeroTile`, `PartnerSplitTile`, `InsetGroup`, `SectionTitle`, `Pill`, `YearSelector`, `EmptyState`, `AsyncBody`, `SliverMonthGroups`, componenti dei form (`DateQuickPicker`, `ToggleTile`, `SelectableGrid`, `ChoiceChipsWrap`, `BigCounter`, `SaveBar`), `showConfirmDialog`, `PartnerAvatar`, `SliverEventCalendar`, `HeartMark`, `showDayEventsSheet`, `ListLayoutToggle`; layout adattivi in `adaptive.dart` (`AppLayout`, `SliverPageWidth`, `PageListView`, `ResponsiveGrid`, `ResponsiveColumns`). Elenco e regole in `design-system.md`. |

## Provider

| Provider | Tipo | Dipende da |
| --- | --- | --- |
| `sharedPreferencesProvider` | `Provider<SharedPreferences>` | override in `main` |
| `profileProvider` | `NotifierProvider<…, PartnerProfile?>` | `ProfileStore` |
| `isOnboardedProvider` / `requireProfileProvider` | `Provider` | `profileProvider` |
| `yearProvider` | `NotifierProvider<…, int>` | preferenze |
| `themeModeProvider` | `NotifierProvider<…, ThemeMode>` | preferenze |
| `listLayoutProvider` | `NotifierProvider<…, ListLayout>` | preferenze |
| `activitiesProvider(year)` | `AsyncNotifierProvider.family` | `ActivitiesRepository` |
| `masturbationsProvider(year)` | `AsyncNotifierProvider.family` | `MasturbationsRepository` |
| `yearDataProvider(year)` | `FutureProvider.family` | le due liste |
| `summaryProvider(year)` | `FutureProvider.family<ActivitySummary>` | `yearDataProvider` |
| `masturbationSummaryProvider(year)` | `FutureProvider.family` | `masturbationsProvider` |
| `monthlyProvider(year)` | `FutureProvider.family<List<PartnerPair>>` | `yearDataProvider` |
| `monthlyRatioProvider(year)` | `FutureProvider.family<List<double?>>` | `activitiesProvider` |
| `cumshotProvider(year)` | `FutureProvider.family` | `activitiesProvider` |
| `calendarProvider(year)` | `FutureProvider.family<CalendarData>` | `yearDataProvider` |
| `yearlyProvider` | `FutureProvider<List<YearStats>>` | anno corrente dai provider, altri anni via repository (max 5 richieste in parallelo) |
| `activityDaysProvider` | `Provider<AsyncValue<Map<DateOnly, List<SexualActivity>>>>` | `activitiesProvider(y)` per ogni anno selezionabile |
| `masturbationDaysProvider` | `Provider<AsyncValue<Map<DateOnly, MasturbationDay>>>` | `masturbationsProvider(y)` per ogni anno, `requireProfileProvider` |
| `routerProvider` | `Provider<GoRouter>` | `isOnboardedProvider` (refreshListenable) |

### Invalidazione

- Cambio anno: tutte le schermate guardano `yearProvider` e quindi `…Provider(year)`; il nuovo anno si carica da solo (B5).
- `add` / `edit` / `remove` dei notifier: ricaricano la lista dell'anno corrente del notifier, invalidano la lista dell'anno toccato se diverso (la data può cambiare anno) e `yearlyProvider`.
- Pull-to-refresh: `ref.refresh` delle due liste dell'anno; nella vista calendario, di tutti gli anni.
- I provider del calendario osservano le liste di tutti gli anni: ogni invalidazione di un anno si riflette nel calendario senza codice aggiuntivo.

## Navigazione

`StatefulShellRoute.indexedStack` con cinque rami (Home, Attività, Masturbazioni, Statistiche, Impostazioni); ogni ramo mantiene il proprio stato. I form (`/activities/new`, `/activities/:id`, `/masturbations/new`, `/masturbations/:id`) usano `parentNavigatorKey: root` e `MaterialPage(fullscreenDialog: true)`; le route di modifica accettano la query `?year=AAAA` (anno del record, usata dal calendario che mostra tutti gli anni): si aprono a tutto schermo senza barra, con l'icona X. Il redirect porta a `/onboarding` finché il profilo non è completo.

Sui tablet la `ShellScaffold` mostra la barra centrata o, con finestra larga in orizzontale, una rail a destra (`AppLayout.useRail`). Il `navigationShell` resta sempre nello stesso punto dell'albero (`Row` → `Expanded` → `MediaQuery.removePadding`), prima della rail, quindi la rotazione non ricrea i navigator dei rami. La rail gestisce l'inset destro, rimosso dal contenuto solo quando è presente. Dettagli: `docs/features/tablet-layout.md`.
