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
| `sensor.heltec_pi30_display_pi30_battery_under_voltage` | PSDV, soglia di sottotensione letta dall'inverter (24.0V se non leggibile) |

`max_manual_current` (default `60`) e `hold_release_margin_v` (default
`0.5` V) sono semplici variabili dentro l'automazione, **non helper** — per
cambiarle, apri l'automazione in modalità YAML e modifica direttamente i
numeri.

**Mantenimento alla soglia di sottotensione.** Quando la tensione della
batteria PI30 scende a `sensor.heltec_pi30_display_pi30_battery_under_voltage`,
al posto di SCARICA viene eseguito MANTIENI: SBU, carica "solare + rete",
corrente da rete fissa a 10A. A quella tensione l'inverter in SBU è già in
Line mode (i carichi vanno sulla rete), ma il suo autoconsumo, circa 50W, che
il PI30 non mostra mai nella corrente di batteria, esce comunque dal pacco e
lo porterebbe fino allo stacco del BMS, che spegne l'inverter con tutta
l'uscita. È successo il 23/09/2026 alle 10:00 (carica su "solo solare", 0A
segnati per cinque ore e mezza in Line mode mentre il pacco scendeva da 25.1V
a 22.7V), il 25/09 alle 22:00 e il 26/09 alle 04:29, sempre a 22.7-22.8V.
**2A non bastano**: il 26/09 dalle 04:02 alle 04:29 il PI30 segnava +2A mentre
il pacco scendeva da 23.6V a 22.8V e il BMS l'ha staccato; con 9-10A, dalle
04:30, è risalito da 23.2V a 25.9V. Con 10A il pacco sale di qualche decimo di
volt in pochi minuti; MANTIENI resta attivo finché la tensione non è
`hold_release_margin_v` sopra la soglia, poi torna SCARICA, e MANTIENI riparte
quando la tensione ridiscende alla soglia: dalla rete si preleva solo quello
che l'inverter consuma, non è una ricarica. MANTIENI è il **primo controllo** di ogni esecuzione e vince
su tutti i rami CARICA e SCARICA, quindi anche una carica a 2A (che non basta)
viene sostituita da MANTIENI quando il pacco è alla soglia. L'automazione fa
tutto da sola e deve restare sempre attiva: disattivata non protegge più il pacco (il 25/09 era
disattivata, alla soglia non è intervenuto nulla e il BMS ha spento
l'inverter alle 22:00). La carica vera resta affidata al
surplus (i rami CARICA). Un trigger template (`sotto_tensione`) fa intervenire
l'automazione entro un minuto dal raggiungimento della soglia, senza
aspettare il controllo dei 10 minuti. Lo script MANTIENI porta la corrente
da rete a 10A anche quando le priorità sono già giuste.

Scritture: `select.heltec_pi30_display_pi30_set_max_utility_charging_current`,
`select.heltec_pi30_display_pi30_set_max_total_charging_current`,
`script.pi30_batteria_da_caricare` (CARICA), `script.pi30_batteria_da_scaricare`
(SCARICA), `script.pi30_batteria_da_mantenere` (MANTIENI — usato al posto di
SCARICA per tenere la batteria PI30 alla soglia di sottotensione con 10A).

Step di corrente da rete: `2 10 20 30 40 50 60`.

<details>
<summary>Logica decisionale completa (clicca per espandere)</summary>

```
PRIMA DI TUTTO
SE
	sensor.heltec_pi30_battery_voltage <= sensor.heltec_pi30_display_pi30_battery_under_voltage
	OPPURE (MANTIENI già attivo E tensione < sottotensione + hold_release_margin_v)
	(MANTIENI attivo = priorità uscita SBU E priorità carica solare + rete)
ALLORA
	MANTIENI = script.pi30_batteria_da_mantenere
	(SBU, solare + rete, 10A: tiene la batteria appena sopra la soglia, non la ricarica dalla rete)
	e STOP: nessuno dei rami sotto viene eseguito

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
  entrati 3.9 kWh" è una prova: si ferma a 99 e aspetta questo aggancio. I
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
SOC -= (kW_scarica + consumo_nascosto) × ore / capacity_kwh × 100
```

`ore` è il tempo **misurato** dall'esecuzione precedente (dal
`last_triggered` dell'automazione stessa), limitato a 5 minuti perché un
lungo fermo non integri la potenza letta al riavvio su ore di storia
sconosciuta. Le tre costanti sono **misurate su questo impianto** su un ciclo
completo pieno → vuoto → pieno (vedi "Cosa dicono tre giorni di storico" più
sotto):

- `capacity_kwh` = **3.9 kWh**, l'energia che il pacco eroga dal 100% allo 0%
  (la nominale 155Ah × 25.6V è 3.97 kWh).
- `charge_efficiency` = **0.87**, la quota di ogni kWh di carica riportato dal
  PI30 che finisce davvero immagazzinata nel pacco.
- `idle_drain_w` = **50 W**, la potenza che il pacco perde e che il PI30 non
  riporta mai: l'autoconsumo dell'inverter, preso dalla batteria ogni volta
  che il caricatore non sta caricando davvero. Viene sottratto ogni minuto in
  cui la potenza di carica è 60 W o meno (`small_charge_w`), tranne in float.

**Carica fantasma.** Una carica riportata di 60 W o meno (1-2A) non viene
contata come carica: è l'autoconsumo del PI30 o uno scarto della sua lettura
di corrente. Il 24-26/09/2026 il PI30 ha segnato +1A per 8 ore di notte in
Battery mode a caricatore spento (il vecchio conteggio saliva dal 61% al 65%,
la tensione diceva 50%), +1A la sera del 25 in Line mode con la carica su
"solo solare" al buio mentre il pacco scendeva da 24.5V a 22.7V e il BMS lo
staccava (il vecchio conteggio passava dal 5% al 6%), e +2A la notte del 26
in carica da rete a 2A mentre il pacco scendeva da 23.6V a 22.8V. L'unica
eccezione è il float (tensione >= `full_floor_v`, niente in scarica): lì il
caricatore tiene il pacco pieno e alimenta l'inverter da sé, quindi non si
conta nulla e un 100% agganciato resta 100%. Rigiocato minuto per minuto sul
24-26/09, il nuovo conteggio chiude la notte al 51% invece del 65% e arriva
allo 0% insieme alla tensione la sera del 25 invece di salire.

L'unità
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
la tensione, compensata per la corrente reale (quella riportata più i 50 W di
consumo nascosto) con la resistenza a regime misurata su questo pacco (10
mOhm), viene trasformata in SOC con una tabella misurata dallo 0% al 99% su
questo pacco, e il conteggio viene tirato verso quel valore — solo quando la
tensione è affidabile, e solo quando è chiaramente in disaccordo:

| Tensione compensata (V) | 22.70 | 23.40 | 24.00 | 24.50 | 25.00 | 25.60 | 25.96 | 26.22 | 26.42 | 26.57 | 26.67 | 26.75 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| SOC (%) | 0 | 1 | 2 | 4 | 6 | 9 | 20 | 30 | 50 | 65 | 75 | 99 |

- **Affidabile** vuol dire in scarica o a riposo (un +1/+2A fantasma vale
  0A), al massimo 30A, non in float, con il caricatore spento da almeno 60
  minuti: potenza di carica al massimo 60 W e o 0 W invariati da 60 minuti o
  entrambi i flag di carica (`binary_sensor.heltec_pi30_display_pi30_ac_charging`
  e `..._scc_charging`) spenti da 60 minuti. Subito dopo una carica la carica
  superficiale fa sembrare il pacco più pieno (con 30 minuti, il 26/09 un
  pacco al 7% circa leggeva 25.8V dopo 1.5 ore di carica e il conteggio veniva
  tirato all'11%), e durante la carica la tensione non dice nulla. I flag
  servono perché un +1A fantasma tiene la potenza di carica sopra 0 per ore, e
  prima spegneva la correzione proprio mentre il pacco si scaricava.
- **Chiaramente in disaccordo** vuol dire fuori dalla fascia di SOC compatibili
  con la lettura ±0.15V (il PI30 riporta passi da 0.1V). Dentro la fascia
  vince il conteggio; fuori, il conteggio recupera la differenza con una
  costante di tempo di 5 minuti (circa 1/5 al minuto).
- La fascia è larga 25-30 punti sul tratto piatto in alto (70-99%), 10-15
  punti sotto il 50%, e pochi punti sotto il 10%, dove la curva piega (25.0V
  è 6%, 24.0V è 2%): lì comanda la tensione. Esempio: 26.3V a -9A sono
  26.41V compensati, fascia 33-64%, e un contatore fermo al 96% scende a
  circa il 65% in circa 15 minuti.
- La tabella viene dal SOC ricostruito con il conteggio tarato sul ciclo del
  22-23 settembre (tensione compensata mediana per ogni 5% di SOC, e minuto
  per minuto nelle cinque ore a riposo prima dello stacco del BMS, 25.1V →
  22.7V). La correzione non scrive mai esattamente 100 o 0: quello resta ai
  due agganci.

Lo stesso modello scritto come tabella tensione × corrente (lato scarica,
corrente riportata; durante la carica la tensione non viene usata). Ogni
Ampere prelevato abbassa la lettura di circa 10 mV; la gobba piatta intorno a
26.4-26.7V è il plateau LiFePO4, dove la tensione dice poco e decide il
conteggio; sotto i 25.5V il ginocchio della curva rende la tensione precisa:

| Tensione | -30 A | -20 A | -10 A | -5 A | 0 A |
|---|---|---|---|---|---|
| 23.0 | 1% | 1% | 1% | 1% | 0% |
| 23.5 | 2% | 2% | 1% | 1% | 1% |
| 24.0 | 3% | 3% | 2% | 2% | 2% |
| 24.5 | 5% | 5% | 4% | 4% | 4% |
| 25.0 | 8% | 7% | 7% | 6% | 6% |
| 25.5 | 16% | 13% | 10% | 9% | 9% |
| 25.7 | 22% | 19% | 16% | 15% | 13% |
| 25.9 | 30% | 26% | 22% | 20% | 19% |
| 26.0 | 39% | 30% | 26% | 24% | 22% |
| 26.1 | 50% | 39% | 30% | 28% | 26% |
| 26.2 | 60% | 50% | 39% | 34% | 30% |
| 26.3 | 69% | 60% | 50% | 44% | 39% |
| 26.4 | 92% | 69% | 60% | 55% | 50% |
| 26.5 | 99% | 92% | 69% | 65% | 60% |
| 26.6 | 99% | 99% | 92% | 75% | 69% |
| 26.7 | 99% | 99% | 99% | 99% | 92% |

**Taratura:**
- **Modello del pacco**: `capacity_kwh` (3.9), `charge_efficiency` (0.87) e
  `idle_drain_w` (50) nell'automazione (`actions` → `variables`), tutti e tre
  misurati (vedi sotto). Ogni riga di aggancio nel Registro riporta entrambi
  i contatori di energia totale, quindi un nuovo ciclo pieno → vuoto → pieno
  li restituisce di nuovo.
- **Cadenza**: 1 minuto (trigger `cadence`). Si può cambiare liberamente: il
  tempo trascorso è misurato, nient'altro dipende da essa. Il limite di un
  singolo passo è `max_dt_hours` (5 minuti).
- **Corrente di mantenimento**: `tail_current_a` (2A, misurata: vedi sotto).
  Non alzarla oltre, o una carica volutamente a bassa corrente verrebbe
  scambiata per una carica esaurita.
- **Correzione con la tensione**: `ocv_v` / `ocv_soc` (la tabella),
  `correction_band_v` (0.15V), `correction_tau_min` (5),
  `correction_resistance_ohm` (0.010), `correction_max_current_a` (30),
  `correction_rest_min` (60).
- **Carica fantasma**: `small_charge_w` (60 W) e `full_floor_v` (27.2V,
  ripetuta in `actions` → `variables`: tienila uguale a quella dei trigger).
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

**Cosa dicono tre giorni di storico (21-23 set 2026: tensione, corrente,
potenza di batteria, modalità e priorità dell'inverter esportate da Home
Assistant).**

- **C'è stato un ciclo completo.** Pieno in float il 22 settembre alle 15:59,
  vuoto quando il BMS ha staccato il pacco a 22.7V (2.84V per cella) il 23
  alle 10:00, di nuovo pieno alle 15:10. Insieme a un ciclo pieno → mattino →
  pieno del 21-22 settembre fanno tre bilanci energetici per tre incognite,
  risolti esattamente: capacità 3.91 kWh, rendimento di carica 0.874, consumo
  nascosto 50 W. Con questi valori il conteggio segna 0.2% nel momento dello
  stacco del BMS e 100.0% alla fine della carica successiva.
- **Il PI30 nasconde circa 50 W.** Dalle 04:36 alle 10:00 del 23, in Line
  mode, ha riportato esattamente 0A per cinque ore e mezza mentre il pacco
  a riposo scendeva da 25.1V a 22.7V. È l'autoconsumo dell'inverter, mai
  mostrato nella corrente di batteria. In una notte fanno 0.6-0.9 kWh:
  ignorarlo è ciò che faceva sembrare il contatore di carica "il doppio" di
  quello di scarica in una taratura precedente (che aveva messo il fattore di
  carica a 0.5 e la capacità a 4.5 kWh; erano sbagliati entrambi).
- **Dal 55% al 99% la tensione è quasi inutile.** 26.42V compensati sono il
  50%, 26.73V il 95%: 0.3V per 45 punti, con il PI30 che legge a passi di
  0.1V. Sotto il 50% diventa informativa, e sotto il 10% la curva piega
  bruscamente: 25.0V a riposo sono il 6%, 24.0V il 2%, 22.7V lo stacco del
  BMS.
- **L'inverter mantiene a 27.5V con +2A, per ore.** Dei minuti passati sopra
  27.4V quasi tutti leggono esattamente +2A e uno solo legge 0A. Con
  `tail_current_a = 0` l'aggancio al 100% non scattava mai; ora è 2A.

**Valore di partenza.** Non serve più: con la correzione in tensione un
valore di partenza sbagliato si corregge entro 15-20 minuti di scarica
dovunque la tensione sia informativa, e la carica completa successiva lo
aggancia comunque al 100%.

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
