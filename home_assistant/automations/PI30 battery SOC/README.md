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
estremi usando la tensione — ma non quella grezza, quella compensata
per la caduta resistiva interna (vedi sezione dedicata sotto),
altrimenti scatterebbe troppo presto in carica e troppo tardi in
scarica:

- **100%**: quando la tensione compensata (voltage_ocv) raggiunge la
  tensione di float del carica-batterie
  (`sensor.heltec_pi30_display_pi30_battery_float_voltage` meno 0.1V
  di margine). A quel punto la batteria e' per definizione piena,
  qualunque cosa dica il conteggio Ah.
- **0%**: quando voltage_ocv scende sotto la tensione di under-voltage
  (`sensor.heltec_pi30_display_pi30_battery_under_voltage`) piu' 0.2V
  di margine, cosi' arriviamo a 0% un po' prima che sia il BMS a
  staccare la batteria per basso voltage.

Tra questi due estremi il SOC si muove solo per integrazione della
corrente, ogni 2 minuti.

## Componenti (tutto da UI, niente `configuration.yaml`)

1. **`Helper 1 - Numero SOC calcolato.md`**: crea da UI l'helper
   "Numero" `input_number.pi30_battery_soc_calcolato`. E' il
   contenitore su cui scrive l'automazione, nessun template.
2. **`Automation - PI30 Battery SOC Coulomb Counting.yaml`**: import
   normale in Impostazioni > Automazioni > Modifica in YAML (questo
   si' e' un import YAML, ma resta dentro l'editor delle automazioni,
   non tocca `configuration.yaml`). Fa l'integrazione e la
   ricalibrazione descritte sopra.
3. **`Helper 2 - Sensore template SOC calcolato.md`**: crea da UI
   l'helper "Template > Sensor" `sensor.pi30_battery_soc_calcolato`,
   che legge l'Helper 1 e lo
   espone come sensore batteria vero e proprio (`device_class:
   battery`), utilizzabile in dashboard/grafici come qualsiasi altro
   sensore SOC.

Crea gli helper nell'ordine 1 poi 2 (il 2 legge l'entity_id del 1).
Dopo aver creato tutti e tre avrai `sensor.pi30_battery_soc_calcolato`
(nome esatto dipende dall'entity_id assegnato da HA, verifica in
Impostazioni > Entita').

4. **`Script - PI30 Battery SOC Ricalibra da tensione.yaml`** (opzionale
   ma consigliato al primo avvio): import in Impostazioni >
   Automazioni e scene > Script > Modifica in YAML. Da lanciare una
   tantum subito dopo aver creato l'Helper 1, per non partire da 0%:
   interpola linearmente la tensione attuale tra i due estremi reali
   (under-voltage+0.2V = 0%, float-0.1V = 100%) e imposta subito
   l'Helper 1 a quella stima, invece di aspettare che il coulomb
   counting risalga da zero o che il pacco tocchi uno dei due estremi.
   E' una retta, non la vera curva del LiFePO4: va bene come punto di
   partenza, non come sostituto del coulomb counting. Rilanciabile in
   qualsiasi momento se sospetti che il contatore abbia derivato
   parecchio.

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

### Taratura della resistenza interna (`internal_resistance_ohm`)

Stessa tensione di pacco, correnti diverse, SOC vero molto diverso:
27.5V con pochi Ampere e' quasi 100%, 27.2V a 39A in carica puo' essere
un SOC decisamente piu' basso, perche' la corrente "gonfia" (in carica)
o "sgonfia" (in scarica) la tensione misurata rispetto alla vera
tensione a riposo (OCV). Sia l'automazione che lo script correggono
questo effetto con:

```
voltage_ocv = voltage - (current * internal_resistance_ohm)
```

(stessa convenzione di segno del sensore corrente: positiva in carica,
negativa in scarica — la formula funziona in entrambi i versi senza
bisogno di due rami separati).

`internal_resistance_ohm` e' impostato a `0.006` (6 mOhm) in entrambi
i file: e' una stima di massima per un pacco 8S di grandi celle
prismatiche, NON una misura reale del tuo pacco. Per tararlo davvero
servono due letture di `sensor.heltec_pi30_battery_voltage` e
`sensor.heltec_pi30_battery_current` prese a pochi minuti di distanza
(cosi' il SOC vero non fa in tempo a cambiare) ma a correnti diverse
(es. una a carica forte, una quasi a riposo o in scarica):

```
R ≈ (V1 - V2) / (I1 - I2)
```

Dammi due coppie (tensione, corrente) cosi' fatte e calcolo il valore
giusto da mettere al posto di `0.006` in entrambi i file.

## Verso una tabella Volt/SOC vera (multi-punto, carica/scarica separati)

Lo script di ricalibrazione sopra usa solo una retta a 2 punti (gli
estremi configurati sull'inverter), non la vera curva a S del LiFePO4:
va bene come stima di partenza, ma a meta' carica puo' sbagliare di
parecchio rispetto alla realta'. Per costruire una tabella vera,
multi-punto, con curve separate per carica e scarica, servono coppie
reali (tensione, corrente, e idealmente un SOC di riferimento) prese
dallo storico: dove la corrente e' vicina a 0 (batteria a riposo) la
tensione letta e' gia' un buon punto della curva "vera"; nei tratti
sotto carico si puo' stimare la resistenza interna del pacco
confrontando come la tensione si sposta al variare della corrente a
parita' di SOC (coulomb counting) nello stesso intervallo di tempo.

Per farlo servono dati che da questa sessione non posso recuperare da
solo (il connettore Home Assistant qui espone solo controlli live, non
lo storico/le statistiche). Due strade:

- **Esporta tu lo storico**: da Home Assistant, Impostazioni >
  Cronologia (o Strumenti per sviluppatori > Statistiche), esporta
  `sensor.heltec_pi30_battery_voltage` e
  `sensor.heltec_pi30_battery_current` per un periodo che copra sia
  una carica completa che una scarica, e passami un po' di
  coppie/tuple (tensione, corrente, e se lo sai anche il SOC
  approssimativo in quel momento).
- **La tabella che pensavi di avermi gia' dato**: era in un'altra
  sessione di questa chat, a cui questa non ha accesso — se la ritrovi
  (anche solo i punti principali, specificando se erano presi in
  carica, scarica o a riposo), incollamela qui e la integro
  nell'automazione al posto della retta a 2 punti.

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
