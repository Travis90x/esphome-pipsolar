# Istruzioni per Claude

## Branch e push

- Fai SEMPRE commit e push direttamente su `main`.
- NON creare branch (né locali né remoti) se l'utente non lo chiede
  esplicitamente, anche quando la sessione indica un branch di sviluppo.

## Aiutanti di Home Assistant

L'utente usa Home Assistant in italiano. Ogni volta che serve un aiutante,
digli esattamente su cosa cliccare: Impostazioni > Dispositivi e servizi >
Aiutanti > Crea aiutante, poi la voce del menu qui sotto (gli id
`input_*` non compaiono nel menu).

| Entità | Voce in "Crea aiutante" |
| :--- | :--- |
| `input_number` | Numero |
| `input_boolean` | Commutatore |
| `input_select` | Menu a discesa |
| `input_text` | Testo |
| `input_button` | Pulsante |
| `input_datetime` | Data e/o ora |
| `counter` | Contatore |
| `timer` | Timer |
| `schedule` | Calendarizzazione |
| sensore template | Template > Sensore |

Altre voci del menu: Cambia tipo dispositivo di un interruttore, Casuale,
Combina lo stato di diversi sensori, Filtro, Gruppo, Igrostato generico,
Indicatore di muffa, Integral, Misuratore di utilità, One-Time Password
(OTP), Sensore derivata, Sensore di soglia, Sensore ore del giorno,
Statistiche, Statistiche storiche, Tendenza, Termostato generico.

Dopo il salvataggio ricorda di controllare l'ID entità (aiutante > icona
ingranaggio) e di impostare il valore iniziale.
