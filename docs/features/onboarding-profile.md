# Feature: Onboarding e profilo partner

## Cosa fa

Al primo avvio (o se il profilo è incompleto) l'app chiede nome e sesso dei due partner. Il profilo vive solo sul dispositivo e alimenta tutte le etichette dell'app. Il backend conosce solo `A` (partner 1) e `B` (partner 2).

## Schermata `/onboarding`

- In alto i due avatar sovrapposti con un cuore (gradiente), titolo "Chi siete?" e sottotitolo "Ci servono solo nomi e sesso. Puoi cambiarli in Impostazioni."
- Due tile: "Partner 1" (testo celeste) e "Partner 2" (testo rosa), ognuna con campo Nome (riempito, senza bordo) e segmented Maschio/Femmina. Default: Maschio per il partner 1, Femmina per il partner 2.
- "Invio" sulla tastiera passa dal nome 1 al nome 2; dal nome 2 conferma se tutto è valido.
- Validazione: nome 1–30 caratteri dopo trim (`PartnerProfile.isValidName`). Il pulsante "Continua" nella barra fissa in basso è attivo solo con entrambi validi. Sessi uguali ammessi.
- "Continua" salva il profilo e `profile.onboarded = true`; il redirect del router porta alla Home.

## Dati

| Chiave `shared_preferences` | Valore |
| --- | --- |
| `profile.onboarded` | `true` dopo l'onboarding |
| `partner.a.name` / `partner.b.name` | nome (trim) |
| `partner.a.gender` / `partner.b.gender` | `male` / `female` |

Lettura tollerante (`ProfileStore.read`): qualunque chiave mancante o non valida → profilo `null` → onboarding.

## Uso del profilo nell'app

- Ogni nome mostrato viene da `requireProfileProvider` (`profile.nameOf(Partner.a)`).
- L'etichetta del conteggio masturbazioni dipende dal sesso: `Gender.masturbationLabel` → "Seghe" / "Ditalini".
- Colori e avatar dipendono dallo slot (`Partner.a` celeste, `Partner.b` rosa), mai dal nome. Il testo colorato usa le varianti `partnerInk` (contrasto AA).

## File

- `lib/features/profile/domain/partner_profile.dart`
- `lib/features/profile/data/profile_store.dart`
- `lib/features/profile/presentation/profile_providers.dart`
- `lib/features/profile/presentation/partner_fields.dart` – `PartnerFields`, `PartnerSlotHeader`, `showPartnerSheet`
- `lib/features/onboarding/presentation/onboarding_screen.dart`
- `lib/app/router.dart` – redirect

## Verifica manuale

1. Installazione pulita → onboarding, nessun'altra route raggiungibile. ✅ emulatore 12/11/2026.
2. "Continua" disabilitato con un nome vuoto o di soli spazi. ✅
3. Completato l'onboarding → Home con i nomi inseriti. ✅
4. Riavvio → direttamente la Home.
5. Impostazioni → modifica nome/sesso → etichette aggiornate subito.
