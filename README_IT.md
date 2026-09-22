# esphome-pipsolar

![GitHub actions](https://github.com/Travis90x/esphome-pipsolar/actions/workflows/ci.yaml/badge.svg)
![GitHub stars](https://img.shields.io/github/stars/Travis90x/esphome-pipsolar)
![GitHub forks](https://img.shields.io/github/forks/Travis90x/esphome-pipsolar)

🇬🇧 **[English version available here / Versione inglese disponibile qui](README.md)**

Configurazioni ESPHome per monitorare e controllare un inverter solare Voltronic/PIP via RS232.

Fork di [syssi/esphome-pipsolar](https://github.com/syssi/esphome-pipsolar).
Grazie a [@andreashergert1984](https://github.com/andreashergert1984) per il lavoro originale.

## Dispositivi supportati

### pipsolar (PI30, protocollo Q-command)

`pipsolar` è un **componente core di ESPHome** — è incluso in ESPHome stesso,
quindi le configurazioni PI30 non richiedono nessun componente esterno.

* Voltronic Axpert / Axpert MAX e unità compatibili
* Qualsiasi inverter il cui comando `QPI` risponde `(PI30`
* Verificato qui su un'unità 24V / 3.2kVA (`(PI30`, firmware `VERFW:00007.00`)

### pip8048 (protocollo Q-command) — componente esterno

* Inverter fotovoltaico compatibile PIP4048
* Axpert King II 6.2KW TWIN (segnalato da [@voronin10](https://github.com/syssi/esphome-pipsolar/issues/196))
* Powmr 4.2KW (segnalato da [@Martyn911](https://github.com/syssi/esphome-pipsolar/issues/231))

### pip2424mse1 (protocollo Q-command, esteso) — componente esterno

* PIP2424MSE1 e inverter compatibili

### pi18 (protocollo PI18, framing `^P`/`^D`) — componente esterno

* MPP Solar LV5048 Hybrid V2
* SunGoldPower 6048
* Voltronic InfiniSolar V 4 (3.6 kW / 5.6 kW / 6 kW)
* AXIOMA 5 kW
* Unità MppSolar compatibili che rispondono a `^P005GS`

## Struttura del repository

```
examples/
  esp32/
    pi18/            pip2424mse1/      pip8048/
    pipsolar/        configurazioni PI30 (componente core)
    heltec-pi30/     PI30 + display OLED SSD1306, Heltec WiFi Kit 32 V3
  esp8266/
    pi18/            pip2424mse1/      pip8048/       pipsolar/
diagnostics/         identificare un inverter/protocollo sconosciuto
components/          i componenti esterni pi18, pip2424mse1 e pip8048
docs/                documenti di protocollo del produttore
home_assistant/      dashboard e automazioni costruite sopra l'esempio heltec-pi30
tests/               inverter finti e sweep di protocollo usati dalla CI
```

Ogni cartella di esempio contiene tre file: `…-example.yaml` (la
configurazione), `…-example-debug.yaml` (aggiunge il tracciamento UART) e
`…-example-faker.yaml` (usato dalla CI per compilare senza hardware).

### Da quale esempio parto?

| Inverter / obiettivo | File |
| :-------------- | :--- |
| PI30, ESP32, solo entità | [`examples/esp32/pipsolar/esp32-pi30-pipsolar.yaml`](examples/esp32/pipsolar/esp32-pi30-pipsolar.yaml) |
| PI30, ESP32, demo upstream | [`examples/esp32/pipsolar/esp32-pipsolar-example.yaml`](examples/esp32/pipsolar/esp32-pipsolar-example.yaml) |
| PI30, ESP8266 | [`examples/esp8266/pipsolar/esp8266-pipsolar-example.yaml`](examples/esp8266/pipsolar/esp8266-pipsolar-example.yaml) |
| PI30 **con display OLED** | [`examples/esp32/heltec-pi30/`](examples/esp32/heltec-pi30/) |
| PIP8048 / Axpert King | [`examples/esp32/pip8048/esp32-pip8048-example.yaml`](examples/esp32/pip8048/esp32-pip8048-example.yaml) |
| PIP2424MSE1 | [`examples/esp32/pip2424mse1/esp32-pip2424mse1-example.yaml`](examples/esp32/pip2424mse1/esp32-pip2424mse1-example.yaml) |
| PI18 / LV5048 | [`examples/esp32/pi18/esp32-pi18-example.yaml`](examples/esp32/pi18/esp32-pi18-example.yaml) |
| Non conosco il mio protocollo | [`diagnostics/`](diagnostics/) |

### Gli esempi Heltec PI30 con display

[`examples/esp32/heltec-pi30/`](examples/esp32/heltec-pi30/) contiene due
**configurazioni di esempio complete per un Heltec WiFi Kit 32 V3**, con il
display OLED SSD1306 integrato già cablato: sette pagine rotanti (data/ora,
WiFi, batteria, carica e scarica, setpoint riletti dall'inverter, e due
grafici di tensione batteria).

| File | Gestione protocollo | Righe |
| :--- | :---------------- | ----: |
| [`heltec-pi30-display-pipsolar.yaml`](examples/esp32/heltec-pi30/heltec-pi30-display-pipsolar.yaml) | componente core `pipsolar` | 648 |
| [`heltec-pi30-display.yaml`](examples/esp32/heltec-pi30/heltec-pi30-display.yaml) | standalone, pilotato da script | 1794 |

**Parti da quello `pipsolar`.** Delega framing, CRC e polling al componente
mantenuto da ESPHome. Il file standalone vale la pena tenerlo solo se ti
servono i suoi due extra: una console che invia comandi PI30 arbitrari, e un
selettore del baud rate a runtime. Espone anche la tensione di bulk
(`PCVV`), che il componente core non espone.

Entrambi richiedono tre file accanto allo YAML che **non** sono in questo
repository: `arial.ttf`, `materialdesignicons-webfont.ttf` e
`solar_power.bmp`. Per questo sono esclusi dalla CI; entrambi sono stati
validati e compilati a mano contro ESPHome 2026.6.5 (ESP32-S3, arduino).

[`Personal-heltec-pi30-display-pipsolar.yaml`](examples/esp32/heltec-pi30/Personal-heltec-pi30-display-pipsolar.yaml)
è una terza variante, personale, di quello `pipsolar` (nome dispositivo
`heltec-inverter`, friendly name `Heltec PI30 Display`) — è la
configurazione che produce davvero la nomenclatura delle entità
(`sensor.heltec_pi30_battery_voltage`, `sensor.heltec_pi30_display_pi30_*`,
…) su cui sono costruite le automazioni Home Assistant descritte più sotto.

## Requisiti

* [ESPHome 2024.6.0 o superiore](https://github.com/esphome/esphome/releases)
* Metà di un cavo ethernet con connettore RJ45
* Modulo RS232-to-TTL (es. `MAX3232CSE`)
* Scheda ESP32 o ESP8266 generica

## Schemi

<a href="images/001.jpg" target="_blank"><img src="images/001.jpg" height="172"></a>
<a href="images/002.jpg" target="_blank"><img src="images/002.jpg" height="172"></a>
<a href="images/004.jpg" target="_blank"><img src="images/004.jpg" height="172"></a>
<a href="images/005.jpg" target="_blank"><img src="images/005.jpg" height="172"></a>

```
               RS232                     UART-TTL
┌──────────┐              ┌──────────┐                ┌─────────┐
│          │              │          │<----- RX ----->│         │
│          │<---- TX ---->│  RS232   │<----- TX ----->│ ESP32/  │
│   PIP    │<---- RX ---->│  to TTL  │<----- GND ---->│ ESP8266 │
│          │<---- GND --->│  module  │<-- 3.3V VCC -->│         │<--- VCC
│          │              │          │                │         │<--- GND
└──────────┘              └──────────┘                └─────────┘
```

### Connettore RJ45

| Pin     | Funzione     | Pin MAX3232       | Colore T-568B |
| :-----: | :----------- | :---------------- | :------------|
|    1    | TX           | P13 (RIN1)        | Bianco-Arancio |
|    2    | RX           | P14 (DOUT1)       | Arancio       |
|    3    |              |                   |              |
|    4    | VCC 12V      | -                 | Blu         |
|    5    |              |                   |              |
|    6    |              |                   |              |
|    7    |              |                   |              |
|    8    | GND          | P15 (GND)         | Marrone        |

Attenzione ai diversi colori del pinout RJ45 ([T-568A vs. T-568B](images/rj45-colors-t568a-vs-t568.png)).

L'inverter fornisce +12V sul pin 4 o 7 a seconda del modello. Puoi usare un
economico convertitore DC-DC per alimentare l'ESP a 3.3V.

[La fonte del pinout è qui](docs/HS_MS_MSX%20RS232%20Protocol.pdf).

### MAX3232

| Pin          | Etichetta    | ESPHome     | Esempio ESP8266  | Esempio ESP32 |
| :----------- | :----------- | :---------- | :--------------- | :------------ |
| P11 (DIN1)   | TXD          | `tx_pin`    | `GPIO4`          | `GPIO16`      |
| P12 (ROUT1)  | RXD          | `rx_pin`    | `GPIO5`          | `GPIO17`      |
| P16 (VCC)    | VCC          |             |                  |               |
| P15 (GND)    | GND          |             |                  |               |

## Installazione

### A. Home Assistant (add-on ESPHome) — senza `pip3 install esphome`

Se usi Home Assistant **non** devi installare ESPHome tu stesso. L'add-on
**ESPHome Builder** compila e flasha per te, quindi non serve installare
nulla sull'host di Home Assistant.

1. **Impostazioni → Add-on → Store degli add-on → ESPHome Builder →
   Installa**, poi Avvia e apri la Web UI.
2. **+ Nuovo dispositivo → Salta** e dagli un nome. Questo crea
   `/config/esphome/<nome>.yaml` e aggiunge la chiave di crittografia API e
   la password OTA al tuo `secrets.yaml`.
3. Apri il nuovo dispositivo con **Modifica** e incolla l'esempio scelto
   dalla tabella sopra. Adatta `tx_pin` / `rx_pin` alla tua scheda.
4. Mantieni o aggiungi queste righe così l'add-on può parlare col
   dispositivo:

   ```yaml
   api:
     encryption:
       key: !secret api_encryption_key   # creata al passo 2
   ```

5. **Installa → Collega a questo computer** per il primo flash, poi
   **Via WiFi** per ogni aggiornamento successivo.

#### PI30: nient'altro da installare

`pipsolar` fa parte di ESPHome, quindi una configurazione PI30 funziona
così com'è. Il blocco `external_components:` serve solo per **pip8048**,
**pip2424mse1** e **pi18**, che vivono in questo repository:

```yaml
external_components:
  - source: github://Travis90x/esphome-pipsolar@main
    refresh: 0s
```

L'add-on li scarica in fase di compilazione — di nuovo, nulla da installare
a mano.

> **Secrets.** L'add-on mantiene un unico `/config/esphome/secrets.yaml`
> condiviso, quindi `!secret wifi_ssid` e simili si risolvono
> automaticamente.

### B. Standalone (CLI ESPHome) — con `pip3 install esphome`

Usa questa strada se compili da un PC invece che da Home Assistant.

```bash
# Installa esphome
pip3 install esphome

# Clona questo repository
git clone https://github.com/Travis90x/esphome-pipsolar.git
cd esphome-pipsolar

# Scegli l'esempio che vuoi compilare
CONFIG=examples/esp32/pipsolar/esp32-pi30-pipsolar.yaml

# ESPHome cerca secrets.yaml ACCANTO al file di configurazione
cat > "$(dirname $CONFIG)/secrets.yaml" <<EOF
wifi_ssid: MY_WIFI_SSID
wifi_password: MY_WIFI_PASSWORD

mqtt_host: MY_MQTT_HOST
mqtt_username: MY_MQTT_USERNAME
mqtt_password: MY_MQTT_PASSWORD
EOF

# Valida, compila, carica e segui i log
esphome run "$CONFIG"
```

Per compilare un esempio contro i componenti nella tua **copia di lavoro**
invece di quelli pubblicati, sovrascrivi la sorgente — gli script helper
fanno l'aritmetica dei percorsi per te:

```bash
./test-esp32.sh run examples/esp32/pip8048/esp32-pip8048-example.yaml
./test-esp8266.sh config examples/esp8266/pi18/esp8266-pi18-example.yaml
```

Dai un'occhiata alla [documentazione ufficiale del componente pipsolar](https://esphome.io/components/pipsolar.html) per dettagli aggiuntivi.

## Automazioni Home Assistant (PI30 + pacco LiFePO4 8S)

Questa sezione documenta il lato Home Assistant costruito sopra il
dispositivo `pipsolar` della sezione precedente — dashboard e due
automazioni che vivono in [`home_assistant/`](home_assistant/). Sostituisce
i README per cartella che stavano sotto `home_assistant/automations/`:
nessuno naviga dentro cartelle annidate, quindi tutto il necessario è
riportato qui. I file YAML veri e propri (importati tramite le schermate
"Modifica in YAML" di Home Assistant) restano nelle loro cartelle e sono
linkati da ciascuna sottosezione qui sotto.

### Il dispositivo PI30 in Home Assistant

Entrambe le automazioni sotto assumono la nomenclatura delle entità
prodotta da
[`Personal-heltec-pi30-display-pipsolar.yaml`](examples/esp32/heltec-pi30/Personal-heltec-pi30-display-pipsolar.yaml)
(nome dispositivo `heltec-inverter`, friendly name `Heltec PI30 Display`,
vedi "Gli esempi Heltec PI30 con display" sopra):
`sensor.heltec_pi30_battery_voltage`, `sensor.heltec_pi30_battery_current`
(positiva in carica, negativa in scarica), e la famiglia
`sensor.heltec_pi30_display_pi30_*` — i setpoint QPIRI riletti dall'inverter
(tensione di float/under/recharge/redischarge/bulk, correnti massime di
carica, ecc.) insieme alle loro controparti scrivibili
`number.heltec_pi30_display_pi30_set_*` / `select.heltec_pi30_display_pi30_set_*`.

[`home_assistant/dashboard/inverter_ita.yaml`](home_assistant/dashboard/inverter_ita.yaml)
e [`inverter_eng.yaml`](home_assistant/dashboard/inverter_eng.yaml) sono
sezioni di dashboard Lovelace già pronte (italiano / inglese) che coprono
priorità della sorgente di uscita, modalità del dispositivo, setpoint di
corrente di carica, tensioni di batteria, i sensori SOC descritti sotto, e
diagnostica (cattura grezza dei frame TX/RX). Incollale nella modalità YAML
di una dashboard.

### Modulazione dinamica della carica da rete

File: [`home_assistant/automations/PI30 battery management/`](<home_assistant/automations/PI30 battery management/>)
- `Automation - PI30 Battery Charging Intelligent Modulation.yaml`
- `Script Battery to charge.yaml`, `Script Battery to discharge.yaml`, `Script Battery to keep.yaml`

Obiettivo: decidere, ogni 10 minuti (più all'avvio e ai cambi rilevanti dei
sensori), se il PI30 debba caricare il suo pacco LiFePO4 dalla rete,
scaricarlo, o semplicemente mantenerlo — e se in carica, quanti Ampere
prelevare dalla rete — in base a un inverter/batteria Goodwe presente sullo
stesso impianto (usato come segnale "c'è potenza solare di scorta in questo
momento") e alla tensione del pacco PI30 come rete di sicurezza.

Sensori letti:

| Entità | Significato |
| :--- | :--- |
| `sensor.goodwe_battery_state_of_charge` | SOC Goodwe |
| `sensor.goodwe_battery_voltage` | Tensione Goodwe |
| `sensor.potenza_contatore` | potenza al contatore/rete |
| `sensor.goodwe_battery_power` | Potenza batteria Goodwe |
| `sensor.heltec_pi30_display_pi30_max_utility_charging_current` | corrente di carica da rete confermata dal PI30 |
| `sensor.heltec_pi30_display_pi30_max_total_charging_current` | corrente totale confermata dal PI30 |
| `sensor.heltec_pi30_battery_voltage` | Tensione batteria PI30 |
| `number.heltec_pi30_display_pi30_set_battery_under_voltage` | PSDV, cut-off batteria impostato sull'inverter |

`max_manual_current` (default `60`) e `battery_keep_under_voltage` (=
PSDV + 0.2V) sono semplici variabili dentro l'automazione, **non helper** —
per cambiarle, apri l'automazione in modalità YAML e modifica direttamente
i numeri.

Scritture: `select.heltec_pi30_display_pi30_set_max_utility_charging_current`,
`select.heltec_pi30_display_pi30_set_max_total_charging_current`,
`script.pi30_batteria_da_caricare` (CARICA), `script.pi30_batteria_da_scaricare`
(SCARICA), `script.pi30_batteria_da_mantenere` (MANTIENI — usato al posto di
SCARICA quando la batteria PI30 è già vicina al cut-off).

Step di corrente da rete: `2 10 20 30 40 50 60`.

<details>
<summary>Logica decisionale completa (clicca per espandere)</summary>

```
Segnale favorevole OR nulla noto
SE
	SOC or VOLT goodwe noti (almeno 1 dei due) e favorevole (batteria goodwe carica E potenza di carica al minimo + NON consuma tanto la goodwe + NON preleva tanto dalla rete) =
	    SE SOC è ignoto, VOLT dev essere favorevole e viceversa.
		sensor.goodwe_battery_state_of_charge = 100 (>99, non ci sono decimali e Home assistant non accetta =100, ma solo above e below) (goodwe carica al 100%)
		OR
		sensor.goodwe_battery_voltage |float >= 54 (goodwe sicuramente carica al 100%)
		OR
		(goodwe carica al 100% ma si sta scaricando)
			sensor.goodwe_battery_state_of_charge > 99
			AND
			sensor.goodwe_battery_voltage |float < 53
		OR
			SE sensor.potenza_contatore E sensor.goodwe_battery_power NOTI
				(Potenza carica al minimo, e servono ENTRAMBE le condizioni favorevoli: NON preleva tanto dalla rete E NON consuma tanto la goodwe)
				(VALORI PIU' ALTI di MODULAZIONE per avere isteresi)
				(CORREZIONE: AND e non OR tra le due soglie - altrimenti basterebbe una sola condizione favorevole
				per restare in carica, mentre piu' sotto la condizione di SCARICA usa OR sulle stesse due soglie:
				le due condizioni risulterebbero vere insieme se un solo sensore e' sfavorevole, e CARICA
				vincerebbe sempre perche' valutata per prima)
				Potenza carica sensor.heltec_pi30_display_pi30_max_utility_charging_current = 2 A
				AND
					sensor.potenza_contatore < 500
					AND
					sensor.goodwe_battery_power < 200
			ALTRIMENTI (sensor.potenza_contatore E sensor.goodwe_battery_power IGNOTI)
				CARICA con "paracadute" = potenza 2A
				MODIFICA select.heltec_pi30_display_pi30_set_max_utility_charging_current = 2

ALLORA
	CARICA = script.pi30_batteria_da_caricare
	E
	MODULA POTENZA DI CARICA:
	LEGGI sensor.heltec_pi30_display_pi30_max_total_charging_current
	SE sensor.heltec_pi30_display_pi30_max_total_charging_current < 60
		MODIFICA select.heltec_pi30_display_pi30_set_max_total_charging_current
		IMPOSTANDO A 60
	SE sensor.potenza_contatore < 300 E sensor.goodwe_battery_power < 200

	(pi30_max_utility_charging_current può essere < max_total_charging_current che è il limite di utility+solar charging_current - il Solar per ora non lo uso)
	ALLORA (AUMENTA STEP)
		LEGGI sensor.heltec_pi30_display_pi30_max_utility_charging_current
		MODIFICA select.heltec_pi30_display_pi30_set_max_utility_charging_current
		AUMENTANDO LO STEP (es: se sta a 2 vai a 10, se 10 ->20, se 60 rimani a 60 ecc.)
		(GLI STEP SONO: 2 10 20 30 40 50 60)
		LO STEP NON PUÒ COMUNQUE SUPERARE max_manual_current (MAX MANUAL CURRENT)
	ALTRIMENTI (DIMINUISCI STEP) (se uno dei due non è rispettato, c'è qualcosa che preleva troppo: sensor.potenza_contatore < 300 E sensor.goodwe_battery_power)
		LEGGI sensor.heltec_pi30_display_pi30_max_utility_charging_current
		MODIFICA select.heltec_pi30_display_pi30_set_max_utility_charging_current
		DIMINUISCI LO STEP (es: se sta a 2 rimani a 2, se 10 vai a 2, se 60 vai a 50 ecc.)
		(GLI STEP SONO: 2 10 20 30 40 50 60)

ALTRIMENTI
	SE
		SOC or VOLT goodwe ignoti
		E
		sensor.potenza_contatore < 300 E sensor.goodwe_battery_power < 200
	ALLORA
		CARICA con "paracadute" = potenza 2A
		MODIFICA select.heltec_pi30_display_pi30_set_max_utility_charging_current = 2

ALTRIMENTI
	SE
		sensor.heltec_pi30_battery_voltage < battery_keep_under_voltage
		(dove battery_keep_under_voltage = number.heltec_pi30_display_pi30_set_battery_under_voltage + 0.2)
	ALLORA
		MANTIENI = script.pi30_batteria_da_mantenere
		(la batteria PI30 è già vicina al cut-off: non scaricarla ulteriormente)
	ALTRIMENTI
		SCARICA = script.pi30_batteria_da_scaricare

VUOL DIRE CHE
SE
	sensor.heltec_pi30_display_pi30_max_utility_charging_current = 2A
	E
	sensor.potenza_contatore > 500 OR sensor.goodwe_battery_power > 200

ALLORA
	NONOSTANTE "Potenza carica al minimo" E "NON consuma tanto la goodwe" E "NON preleva tanto dalla rete"
	questo non basta, quindi SCARICA
```

**MAX MANUAL CURRENT.** Non è un helper: è una variabile fissa dentro
l'automazione stessa, in `action > variables > max_manual_current` (di
default 60). Per cambiarla, apri l'automazione in modalità YAML, modifica
quel numero e salva. Se impostata ad esempio a 40: la fase AUMENTA STEP non
salirà mai oltre 40A; se la corrente è già sopra 40A (perché il limite è
stato abbassato mentre il sistema stava caricando a uno step più alto),
l'automazione la riporta subito al gradino valido più alto non superiore a
40 (quindi 40).

**Trigger:**

```yaml
trigger:
  - trigger: homeassistant
    id: avvio
    event: start
  - trigger: time_pattern
    id: controllo_10_minuti
    minutes: /10
  - trigger: state
    id: batteria_stabile
    entity_id:
      - sensor.goodwe_battery_state_of_charge
      - sensor.goodwe_battery_voltage
      - sensor.potenza_contatore
      - sensor.goodwe_battery_power
```

</details>

### SOC reale via conteggio dell'energia (tensione + energia entrata/uscita)

File: [`home_assistant/automations/PI30 battery SOC/`](<home_assistant/automations/PI30 battery SOC/>)
- `Automation - PI30 Battery SOC Energy Counting.yaml`
- `Script - PI30 Battery SOC Recalibrate from Voltage.yaml`

Il pacco LiFePO4 8S ha una curva Volt/SOC molto piatta tra il 20% e l'80%
circa: pochi centesimi di volt corrispondono a decine di punti percentuali
di SOC. In più quella curva si sposta in base a quanta corrente sta
assorbendo o erogando la batteria in quel momento (caduta resistiva
interna). Un sensore SOC basato solo sulla tensione istantanea (come
`sensor.heltec_pi30_battery_soc`, letto dal protocollo PI30) è quindi
impreciso proprio nel mezzo della curva, dove serve di più.

**Come funziona.** Invece di leggere il SOC dalla tensione, si conta
l'energia che entra ed esce dal pacco rispetto alla sua capacità utile in
kWh: una volta al minuto (e all'avvio, e ogni volta che esegui
l'automazione a mano) legge la potenza di carica e di scarica della
batteria (`sensor.heltec_pi30_batteria_potenza_carica` e
`sensor.heltec_pi30_batteria_potenza_scarica`, gli stessi due sensori su cui
sono costruiti i contatori di kWh totali) e la moltiplica per il tempo reale
trascorso dall'esecuzione precedente. 26.6V a 5A per quattro ore non dicono
nulla sul SOC; 0.5 kWh mossi in quattro ore sì. Il conteggio puro deriva nel
tempo (e si porta dietro ogni errore sulla capacità), quindi
la stima viene riagganciata ai due estremi usando una tensione compensata
per la caduta resistiva interna anziché quella grezza (`voltage_ocv =
voltage - current * internal_resistance_ohm`, stessa convenzione di segno
del sensore corrente):

- **100%** (trigger `full_hold`) quando `voltage_ocv` raggiunge la soglia
  di pieno **e** il pacco non è sotto spinta (`current <= tail_current_a`,
  `0` di default: fermo o in scarica), **entrambe vere ininterrottamente
  per 5 minuti**. La soglia di pieno è la *più alta* tra la tensione di
  float (`sensor.heltec_pi30_display_pi30_battery_float_voltage` meno 0.1V
  di margine) e un pavimento fisso di **27.2V** (`full_floor_v`, 3.40V per
  cella × 8). Il pavimento serve perché la tensione di float è quella che
  qualcuno ha programmato sull'inverter: con un float di 26.8V o meno,
  "alla tensione di float" è il tratto piatto della curva LiFePO4 (26.6V a
  riposo può essere qualunque cosa tra il 60% e l'85%) e l'aggancio
  certificherebbe come 100% un pacco a metà. Sotto i 3.40V per cella una
  cella LiFePO4 a riposo non è piena, qualunque cosa dicano le impostazioni
  del caricatore. La seconda metà è il test che conta:
  se il pacco tiene la tensione di float mentre nessuno lo sta caricando,
  quella tensione viene dal suo stato di carica, quindi è davvero pieno —
  senza bisogno di alcun modello. Un pacco che sta ancora assorbendo
  corrente potrebbe essere semplicemente tenuto lassù dal
  carica-batterie. Attenzione: nemmeno una corrente di carica *bassa* è
  prova che il pacco sia pieno — caricare a 2A perché non c'è surplus
  fotovoltaico non è la stessa cosa di una carica che è calata perché la
  batteria non accetta più nulla. Per questo la soglia di default è 0 e
  non un valore di "corrente di coda". Nemmeno un conteggio che dice "sono
  entrati 4.5 kWh" è una prova: si ferma a 99 e aspetta questo aggancio. I
  5 minuti di tenuta filtrano la
  carica superficiale: appena il caricatore si stacca, un pacco LiFePO4 a
  metà carica resta vicino alla tensione di carica per un minuto o due
  prima di rilassarsi alla sua tensione a riposo.
  Il flag *charging to floating mode* dell'inverter
  (`binary_sensor.heltec_pi30_display_pi30_charging_to_floating_mode`)
  è volutamente **escluso** da questo aggancio: descrive lo stadio del
  carica-batterie, non lo stato della batteria, e il PI30 lo tiene
  acceso dopo il tramonto, per tutta la notte mentre il pacco si
  scarica, finché il caricatore non torna in bulk. Usato in alternativa
  al test di tensione riscriveva 100% ogni 2 minuti per tutta la notte
  (un pacco in scarica supera sempre il test "non sotto spinta"),
  inchiodando il sensore al 100% qualunque fosse il vero stato di
  carica.
- **0%** (trigger `empty_hold`) quando `voltage_ocv` scende sotto la
  tensione di under-voltage
  (`sensor.heltec_pi30_display_pi30_battery_under_voltage`) più 0.2V di
  margine, ininterrottamente per 1 minuto, arrivando a 0% un po' prima
  che sia il BMS stesso a staccare la batteria. Il minuto di tenuta
  ignora l'abbassamento dovuto a un picco di carico (lo spunto di un
  compressore) che il modello resistivo non compensa del tutto.

Entrambi gli agganci sono trigger template di Home Assistant con una
tenuta `for:`, quindi ciascuno scrive il suo valore **una volta sola**,
sulla transizione falso → vero della sua condizione, e si riarma solo dopo
che la condizione è tornata falsa. Ogni aggancio scrive anche una riga nel
**Registro** (Logbook) con le letture su cui è scattato (tensione,
corrente, soglie di float e under-voltage, entrambi i contatori di
energia totale, SOC precedente), così un 100% o
uno 0% sbagliato si può ricondurre al momento esatto: apri il Registro e
filtra su `input_number.pi30_battery_soc_calculated`. È questo che permette
a un pacco pieno
di iniziare a contare in discesa da 100 nel momento in cui esce corrente,
invece di essere riscritto a 100 ogni 2 minuti finché la tensione resta
alta. Se il pacco è già pieno (o vuoto) quando carichi l'automazione per
la prima volta, l'aggancio aspetta l'episodio successivo: imposta l'helper
Number a mano una volta, come descritto nel setup qui sotto.

Tra i due estremi il SOC si muove solo con l'energia mossa:

```
SOC += kW_carica × charge_efficiency × ore / capacity_kwh × 100
SOC -= kW_scarica × ore / capacity_kwh × 100
```

`ore` è il tempo **misurato** dall'esecuzione precedente (dal
`last_triggered` dell'automazione stessa), limitato a 5 minuti perché un
lungo fermo non integri la potenza letta al riavvio su ore di storia
sconosciuta. `capacity_kwh` (4.5) è l'energia che il pacco *eroga* dal 100%
allo 0% (lato scarica). `charge_efficiency` (0.5) è quanta parte di ogni
kWh che il PI30 *dice* di aver immesso torna davvero fuori — **misurata su
questo impianto**, vedi "Cosa dicono due giorni di storico" più sotto; la
sola fisica darebbe circa 0.93 (carica a 27-28V, scarica a 26V, qualche
punto di perdite), ma questo inverter riporta circa il doppio della corrente
di carica che entra davvero nel pacco. L'unità
dei sensori di potenza è letta dal sensore (W o kW). Il valore è salvato con
3 decimali (agli 1-2A a cui questo pacco sta fermo di notte un passo vale
pochi centesimi di percento, che un arrotondamento a 1 decimale butterebbe
via del tutto); il sensore template lo arrotonda per la visualizzazione.

Perché non leggere direttamente i due contatori di kWh totali? Scattano ogni
10 secondi, e contare i loro scatti vuol dire eseguire l'automazione ogni 10
secondi, con registro e storico pieni di esecuzioni. Usarli una volta al
minuto richiederebbe un secondo helper per ricordare il valore del
contatore all'esecuzione precedente, e questo setup deve restare a un solo
helper. Integrare la stessa potenza una volta al minuto dà gli stessi kWh,
solo campionati ogni 60 s invece che ogni 10 s, che per una batteria non è
nessuna perdita.

Il conteggio puro non può mai *dichiarare* un pacco pieno o vuoto: in
salita si ferma a 99, in discesa a 1. Può però continuare a scendere da un
100 agganciato (o salire da uno 0 agganciato). Il contrario è volutamente
**vietato**: una qualsiasi carica porta un 100 agganciato a 99, perché un
pacco che sta ancora assorbendo energia non è più certificato pieno. Costa
un'oscillazione 100 ↔ 99 mentre l'inverter mantiene in float, e ne vale la
pena: un 100 stantio (da un aggancio sbagliato precedente, o messo a mano)
non deve restare lì mentre il pacco assorbe 5A per ore. Solo i due agganci
qui sopra scrivono esattamente 100 e esattamente 0.

**Setup — 2 helper, tutto da UI, niente `configuration.yaml`:**

Prerequisito: i sensori di potenza di carica e di scarica della batteria
`sensor.heltec_pi30_batteria_potenza_carica` e
`sensor.heltec_pi30_batteria_potenza_scarica` (W o kW, entrambi ≥ 0), più,
per le note di taratura che gli agganci scrivono nel Registro, i due
contatori di kWh totali `sensor.heltec_pi30_batteria_energia_caricata` e
`sensor.heltec_pi30_batteria_energia_scaricata` costruiti su di essi.

Entrambi gli helper sono nella stessa cartella dell'automazione, ciascuno
con la ricetta da UI e l'equivalente per `configuration.yaml`:
`Helper 1 - PI30 Battery SOC calculated (Number).yaml` e
`Helper 2 - PI30 Battery SOC calculated (Template sensor).yaml`.

1. **Helper "Numero"** (Impostazioni → Dispositivi e servizi → Helper →
   Crea helper → Numero): Nome `PI30 battery SOC calculated`, icona
   `mdi:battery-unknown`, min `0`, max `100`, passo `0.1`, unità `%`. Crea
   `input_number.pi30_battery_soc_calculated`, il contenitore del valore
   grezzo su cui scrive l'automazione. **L'entity id deve essere
   esattamente quello**: apri l'helper, icona ingranaggio, controlla "ID
   entità" e correggilo se il nome ha prodotto qualcos'altro. Se l'editor
   dell'automazione mostra "entità non trovata" accanto a
   `input_number.pi30_battery_soc_calculated`, questo helper manca e niente
   può funzionare — e il SOC che stai guardando è un altro sensore, quasi
   certamente `sensor.heltec_pi30_battery_soc` dell'inverter, che è basato
   sulla tensione e resta beato al 100% per ore. Al primo salvataggio
   impostalo a un
   valore vicino a quello letto da `sensor.heltec_pi30_battery_soc` —
   l'automazione lo riaggancerà comunque la prima volta che il pacco
   completa una carica (o si svuota). L'automazione ci scrive 3 decimali:
   il passo `0.1` riguarda solo lo slider, `set_value` non ne è limitato.
2. **Helper "Sensore basato su modello"** (Impostazioni → Dispositivi e
   servizi → Helper → Crea helper → Template → Sensor): Nome `Heltec PI30
   Display PI30 battery SOC calculated`, unità `%`, classe dispositivo
   `Batteria`, classe di stato `Misurazione`, e come **Stato**:
   ```
   {{ states('input_number.pi30_battery_soc_calculated') | float(default=0) | round(0) }}
   ```
   Crea `sensor.heltec_pi30_display_pi30_battery_soc_calculated`, il
   sensore batteria vero e proprio usato dalle dashboard in
   `home_assistant/dashboard`, utilizzabile nei grafici come qualunque
   altro sensore SOC. Crealo dopo l'helper Numero (legge quell'entity_id).

Poi importa `Automation - PI30 Battery SOC Energy Counting.yaml`
(Impostazioni → Automazioni → Modifica in YAML) per fare l'integrazione e
la ricalibrazione descritte sopra.

Facoltativamente, subito dopo aver creato l'helper Numero, lancia **una
volta sola** `Script - PI30 Battery SOC Recalibrate from Voltage.yaml`
(Impostazioni → Automazioni e scene → Script → Modifica in YAML, poi
eseguilo) così il contatore non parte da 0%: interpola linearmente la
tensione compensata tra i due estremi reali e imposta subito l'helper
Numero a quella stima. È una retta, non la vera curva del LiFePO4: va bene
come punto di partenza, non come sostituto del conteggio quotidiano.
**Non rilanciarlo di routine**: farlo ogni volta che la tensione sale un
po' riporta il sensore a essere basato sulla sola tensione istantanea,
vanificando il senso del conteggio dell'energia (vedi l'avviso nella descrizione
dello script stesso).

**Correzione con la tensione.** Il conteggio da solo non sa da dove è partito:
se è partito sbagliato (un 100 stantio, un helper creato a metà scarica)
resterebbe sbagliato fino alla carica completa successiva. Quindi ogni minuto
la tensione, compensata per la corrente con la resistenza a regime misurata su
questo pacco (11.3 mOhm), viene trasformata in SOC con una tabella ricavata da
due giorni di storico, e il conteggio viene tirato verso quel valore — solo
quando la tensione è affidabile, e solo quando è chiaramente in disaccordo:

| Tensione compensata (V) | 24.00 | 25.40 | 25.90 | 26.18 | 26.30 | 26.42 | 26.53 | 26.63 | 26.67 | 26.70 | 26.72 | 26.75 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| SOC (%) | 0 | 10 | 30 | 50 | 60 | 70 | 75 | 80 | 85 | 90 | 95 | 99 |

- **Affidabile** vuol dire in scarica o a riposo, al massimo 30A, con il
  caricatore spento da almeno 30 minuti: subito dopo una carica la carica
  superficiale fa sembrare pieno qualunque pacco, e durante la carica la
  tensione non dice nulla.
- **Chiaramente in disaccordo** vuol dire fuori dalla fascia di SOC compatibili
  con la lettura ±0.1V (il PI30 riporta passi da 0.1V). Dentro la fascia vince
  il conteggio; fuori, il conteggio recupera la differenza con una costante di
  tempo di 5 minuti (circa 1/5 al minuto).
- Sul tratto piatto in alto (85-99%) la fascia è larga circa 20 punti e la
  tensione corregge raramente; da circa l'80% in giù corregge. Esempio: 26.3V
  a -9A sono 26.40V compensati, fascia 60-74%, e un contatore fermo al 96%
  scende a circa il 74% in circa 15 minuti.
- La parte 70-99% della tabella è misurata (SOC ricostruito dai contatori di
  energia tra due cariche complete, V = 25.32 + 0.0152·SOC + 0.0113·I, residuo
  0.06V). Sotto il 70%, mai raggiunto nei dati, segue la curva LiFePO4 tipica
  fino alla tensione dell'aggancio a 0%. La correzione non scrive mai
  esattamente 100 o 0: quello resta ai due agganci.

Lo stesso modello scritto come tabella tensione × corrente (lato scarica;
durante la carica la tensione non viene usata), per confrontarlo con una
tabella fatta a mano. Ogni Ampere prelevato abbassa la lettura di circa 11
mV; la gobba piatta intorno a 26.6-26.7V è il plateau LiFePO4, dove la
tensione dice poco e decide il conteggio:

| Tensione | -30 A | -20 A | -10 A | -8 A | -2 A | 0 A |
|---|---|---|---|---|---|---|
| 24.0 | 2% | 1% | 1% | 1% | 0% | 0% |
| 24.5 | 5% | 5% | 4% | 4% | 3% | 3% |
| 25.0 | 9% | 9% | 8% | 7% | 7% | 7% |
| 25.5 | 27% | 21% | 17% | 16% | 14% | 13% |
| 26.0 | 63% | 54% | 45% | 43% | 38% | 37% |
| 26.2 | 75% | 70% | 61% | 59% | 54% | 52% |
| 26.3 | 81% | 75% | 69% | 68% | 62% | 60% |
| 26.4 | 98% | 80% | 74% | 73% | 70% | 68% |
| 26.5 | 99% | 96% | 79% | 78% | 75% | 74% |
| 26.6 | 99% | 99% | 93% | 88% | 80% | 79% |
| 26.7 | 99% | 99% | 99% | 99% | 95% | 90% |

Le righe da 26.2V in su sono misurate su questo pacco; sotto seguono la curva
LiFePO4 tipica e si possono modificare nell'automazione (`ocv_v` /
`ocv_soc`, la colonna 0 A).

**Taratura:**
- **Capacità pacco**: `capacity_kwh` (4.5 kWh, l'energia erogata dal 100%
  allo 0%) e `charge_efficiency` (0.93) nell'automazione (`actions` →
  `variables`). Entrambi si leggono dal Registro: tra uno 0% agganciato e il
  100% successivo, l'aumento del contatore di carica vale `capacity_kwh /
  charge_efficiency`; tra un 100% agganciato e lo 0% successivo, l'aumento
  del contatore di scarica vale `capacity_kwh`. Ogni riga di aggancio nel
  Registro riporta entrambi i contatori in quel momento.
- **Cadenza**: 1 minuto (trigger `cadence`). Si può cambiare liberamente: il
  tempo trascorso è misurato, nient'altro dipende da essa. Il limite di un
  singolo passo è `max_dt_hours` (5 minuti).
- **Corrente di mantenimento**: `tail_current_a` (2A, misurata: vedi sotto).
  Non alzarla oltre, o una carica volutamente a bassa corrente verrebbe
  scambiata per una carica esaurita.

**Cosa dicono due giorni di storico (20-22 set 2026: tensione, corrente e i
due contatori di kWh esportati da Home Assistant).** Tre fatti che hanno
deciso i valori qui sopra:

- **La tensione è inutile tra i due estremi.** In scarica a 3-25A il pacco
  ha letto 26.2-26.7V per tutta la notte; a riposo ha letto 26.4-26.5V
  entrambe le mattine, dopo due notti da 1.0 e 1.2 kWh. Tra "pieno" e
  "mattina" l'unica cosa che si muove è l'energia, ed è per questo che il
  SOC si conta e non si legge. La tensione torna informativa solo sopra i
  27.2V a riposo (pieno) e vicino alla soglia di under-voltage (vuoto), ed
  è esattamente lì che stanno i due agganci.
- **L'inverter mantiene a 27.5V con +2A, per ore.** Dei 587 minuti passati
  sopra 27.4V, 536 leggono esattamente +2A, 48 leggono +1A e un solo minuto
  legge 0A. Un pacco pieno non può assorbire 2A per cinque ore: è la
  lettura ad Ampere interi del PI30 di una piccola corrente di
  mantenimento. Con `tail_current_a = 0` l'aggancio al 100% non è mai
  scattato; ora è 2A, che con la soglia di 27.4V resta un test di "pieno"
  sicuro.
- **Il contatore di carica vale circa il doppio di quello di scarica tra
  gli stessi due stati.** Riposo mattutino a 26.4V → pieno: il contatore di
  carica è salito di 2.50 kWh (giorno 1) e 2.05 kWh (giorno 2). Pieno → lo
  stesso riposo a 26.4V: il contatore di scarica è salito di 1.20 e 1.11
  kWh. Il lato scarica è giusto — coincide con la potenza in uscita
  dell'inverter integrata sulle stesse notti (1.20 contro 1.27 kWh, la
  differenza sono le perdite dell'inverter) — quindi il PI30 riporta circa
  il doppio della corrente di carica che entra davvero nel pacco (39A per
  due ore, mentre il pacco poteva accettarne circa 45Ah). Da qui
  `charge_efficiency = 0.5` invece dello 0.93 da manuale. Se cambia il pacco
  o l'inverter, rifai questo controllo dalle righe che gli agganci scrivono
  nel Registro: aumento del contatore di carica tra uno 0% (o uno stato a
  riposo noto) e il 100% successivo, contro l'aumento del contatore di
  scarica al ritorno.

**Valore di partenza.** Il contatore si muove solo con l'energia, quindi ha
bisogno di un primo valore sensato: con il pacco a riposo a 26.4-26.5V dopo
una notte normale (circa 1.2 kWh prelevati dal pieno, capacità 4.5 kWh) è
all'incirca **70-75%**. Imposta l'helper Numero a mano su quel valore una
volta sola; la prima carica completa lo aggancia al 100% e da lì il
conteggio è esatto.
- **Costanti degli agganci**: `tail_current_a` (0A),
  `internal_resistance_ohm` (0.0095), `full_margin_v` (0.1V sotto il float
  per il 100%), `full_floor_v` (27.2V, la tensione più bassa che può mai
  contare come pieno: cambiala solo per un'altra chimica o un altro numero
  di celle) e `empty_margin_v` (0.2V sopra l'under-voltage per lo 0%)
  stanno nelle `trigger_variables` dell'automazione, perché gli agganci
  sono trigger e Home Assistant non rende le variabili dei trigger
  visibili alle azioni.
- **Tempi di tenuta**: il `for:` dei trigger `full_hold` (5 minuti) e
  `empty_hold` (1 minuto).

**Taratura della resistenza interna (`internal_resistance_ohm`).** Stessa
tensione di pacco, correnti diverse, SOC vero molto diverso: 27.5V con
pochi Ampere è quasi 100%, 27.2V a 39A in carica può essere un SOC
decisamente più basso, perché la corrente gonfia (in carica) o sgonfia (in
scarica) la tensione misurata rispetto alla vera tensione a riposo (OCV).

Valore attuale: **`internal_resistance_ohm = 0.0095` (9.5 mOhm)**, tarato
sul pacco reale a partire da uno storico esportato da un BMS JK-B2A8S20P.
**Il BMS non è collegato via RS485** (né in altro modo) a Home Assistant o
all'ESP32: il dato è stato ottenuto esportando lo storico dei log dall'app
JK sul telefono e analizzandolo offline. Metodo: nel log ogni volta che
scatta "Cell XX over charge protection" il caricabatterie viene interrotto
e 2-3 secondi dopo arriva "protection is released" — in quella finestra
così breve il SOC del BMS ("SOC Cap. Remain (AH)") non fa in tempo a
cambiare, ma la corrente crolla da ~35-39A a circa 0/-0.6A. Sono quindi
coppie (V1,I1)/(V2,I2) a parità di SOC, perfette per `R ≈ ΔV/ΔI`. Ce
n'erano 19 di questo tipo; una media pesata (somma ΔV / somma ΔI) dà
R ≈ 9.5 mOhm, con i singoli campioni compresi tra ~7 e ~14 mOhm. Convalidato
con lo stesso log: la tensione a riposo vicino al 100% di SOC si assesta
tra 27.5-27.6V (conferma l'ancoraggio a float_voltage), e l'unico evento di
scarica profonda registrato (SOC BMS = 0) mostra 21.41V, ben al di sotto dei
24.0V dell'ancoraggio di sicurezza conservativo usato per lo 0%.
**Questo valore è considerato definitivo per ora** — non un placeholder,
nessun lavoro aperto su questo punto. Per ricalcolarlo in futuro (pacco
diverso, deriva evidente): due letture di tensione/corrente a correnti
diverse ravvicinate nel tempo, oppure un nuovo export del log del BMS con
eventi simili.

**Possibile sviluppo futuro, non in corso.** Il BMS JK-B2A8S20P fa già un
proprio coulomb counting interno (calibrazione di fabbrica, compensazione
temperatura, bilanciamento cella-per-cella) — probabilmente più accurato di
quello ricostruito qui. Collegarlo all'ESP32 via RS485 (o Bluetooth) per
leggere il suo SOC direttamente potrebbe sostituire questa automazione in
tutto o in parte, ma è solo un'idea per il futuro: non pianificata né
iniziata. La soluzione attuale (tensione + corrente, con la resistenza
interna tarata come sopra) è considerata sufficientemente buona e stabile
così com'è.

Questo sensore è pensato per affiancare, non sostituire subito,
`sensor.heltec_pi30_battery_soc` e l'automazione di carica dinamica sopra
(che oggi usa soprattutto SOC/tensione Goodwe). Una volta verificato per
qualche giorno contro il comportamento reale della batteria, può essere
usato al posto di (o insieme a) gli altri sensori SOC nelle condizioni di
quell'automazione.

## Guida al protocollo Voltronic Axpert MAX (PI30)

Il documento del produttore è replicato qui:
[`docs/MAX Communication Protocol for HV7.2k-LV5k V00 20200717.pdf`](docs/MAX%20Communication%20Protocol%20for%20HV7.2k-LV5k%20V00%2020200717.pdf)
(Voltronic Power, *Axpert MAX Communication Protocol for HV7.2kW & LV5kW*,
V00, 2020-07-17 — 27 pagine). Riprodotto per riferimento; il copyright resta
di Voltronic Power.

### Formato seriale e framing

RS232, **2400 baud, 8 bit dati, nessuna parità, 1 bit di stop**.

Ogni frame — richiesta e risposta allo stesso modo — è:

```
<payload> <CRC alto> <CRC basso> <CR>
```

* Il CRC è **CRC-16/XMODEM** (polinomio `0x1021`, valore iniziale `0x0000`)
  calcolato solo sul payload.
* Se un byte di CRC risulta `0x28` (`(`), `0x0D` o `0x0A`, viene
  **incrementato di uno**. Questo mantiene inequivocabili i caratteri di
  framing.
* Le risposte iniziano con `(`. `(ACK` significa accettato, `(NAK`
  rifiutato — anche un `NAK` prova comunque che cablaggio e baud rate sono
  corretti.

> **I byte di CRC fanno parte del frame, non del payload.** Sono spesso
> ASCII stampabile, quindi un parser che rimuove solo il `<CR>` finale
> corrompe silenziosamente l'ultimo campo. Catture reali dall'inverter di
> test di questo repository: `(NAK` è seguito da `73 73` (`ss`), `(ACK` da
> `39 20` (`9` e uno **spazio**, che separa anche un campo fantasma).

### Comandi di interrogazione

| Comando | Scopo |
| :------ | :------ |
| `QPI` | ID protocollo dispositivo (un'unità PI30 risponde `(PI30`) |
| `QID` / `QSID` | Numero di serie (`QSID` per seriali più lunghi di 14) |
| `QVFW` / `QVFW3` | Versione firmware CPU principale / pannello remoto |
| `VERFW:` | Versione Bluetooth |
| `QPIRI` | Informazioni di targa e setpoint del dispositivo (25 campi) |
| `QFLAG` | Stato dei flag del dispositivo |
| `QPIGS` / `QPIGS2` | Parametri di stato generale (21 campi) |
| `QPGSn` | Informazioni parallelo per l'unità *n* |
| `QMOD` | Modalità del dispositivo |
| `QPIWS` | Stato degli avvisi (32 bit) |
| `QDI` | Valori di default |
| `QMCHGCR` / `QMUCHGCR` | Correnti massime di carica / carica da rete selezionabili |
| `QOPPT` / `QCHPT` | Ordine di priorità sorgente di uscita / sorgente di carica nel tempo |
| `QT` | Ora del dispositivo |
| `QBEQI` | Stato equalizzazione batteria |
| `QMN` / `QGMN` | Nome modello / nome modello generale |
| `QBOOT` | Se il DSP ha il bootstrap |
| `QBATCD` | Stato di carica e scarica |
| `QLED` | Parametri di stato dei LED |

### Comandi di impostazione

| Comando | Scopo |
| :------ | :------ |
| `PE<x>` / `PD<x>` | Abilita / disabilita un flag del dispositivo |
| `PF` | Ripristina i parametri di controllo ai valori di fabbrica |
| `MNCHGC<mnnn>` / `MUCHGC<mnn>` | Corrente massima di carica / carica da rete |
| `F<nn>` | Frequenza nominale di uscita (`F50`, `F60`) |
| `V<nnn>` | Tensione nominale di uscita |
| `POP<NN>` | Priorità sorgente di uscita |
| `PCP<NN>` | Priorità sorgente di carica |
| `PGR<NN>` | Range di funzionamento rete (`PGR00` appliance, `PGR01` UPS) |
| `PBT<NN>` | Tipo di batteria |
| `POPM<nn>` | Modalità di uscita |
| `PPCP<MNN>` | Priorità carica dispositivo in parallelo |
| `PBCV<nn.n>` | Tensione di **re-charge** batteria |
| `PBDV<nn.n>` | Tensione di **re-discharge** batteria |
| `PSDV<nn.n>` | Tensione di cut-off (under) batteria |
| `PCVV<nn.n>` | Tensione di carica C.V. (bulk) batteria |
| `PBFT<nn.n>` | Tensione di carica float batteria |
| `PCVT<nnn>` | Tempo massimo di carica in fase C.V. |
| `PBEQE<n>` / `PBEQA<n>` | Abilita / attiva equalizzazione batteria |
| `PBEQT<nnn>` / `PBEQP<nnn>` / `PBEQV<nn.nn>` / `PBEQOT<nnn>` | Tempo / periodo / tensione / timeout di equalizzazione |
| `DAT<YYMMDDHHMMSS>` | Imposta data e ora |
| `PBATCD<abc>` | Controllo carica/scarica batteria |
| `PBATMAXDISC<nnn>` | Corrente massima di scarica |
| `RTEY` | Reset dell'energia PV/carico memorizzata |
| `RTDL` | Cancella il data log |

> **Le quattro tensioni di batteria si confondono facilmente**, e
> sbagliarle cambia il comportamento dell'inverter. `PBCV` è *quando
> ricominciare a caricare dalla rete* — **non** è la tensione di bulk. Il
> bulk è `PCVV`, il float è `PBFT`, il cut-off è `PSDV`. I comandi
> `PBFTV`, `PBLWV` o `SCOV` non esistono in questo protocollo.

### Campi della risposta `QPIGS`

Verificati campo per campo contro ~24 000 risposte reali di un'unità PI30.

| # | Campo | # | Campo |
| -: | :---- | -: | :---- |
| 0 | Tensione di rete | 11 | Temperatura dissipatore inverter |
| 1 | Frequenza di rete | 12 | Corrente PV in ingresso per la batteria |
| 2 | Tensione di uscita AC | 13 | Tensione PV in ingresso |
| 3 | Frequenza di uscita AC | 14 | Tensione batteria da SCC |
| 4 | Potenza apparente di uscita AC (VA) | 15 | Corrente di scarica batteria |
| 5 | Potenza attiva di uscita AC (W) | 16 | **Stato dispositivo `b7…b0`** |
| 6 | Percentuale carico in uscita | 17 | Offset tensione batteria per ventole ON |
| 7 | Tensione di bus | 18 | Versione EEPROM |
| 8 | Tensione batteria | 19 | Potenza di carica PV |
| 9 | Corrente di carica batteria | 20 | **Stato dispositivo `b10b11b12`** |
| 10 | Capacità batteria (SoC) | | |

I campi 16 e 20 sono **stringhe di bit, non numeri** — `00010101` letto
come decimale diventa `10101` e perde gli zeri iniziali.

| Campo 16 | Significato | Campo 20 | Significato |
| :------- | :------ | :------- | :------ |
| `b7` | Versione priorità SBU aggiunta | `b10` | Carica verso modalità floating |
| `b6` | Configurazione cambiata | `b11` | Acceso |
| `b5` | Firmware SCC aggiornato | `b12` | Antipolvere installato |
| `b4` | Carico acceso | | |
| `b3` | Tensione batteria stabile in carica | | |
| `b2` | Carica attiva | | |
| `b1` | Carica SCC attiva | | |
| `b0` | Carica AC attiva | | |

### Campi della risposta `QPIRI`

| # | Campo | # | Campo |
| -: | :---- | -: | :---- |
| 0 | Tensione nominale di rete | 13 | Corrente massima di carica AC (`MUCHGC`) |
| 1 | Corrente nominale di rete | 14 | Corrente massima di carica (`MCHGC`) |
| 2 | Tensione nominale di uscita AC | 15 | Range di tensione in ingresso |
| 3 | Frequenza nominale di uscita AC | 16 | Priorità sorgente di uscita (`POP`) |
| 4 | Corrente nominale di uscita AC | 17 | Priorità sorgente di carica (`PCP`) |
| 5 | Potenza apparente nominale di uscita AC | 18 | Numero massimo in parallelo |
| 6 | Potenza attiva nominale di uscita AC | 19 | Tipo macchina |
| 7 | Tensione nominale batteria | 20 | Topologia |
| 8 | Tensione di re-charge batteria (`PBCV`) | 21 | Modalità di uscita |
| 9 | Tensione under batteria (`PSDV`) | 22 | Tensione di re-discharge batteria (`PBDV`) |
| 10 | Tensione bulk batteria (`PCVV`) | 23 | Condizione PV OK per parallelo |
| 11 | Tensione float batteria (`PBFT`) | 24 | Bilanciamento potenza PV |
| 12 | Tipo di batteria | | |

## Identificare un inverter sconosciuto

[`diagnostics/`](diagnostics/) contiene due configurazioni di sweep
standalone per un Heltec WiFi Kit 32 V3. Sono mantenute come ricevute e
**non** sono validate dalla CI: puntano a una scheda specifica e si
aspettano un secret `api_key_heltec_v3`.

| File | Cosa fa |
| :--- | :----------- |
| [`ESP32_ESP8266_diagnostic_inverter_type.yaml`](diagnostics/ESP32_ESP8266_diagnostic_inverter_type.yaml) | Un pulsante per ogni comando PI30 (`QPI`, `QID`, `QVFW`, `QPIRI`, `QDI`, `QFLAG`, `QMOD`, `QPIGS`, `QPIWS`), risposte scaricate in HEX e ASCII, baud rate selezionabile a runtime |
| [`ESP32_ESP8266_test_protocol_solar_inverter_RS232.yaml`](diagnostics/ESP32_ESP8266_test_protocol_solar_inverter_RS232.yaml) | Sweep di PI30 / PI30MAX / PI30REVO / PI41 / PI18 / PI17 / PI16 / Qx / Modbus RTU su 2400, 4800, 9600 e 19200 baud |

[`tests/esp8266-test-protocols.yaml`](tests/esp8266-test-protocols.yaml) fa
lo stesso sweep di protocollo per un ESP8266 ma solo a 2400 baud, e gira
nella CI. Usa lo sweep in `diagnostics/` quando devi anche scovare il baud
rate; usa quello in `tests/` quando lo conosci già (2400).

Cerca qualsiasi riga `RX` nel log. Anche `(NAK` è un successo: significa
che l'inverter ti sente. Se nulla risponde a nessun baud rate, prova a
scambiare TX e RX.

## Problemi noti

1. Se configuri molti dei sensori possibili ecc. potresti esaurire la
   memoria (su esp32). Se configuri quasi tutti i sensori ecc. incorri in
   un problema di dimensione dello stack. In questo caso devi aumentare la
   dimensione dello stack: https://github.com/esphome/issues/issues/855

## Debug

Se questo componente non funziona subito per il tuo dispositivo, aggiorna
la configurazione per abilitare l'output di debug del componente UART e
aumenta il livello di log per vedere il traffico seriale in uscita e in
ingresso:

```yaml
logger:
  level: DEBUG
  # Non scrivere i messaggi di log su UART0 (GPIO1/GPIO3) se l'inverter è collegato a GPIO1/GPIO3
  baud_rate: 0

uart:
  id: uart_0
  baud_rate: 2400
  tx_pin: ${tx_pin}
  rx_pin: ${rx_pin}
  debug:
    direction: BOTH
    dummy_receiver: false
    after:
      delimiter: "\r"
    sequence:
      - lambda: UARTDebug::log_string(direction, bytes);
```

Ogni esempio include già un `…-example-debug.yaml` pronto che fa
esattamente questo.

## Riferimenti

* https://github.com/syssi/esphome-pipsolar
* https://github.com/esphome/esphome/pull/1664
* https://github.com/esphome/esphome-docs/pull/1084/files
* https://github.com/andreashergert1984/esphome/tree/feature_pipsolar_anh
* https://github.com/jblance/mpp-solar/tree/master/docs/protocols
