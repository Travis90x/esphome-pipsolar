# SOC LiFePO4 8S (tensione + corrente)

*[English version](README.en.md)*

## Perché non basta la tensione

Il pacco LiFePO4 8S ha una curva Volt/SOC molto piatta tra il 20% e
l'80% circa: pochi centesimi di volt corrispondono a decine di punti
percentuali di SOC. In più quella curva "si sposta" in base a quanta
corrente sta assorbendo o erogando la batteria in quel momento (caduta
resistiva interna): la stessa tensione misurata può corrispondere a
SOC diversi a seconda che la batteria stia caricando forte, scaricando
forte o sia a riposo. Un sensore SOC basato solo sulla tensione
istantanea (come `sensor.heltec_pi30_battery_soc`, quello letto dal
protocollo PI30) è quindi impreciso proprio nel mezzo della curva,
dove serve di più.

## Come funziona questa soluzione

Invece di leggere il SOC dalla tensione, si integra nel tempo la
corrente di `sensor.heltec_pi30_battery_current` (positiva in carica,
negativa in scarica: è già così per questo sensore) rispetto alla
capacità nominale del pacco (155Ah): è il classico "coulomb counting"
usato dai BMS.

Il problema del coulomb counting puro è che accumula errore nel tempo
(deriva). Per eliminarlo, la stima viene "agganciata" ai due estremi
usando la tensione — ma non quella grezza, quella compensata per la
caduta resistiva interna (vedi sezione dedicata sotto), altrimenti
scatterebbe troppo presto in carica e troppo tardi in scarica:

- **100%**: quando la tensione compensata (voltage_ocv) raggiunge la
  tensione di float del carica-batterie
  (`sensor.heltec_pi30_display_pi30_battery_float_voltage` meno 0.1V
  di margine). A quel punto la batteria è per definizione piena,
  qualunque cosa dica il conteggio Ah.
- **0%**: quando voltage_ocv scende sotto la tensione di under-voltage
  (`sensor.heltec_pi30_display_pi30_battery_under_voltage`) più 0.2V
  di margine, così arriviamo a 0% un po' prima che sia il BMS a
  staccare la batteria per basso voltaggio.

Tra questi due estremi il SOC si muove solo per integrazione della
corrente, ogni 2 minuti.

## Componenti (tutto da UI, niente `configuration.yaml`)

Le automazioni, lo script e gli helper sono in inglese (alias,
descrizioni, testi nei campi UI): questo file e la sua versione
inglese sono l'unica documentazione bilingue.

1. **`Helper 1 - SOC Calculated Number.md`**: crea da UI l'helper
   "Numero" `input_number.pi30_battery_soc_calculated`. È il
   contenitore su cui scrive l'automazione, nessun template.
2. **`Automation - PI30 Battery SOC Coulomb Counting.yaml`**: import
   normale in Impostazioni > Automazioni > Modifica in YAML (resta
   dentro l'editor delle automazioni, non tocca
   `configuration.yaml`). Fa l'integrazione e la ricalibrazione
   descritte sopra.
3. **`Helper 2 - SOC Calculated Template Sensor.md`**: crea da UI
   l'helper "Template > Sensor" `sensor.pi30_battery_soc_calculated`,
   che legge l'Helper 1 e lo espone come sensore batteria vero e
   proprio (`device_class: battery`), utilizzabile in
   dashboard/grafici come qualsiasi altro sensore SOC.
4. **`Script - PI30 Battery SOC Recalibrate from Voltage.yaml`**
   (opzionale ma consigliato al primo avvio): import in Impostazioni >
   Automazioni e scene > Script > Modifica in YAML. Da lanciare una
   tantum subito dopo aver creato l'Helper 1, per non partire da 0%:
   interpola linearmente la tensione compensata tra i due estremi
   reali (under-voltage+0.2V = 0%, float-0.1V = 100%) e imposta subito
   l'Helper 1 a quella stima, invece di aspettare che il coulomb
   counting risalga da zero o che il pacco tocchi uno dei due estremi.
   È una retta, non la vera curva del LiFePO4: va bene come punto di
   partenza, non come sostituto del coulomb counting quotidiano — non
   rilanciarlo di routine (vedi avviso nella descrizione dello
   script).

Crea gli helper nell'ordine 1 poi 2 (il 2 legge l'entity_id del 1).
Dopo aver creato tutto avrai `sensor.pi30_battery_soc_calculated`
(nome esatto dipende dall'entity_id assegnato da HA, verifica in
Impostazioni > Entità).

## Taratura

- **Capacità pacco**: 155Ah, impostata nella variabile `capacity_ah`
  dell'automazione. Se cambi/aggiungi celle, modifica solo quel
  numero.
- **Cadenza di integrazione**: 2 minuti (trigger `cadence`). Se la
  cambi, aggiorna anche `dt_hours` nella stessa automazione
  (`dt_hours = minuti_trigger / 60`), altrimenti l'integrazione sarà
  sbagliata.
