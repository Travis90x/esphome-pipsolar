# SOC LiFePO4 8S (tensione + corrente)

## Perche' non basta la tensione

Il pacco LiFePO4 8S ha una curva Volt/SOC molto piatta tra il 20% e
l'80% circa: pochi centesimi di volt corrispondono a decine di punti
percentuali di SOC. In piu' quella curva "si sposta" in base a quanta
corrente sta assorbendo o erogando la batteria in quel momento (caduta
resistiva interna): la stessa tensione misurata puo' corrispondere a
SOC diversi a seconda che la batteria stia caricando forte, scaricando
forte o sia a riposo. Un sensore SOC basato solo sulla tensione
istantanea (come `sensor.heltec_pi30_battery_soc`, quello letto dal
protocollo PI30) e' quindi impreciso proprio nel mezzo della curva,
dove serve di piu'.

## Come funziona questa soluzione

Invece di leggere il SOC dalla tensione, si integra nel tempo la
corrente di `sensor.heltec_pi30_battery_current` (positiva in carica,
negativa in scarica: e' gia' cosi' per questo sensore) rispetto alla
capacita' nominale del pacco (155Ah): e' il classico "coulomb
counting" usato dai BMS.

Il problema del coulomb counting puro e' che accumula errore nel
tempo (deriva). Per eliminarlo, la stima viene "agganciata" ai due
estremi usando la tensione, dove la tensione E' affidabile:

- **100%**: quando la tensione di pacco raggiunge la tensione di
  float del carica-batterie (`sensor.heltec_pi30_display_pi30_battery_float_voltage`
  meno 0.1V di margine). A quel punto la batteria e' per definizione
  piena, qualunque cosa dica il conteggio Ah.
- **0%**: quando la tensione di pacco scende sotto la tensione di
  under-voltage (`sensor.heltec_pi30_display_pi30_battery_under_voltage`)
  piu' 0.2V di margine, cosi' arriviamo a 0% un po' prima che sia il
  BMS a staccare la batteria per basso voltage.

Tra questi due estremi il SOC si muove solo per integrazione della
corrente, ogni 2 minuti.

## Componenti (3 file, da installare cosi')

1. **`Helpers - PI30 Battery SOC.yaml`**: NON e' un'automazione
   importabile. Crea l'helper `input_number.pi30_battery_soc_calcolato`
   da UI (Impostazioni > Dispositivi e servizi > Helper) seguendo i
   valori indicati nel file, oppure incollane lo YAML in
   `configuration.yaml` sotto `input_number:`.
2. **`Automation - PI30 Battery SOC Coulomb Counting.yaml`**: import
   normale in Impostazioni > Automazioni > Modifica in YAML. Fa
   l'integrazione e la ricalibrazione descritte sopra.
3. **`Sensor - PI30 Battery SOC Calcolato.yaml`**: NON e' un'automazione.
   Va incollato in `configuration.yaml` sotto la chiave `template:`
   (o unito alla sezione `template:` che hai gia', se esiste). Espone
   il valore come sensore vero e proprio, `device_class: battery`,
   cosi' e' utilizzabile in dashboard/grafici come qualsiasi altro
   sensore SOC.

Dopo aver installato tutto e tre avrai `sensor.pi30_battery_soc_calcolato`
(nome esatto dipende dall'unique_id/entity_id assegnato da HA, verifica
in Impostazioni > Entita').

## Taratura

- **Capacita' pacco**: 155Ah, impostata nella variabile `capacity_ah`
  dell'automazione. Se cambi/aggiungi celle, modifica solo quel
  numero.
- **Cadenza di integrazione**: 2 minuti (trigger `cadenza`). Se la
  cambi, aggiorna anche `dt_hours` nella stessa automazione
  (`dt_hours = minuti_trigger / 60`), altrimenti l'integrazione sara'
  sbagliata.
- **Margini di ricalibrazione** (0.1V sotto il float per il 100%, 0.2V
  sopra l'under-voltage per lo 0%): sono nelle variabili
  `full_threshold`/`empty_threshold`, modificabili se vuoi un
  aggancio piu' o meno "largo".

## Integrazione con l'automazione di carica/scarica esistente

Questo sensore e' pensato per affiancare, non sostituire da subito,
`sensor.heltec_pi30_battery_soc` e la logica gia' presente in
"PI30 battery management" (che oggi usa soprattutto
`sensor.goodwe_battery_state_of_charge` e le tensioni). Una volta
verificato per qualche giorno che il valore calcolato e' plausibile
(confrontalo con il comportamento reale della batteria: si stabilizza
a 100% quando sai che e' piena, scende in modo coerente sotto carico),
puoi decidere di usarlo al posto di (o insieme a) gli altri sensori
SOC nelle condizioni dell'automazione principale.
