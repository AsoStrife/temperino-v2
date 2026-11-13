# Feature: Impostazioni e anno selezionato

Route `/settings`, ultimo tab. Stile "inset grouped": righe in contenitori arrotondati con divisori.

## Sezioni

1. **Partner** – una riga per partner: avatar, nome nel colore del partner, "Partner N · sesso", freccia. Tap → foglio dal basso con gli stessi campi dell'onboarding (`showPartnerSheet`: nome e Maschio/Femmina, "Salva" attivo solo con nome valido, si adatta alla tastiera). Al salvataggio SnackBar "Profilo aggiornato" ed etichette aggiornate subito ovunque.
2. **Dati** – "Anno visualizzato" con la pillola `YearSelector`.
3. **Aspetto** – Tema: segmented Auto / Chiaro / Scuro.
4. **Informazioni** – illustrazione, nome app e `AppConfig.appVersion`.

## Anno selezionato

- `yearProvider` (`YearNotifier`): default anno corrente, salvato in `settings.year` (B6), limitato fra `startYear` e l'anno corrente.
- `YearSelector` è una pillola "2026 ˅" nella barra in alto di Home, Attività, Masturbazioni, Statistiche e in Impostazioni; apre un foglio con gli anni come chip grandi.
- Tutti i provider dati sono indicizzati per anno: cambiarlo ricarica le schermate senza riavvio (B5).

## Tema

`themeModeProvider` salvato in `settings.themeMode` (`system` / `light` / `dark`).

## File

- `lib/features/settings/data/year_preference.dart`, `theme_preference.dart`
- `lib/features/settings/presentation/settings_screen.dart`
- `lib/shared/widgets/year_selector.dart`
- `lib/features/profile/presentation/partner_fields.dart` (`showPartnerSheet`)

## Verifica manuale

1. Cambio anno → Home e liste mostrano l'anno nuovo; riavvio → l'anno resta.
2. Tema Scuro → app scura e icone della status bar chiare. ✅ emulatore 12/11/2026.
3. Modifica del nome del partner 2 → la lista attività mostra il nuovo nome.

## Tablet

Sui tablet la pagina è centrata, larga al massimo 760 dp. Dettagli in `tablet-layout.md`.