- **Margini di ricalibrazione** (0.1V sotto il float per il 100%, 0.2V
  sopra l'under-voltage per lo 0%): sono nelle variabili
  `full_threshold`/`empty_threshold`, modificabili se vuoi un
  aggancio più o meno "largo".

### Taratura della resistenza interna (`internal_resistance_ohm`)

Stessa tensione di pacco, correnti diverse, SOC vero molto diverso:
27.5V con pochi Ampere è quasi 100%, 27.2V a 39A in carica può essere
un SOC decisamente più basso, perché la corrente "gonfia" (in carica)
o "sgonfia" (in scarica) la tensione misurata rispetto alla vera
tensione a riposo (OCV). Sia l'automazione che lo script correggono
questo effetto con:

```
voltage_ocv = voltage - (current * internal_resistance_ohm)
```

(stessa convenzione di segno del sensore corrente: positiva in carica,
negativa in scarica — la formula funziona in entrambi i versi senza
bisogno di due rami separati).

**Valore attuale: `internal_resistance_ohm = 0.0095` (9.5 mOhm)**,
tarato sul pacco reale a partire dallo storico esportato dal BMS JK
(JK-B2A8S20P). Il BMS **non è collegato via RS485** né in altro modo
a Home Assistant o all'ESP32: il dato è stato ottenuto esportando lo
storico dei log dall'app JK sul telefono e passandolo qui per
l'analisi.

Metodo: nel log ogni volta che scatta "Cell XX over charge
protection" il caricabatterie viene interrotto e 2-3 secondi dopo
arriva "protection is released" — in questa finestra così breve il
SOC vero (colonna "SOC Cap. Remain (AH)" del BMS) non fa in tempo a
cambiare, ma la corrente crolla da ~35-39A (carica) a circa 0/-0.6A.
Sono quindi coppie (V1,I1)/(V2,I2) a parità di SOC, perfette per
`R ≈ ΔV/ΔI`. Nel log ce n'erano 19 di questo tipo; mediando ΔV e ΔI
pesati (somma ΔV / somma ΔI, più robusto della media dei singoli
rapporti) viene R ≈ 9.5 mOhm, con i singoli campioni compresi tra
~7 e ~14 mOhm (rumore dovuto alla risoluzione di 0.01V del log).

Convalida incrociata con lo stesso log:
- Quando la corrente è vicina a 0 e il SOC del BMS è vicino al 100%,
  la tensione di pacco si assesta intorno a 27.5-27.6V: conferma che
  l'ancoraggio "float_voltage=27.5V → 100%" è corretto.
- L'unico evento di scarica profonda registrato (SOC BMS a 0.0Ah)
  mostra 21.41V: molto più basso della soglia operativa di sicurezza
  usata per lo 0% (under_voltage+0.2V = 24.0V), a conferma che quel
  margine di sicurezza è abbondante rispetto al vero fondo scala del
  pacco (non è un rischio, è intenzionalmente conservativo).

**Questo valore è considerato definitivo per ora**: non è un
placeholder in attesa di ulteriori dati, e non ci sono azioni aperte
o lavori in corso su questo punto. Se in futuro il pacco cambia
(nuove celle, cablaggio diverso) o si nota una deriva evidente, il
metodo per ricalcolare R resta lo stesso: due letture di
`sensor.heltec_pi30_battery_voltage` / `sensor.heltec_pi30_battery_current`
a correnti diverse ma ravvicinate nel tempo, oppure un nuovo export
del log del BMS con eventi simili a quelli usati qui.

## Possibile sviluppo futuro: BMS collegato via RS485

Il BMS JK-B2A8S20P fa già un proprio coulomb counting interno
(colonne "SOC Cap. Remain (AH)" / "SOC Full Charge Cap. (AH)" nel
log), probabilmente più accurato di quello ricostruito qui
(calibrazione di fabbrica, compensazione temperatura, bilanciamento
cella-per-cella). In futuro si potrebbe collegare il BMS all'ESP32
via RS485 (o Bluetooth) e leggere il suo SOC direttamente, il che
potrebbe sostituire in tutto o in parte questa automazione.

**Per ora questo non è un lavoro in corso**: è solo un'idea per il
futuro, non pianificata né iniziata. La soluzione attuale (tensione +
corrente, con la resistenza interna tarata come sopra) è considerata
sufficientemente buona e stabile.

## Integrazione con l'automazione di carica/scarica esistente

Questo sensore è pensato per affiancare, non sostituire da subito,
`sensor.heltec_pi30_battery_soc` e la logica già presente in
"PI30 battery management" (che oggi usa soprattutto
`sensor.goodwe_battery_state_of_charge` e le tensioni). Una volta
verificato per qualche giorno che il valore calcolato è plausibile
(confrontalo con il comportamento reale della batteria: si stabilizza
a 100% quando sai che è piena, scende in modo coerente sotto carico),
puoi decidere di usarlo al posto di (o insieme a) gli altri sensori
SOC nelle condizioni dell'automazione principale.
