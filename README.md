# esphome-pipsolar

![GitHub actions](https://github.com/Travis90x/esphome-pipsolar/actions/workflows/ci.yaml/badge.svg)
![GitHub stars](https://img.shields.io/github/stars/Travis90x/esphome-pipsolar)
![GitHub forks](https://img.shields.io/github/forks/Travis90x/esphome-pipsolar)

🇮🇹 **[Versione italiana disponibile qui / Italian version available here](README_IT.md)**

ESPHome configurations to monitor and control a Voltronic/PIP solar inverter over RS232.

Fork of [syssi/esphome-pipsolar](https://github.com/syssi/esphome-pipsolar).
Kudos to [@andreashergert1984](https://github.com/andreashergert1984) for the original work.

## Supported devices

### pipsolar (PI30, Q-command protocol)

`pipsolar` is a **core ESPHome component** — it ships with ESPHome, so PI30 setups
need no external component at all.

* Voltronic Axpert / Axpert MAX and compatible units
* Any inverter whose `QPI` command replies `(PI30`
* Verified here on a 24V / 3.2kVA unit (`(PI30`, firmware `VERFW:00007.00`)

### pip8048 (Q-command protocol) — external component

* PIP4048 compatible PV Inverter
* Axpert King II 6.2KW TWIN (reported by [@voronin10](https://github.com/syssi/esphome-pipsolar/issues/196))
* Powmr 4.2KW (reported by [@Martyn911](https://github.com/syssi/esphome-pipsolar/issues/231))

### pip2424mse1 (Q-command protocol, extended) — external component

* PIP2424MSE1 and compatible inverters

### pi18 (PI18 protocol, `^P`/`^D` framing) — external component

* MPP Solar LV5048 Hybrid V2
* SunGoldPower 6048
* Voltronic InfiniSolar V 4 (3.6 kW / 5.6 kW / 6 kW)
* AXIOMA 5 kW
* MppSolar compatible units responding to `^P005GS`

## Repository layout

```
examples/
  esp32/
    pi18/            pip2424mse1/      pip8048/
    pipsolar/        PI30 configurations (core component)
    heltec-pi30/     PI30 + SSD1306 OLED, Heltec WiFi Kit 32 V3
  esp8266/
    pi18/            pip2424mse1/      pip8048/       pipsolar/
diagnostics/         identify an unknown inverter / protocol
components/          the pi18, pip2424mse1 and pip8048 external components
docs/                manufacturer protocol documents
home_assistant/      dashboards and automations built on top of the heltec-pi30 example
tests/               fake inverters and protocol sweeps used by CI
```

Each example folder holds three files: `…-example.yaml` (the config),
`…-example-debug.yaml` (adds UART tracing) and `…-example-faker.yaml`
(used by CI to compile without hardware).

### Which example should I start from?

| Inverter / goal | File |
| :-------------- | :--- |
| PI30, ESP32, entities only | [`examples/esp32/pipsolar/esp32-pi30-pipsolar.yaml`](examples/esp32/pipsolar/esp32-pi30-pipsolar.yaml) |
| PI30, ESP32, upstream demo | [`examples/esp32/pipsolar/esp32-pipsolar-example.yaml`](examples/esp32/pipsolar/esp32-pipsolar-example.yaml) |
| PI30, ESP8266 | [`examples/esp8266/pipsolar/esp8266-pipsolar-example.yaml`](examples/esp8266/pipsolar/esp8266-pipsolar-example.yaml) |
| PI30 **with OLED display** | [`examples/esp32/heltec-pi30/`](examples/esp32/heltec-pi30/) |
| PIP8048 / Axpert King | [`examples/esp32/pip8048/esp32-pip8048-example.yaml`](examples/esp32/pip8048/esp32-pip8048-example.yaml) |
| PIP2424MSE1 | [`examples/esp32/pip2424mse1/esp32-pip2424mse1-example.yaml`](examples/esp32/pip2424mse1/esp32-pip2424mse1-example.yaml) |
| PI18 / LV5048 | [`examples/esp32/pi18/esp32-pi18-example.yaml`](examples/esp32/pi18/esp32-pi18-example.yaml) |
| I don't know my protocol | [`diagnostics/`](diagnostics/) |

### The Heltec PI30 display examples

[`examples/esp32/heltec-pi30/`](examples/esp32/heltec-pi30/) holds two **complete
example configurations for a Heltec WiFi Kit 32 V3**, with the on-board SSD1306
OLED already wired up: seven rotating pages (date/time, WiFi, battery, charge and
discharge, setpoints read back from the inverter, and two battery-voltage graphs).

| File | Protocol handling | Lines |
| :--- | :---------------- | ----: |
| [`heltec-pi30-display-pipsolar.yaml`](examples/esp32/heltec-pi30/heltec-pi30-display-pipsolar.yaml) | core `pipsolar` component | 648 |
| [`heltec-pi30-display.yaml`](examples/esp32/heltec-pi30/heltec-pi30-display.yaml) | standalone, driven from scripts | 1794 |

**Start with the `pipsolar` one.** It delegates framing, CRC and polling to the
component that ESPHome maintains. The standalone file is worth keeping only if
you need its two extras: a console that sends arbitrary PI30 commands, and a
runtime baud-rate selector. It also exposes the bulk voltage (`PCVV`), which the
core component does not.

Both need three files next to the YAML that are **not** in this repository:
`arial.ttf`, `materialdesignicons-webfont.ttf` and `solar_power.bmp`. They are
excluded from CI for that reason; both were validated and compiled by hand
against ESPHome 2026.6.5 (ESP32-S3, arduino).

[`Personal-heltec-pi30-display-pipsolar.yaml`](examples/esp32/heltec-pi30/Personal-heltec-pi30-display-pipsolar.yaml)
is a third, personal variant of the `pipsolar` one (device name `heltec-inverter`,
friendly name `Heltec PI30 Display`) — it's the config actually producing the
entity naming (`sensor.heltec_pi30_battery_voltage`,
`sensor.heltec_pi30_display_pi30_*`, …) that the Home Assistant automations
below are built against.

## Requirements

* [ESPHome 2024.6.0 or higher](https://github.com/esphome/esphome/releases)
* One half of an ethernet cable with RJ45 connector
* RS232-to-TTL module (`MAX3232CSE` f.e.)
* Generic ESP32 or ESP8266 board

## Schematics

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

### RJ45 connector

| Pin     | Purpose      | MAX3232 pin       | Color T-568B |
| :-----: | :----------- | :---------------- | :------------|
|    1    | TX           | P13 (RIN1)        | White-Orange |
|    2    | RX           | P14 (DOUT1)       | Orange       |
|    3    |              |                   |              |
|    4    | VCC 12V      | -                 | Blue         |
|    5    |              |                   |              |
|    6    |              |                   |              |
|    7    |              |                   |              |
|    8    | GND          | P15 (GND)         | Brown        |

Please be aware of the different RJ45 pinout colors ([T-568A vs. T-568B](images/rj45-colors-t568a-vs-t568.png)).

The inverter provides +12V on pin 4 or 7 depending on the model. You can use a cheap DC-DC converter to power the ESP with 3.3V.

The [source for the pinout is here](docs/HS_MS_MSX%20RS232%20Protocol.pdf).

### MAX3232

| Pin          | Label        | ESPHome     | ESP8266 example  | ESP32 example |
| :----------- | :----------- | :---------- | :--------------- | :------------ |
| P11 (DIN1)   | TXD          | `tx_pin`    | `GPIO4`          | `GPIO16`      |
| P12 (ROUT1)  | RXD          | `rx_pin`    | `GPIO5`          | `GPIO17`      |
| P16 (VCC)    | VCC          |             |                  |               |
| P15 (GND)    | GND          |             |                  |               |

## Installation

### A. Home Assistant (ESPHome add-on) — no `pip3 install esphome`

If you run Home Assistant you do **not** install ESPHome yourself. The
**ESPHome Builder** add-on compiles and flashes for you, so nothing needs to be
installed on the Home Assistant host.

1. **Settings → Add-ons → Add-on Store → ESPHome Builder → Install**, then Start
   and open the Web UI.
2. **+ New Device → Skip** and give it a name. This creates
   `/config/esphome/<name>.yaml` and adds the API encryption key and OTA
   password to your `secrets.yaml`.
3. Open the new device with **Edit** and paste the example you picked from the
   table above. Adjust `tx_pin` / `rx_pin` for your board.
4. Keep or add these lines so the add-on can talk to the device:

   ```yaml
   api:
     encryption:
       key: !secret api_encryption_key   # created in step 2
   ```

5. **Install → Plug into this computer** for the first flash, then **Wirelessly**
   for every later update.

#### PI30: nothing else to install

`pipsolar` is part of ESPHome, so a PI30 config works as-is. The
`external_components:` block is only needed for **pip8048**, **pip2424mse1** and
**pi18**, which live in this repository:

```yaml
external_components:
  - source: github://Travis90x/esphome-pipsolar@main
    refresh: 0s
```

The add-on downloads them at compile time — again, nothing to install by hand.

> **Secrets.** The add-on keeps one shared `/config/esphome/secrets.yaml`, so
> `!secret wifi_ssid` and friends resolve automatically.

### B. Standalone (ESPHome CLI) — with `pip3 install esphome`

Use this if you build from a PC instead of Home Assistant.

```bash
# Install esphome
pip3 install esphome

# Clone this repository
git clone https://github.com/Travis90x/esphome-pipsolar.git
cd esphome-pipsolar

# Pick the example you want to build
CONFIG=examples/esp32/pipsolar/esp32-pi30-pipsolar.yaml

# ESPHome looks for secrets.yaml NEXT TO the config file
cat > "$(dirname $CONFIG)/secrets.yaml" <<EOF
wifi_ssid: MY_WIFI_SSID
wifi_password: MY_WIFI_PASSWORD

mqtt_host: MY_MQTT_HOST
mqtt_username: MY_MQTT_USERNAME
mqtt_password: MY_MQTT_PASSWORD
EOF

# Validate, build, upload and follow the logs
esphome run "$CONFIG"
```

To build an example against the components in your **working copy** instead of
the published ones, override the source — the helper scripts do the path
arithmetic for you:

```bash
./test-esp32.sh run examples/esp32/pip8048/esp32-pip8048-example.yaml
./test-esp8266.sh config examples/esp8266/pi18/esp8266-pi18-example.yaml
```

Take a look at the [official documentation of the pipsolar component](https://esphome.io/components/pipsolar.html) for additional details.

## Home Assistant automations (PI30 + LiFePO4 8S pack)

This section documents the Home Assistant side built on top of the `pipsolar`
device from the section above — dashboards and two automations that live in
[`home_assistant/`](home_assistant/). It replaces the per-folder READMEs that
used to live under `home_assistant/automations/`: nobody browses into nested
folders, so everything relevant is inlined here instead. The YAML files
themselves (imported via Home Assistant's "Edit in YAML" screens) stay in
their folders and are linked from each subsection below.

### The PI30 device in Home Assistant

Both automations below assume the entity naming produced by
[`Personal-heltec-pi30-display-pipsolar.yaml`](examples/esp32/heltec-pi30/Personal-heltec-pi30-display-pipsolar.yaml)
(device name `heltec-inverter`, friendly name `Heltec PI30 Display`, see "The
Heltec PI30 display examples" above): `sensor.heltec_pi30_battery_voltage`,
`sensor.heltec_pi30_battery_current` (positive while charging, negative while
discharging), and the `sensor.heltec_pi30_display_pi30_*` family — the QPIRI
setpoints read back from the inverter (float/under/recharge/redischarge/bulk
voltage, max charging currents, etc.) together with their writable
`number.heltec_pi30_display_pi30_set_*` / `select.heltec_pi30_display_pi30_set_*`
counterparts.

[`home_assistant/dashboard/inverter_ita.yaml`](home_assistant/dashboard/inverter_ita.yaml)
and [`inverter_eng.yaml`](home_assistant/dashboard/inverter_eng.yaml) are
ready-made Lovelace dashboard sections (Italian / English) covering output
source priority, device mode, charging current setpoints, battery voltages,
the SOC sensors described below, and diagnostics (raw TX/RX frame capture).
Paste them into a dashboard's YAML mode.

### Dynamic utility-charging modulation

Files: [`home_assistant/automations/PI30 battery management/`](<home_assistant/automations/PI30 battery management/>)
- `Automation - PI30 Battery Charging Intelligent Modulation.yaml`
- `Script Battery to charge.yaml`, `Script Battery to discharge.yaml`, `Script Battery to keep.yaml`

Goal: decide, every 10 minutes (plus on startup and on relevant sensor
changes), whether the PI30 should be charging its LiFePO4 pack from the grid,
discharging it, or just holding it — and if charging, how many Amps to pull
from the grid — based on a Goodwe inverter/battery on the same installation
(used as the "is there spare solar power right now" signal) and the PI30's
own battery voltage as a safety backstop.

Sensors read:

| Entity | Meaning |
| :--- | :--- |
| `sensor.goodwe_battery_state_of_charge` | Goodwe SOC |
| `sensor.goodwe_battery_voltage` | Goodwe voltage |
| `sensor.potenza_contatore` | grid meter power |
| `sensor.goodwe_battery_power` | Goodwe battery power |
| `sensor.heltec_pi30_display_pi30_max_utility_charging_current` | utility charging current confirmed by the PI30 |
| `sensor.heltec_pi30_display_pi30_max_total_charging_current` | total charging current confirmed by the PI30 |
| `sensor.heltec_pi30_battery_voltage` | PI30 battery voltage |
| `number.heltec_pi30_display_pi30_set_battery_under_voltage` | PSDV, battery cut-off configured on the inverter |

`max_manual_current` (default `60`) and `battery_keep_under_voltage` (=
PSDV + 0.2V) are plain variables inside the automation, **not helpers** — to
change them, open the automation in YAML mode and edit the numbers directly.

Writes: `select.heltec_pi30_display_pi30_set_max_utility_charging_current`,
`select.heltec_pi30_display_pi30_set_max_total_charging_current`,
`script.pi30_batteria_da_caricare` (CHARGE), `script.pi30_batteria_da_scaricare`
(DISCHARGE), `script.pi30_batteria_da_mantenere` (KEEP — used instead of
DISCHARGE when the PI30 battery is already close to cut-off).

Utility current steps: `2 10 20 30 40 50 60`.

<details>
<summary>Full decision logic (click to expand)</summary>

```
Favorable signal OR nothing known
IF
	Goodwe SOC or VOLT known (at least one of the two) and favorable (goodwe battery full AND charging power at minimum + goodwe NOT drawing much + NOT drawing much from the grid) =
	    IF SOC is unknown, VOLT must be favorable and vice versa.
		sensor.goodwe_battery_state_of_charge = 100 (>99, there are no decimals and Home Assistant does not accept =100, only above/below) (goodwe fully charged)
		OR
		sensor.goodwe_battery_voltage |float >= 54 (goodwe definitely fully charged)
		OR
		(goodwe fully charged but discharging)
			sensor.goodwe_battery_state_of_charge > 99
			AND
			sensor.goodwe_battery_voltage |float < 53
		OR
			IF sensor.potenza_contatore AND sensor.goodwe_battery_power KNOWN
				(Charging power at minimum, and BOTH favorable conditions are required: NOT drawing much from the grid AND NOT drawing much from goodwe)
				(HIGHER VALUES than modulation, for hysteresis)
				(FIX: AND, not OR, between the two thresholds - otherwise a single favorable condition would be
				enough to keep charging, while the DISCHARGE condition further below uses OR on the same two
				thresholds: both conditions could end up true at once when only one sensor is unfavorable, and
				CHARGE would always win because it is evaluated first)
				Charging power sensor.heltec_pi30_display_pi30_max_utility_charging_current = 2 A
				AND
					sensor.potenza_contatore < 500
					AND
					sensor.goodwe_battery_power < 200
			OTHERWISE (sensor.potenza_contatore AND sensor.goodwe_battery_power UNKNOWN)
				CHARGE with "safety net" = 2A power
				SET select.heltec_pi30_display_pi30_set_max_utility_charging_current = 2

THEN
	CHARGE = script.pi30_batteria_da_caricare
	AND
	MODULATE CHARGING POWER:
	READ sensor.heltec_pi30_display_pi30_max_total_charging_current
	IF sensor.heltec_pi30_display_pi30_max_total_charging_current < 60
		SET select.heltec_pi30_display_pi30_set_max_total_charging_current
		TO 60
	IF sensor.potenza_contatore < 300 AND sensor.goodwe_battery_power < 200

	(pi30_max_utility_charging_current can be < max_total_charging_current, which is the utility+solar charging current limit - solar is not used for now)
	THEN (STEP UP)
		READ sensor.heltec_pi30_display_pi30_max_utility_charging_current
		SET select.heltec_pi30_display_pi30_set_max_utility_charging_current
		INCREASING THE STEP (e.g.: if at 2 go to 10, if 10 -> 20, if 60 stay at 60, etc.)
		(STEPS ARE: 2 10 20 30 40 50 60)
		THE STEP CAN NEVER EXCEED max_manual_current (MAX MANUAL CURRENT)
	OTHERWISE (STEP DOWN) (if either condition is not met, something is drawing too much: sensor.potenza_contatore < 300 AND sensor.goodwe_battery_power)
		READ sensor.heltec_pi30_display_pi30_max_utility_charging_current
		SET select.heltec_pi30_display_pi30_set_max_utility_charging_current
		DECREASING THE STEP (e.g.: if at 2 stay at 2, if 10 go to 2, if 60 go to 50, etc.)
		(STEPS ARE: 2 10 20 30 40 50 60)

OTHERWISE
	IF
		Goodwe SOC or VOLT unknown
		AND
		sensor.potenza_contatore < 300 AND sensor.goodwe_battery_power < 200
	THEN
		CHARGE with "safety net" = 2A power
		SET select.heltec_pi30_display_pi30_set_max_utility_charging_current = 2

OTHERWISE
	IF
		sensor.heltec_pi30_battery_voltage < battery_keep_under_voltage
		(where battery_keep_under_voltage = number.heltec_pi30_display_pi30_set_battery_under_voltage + 0.2)
	THEN
		KEEP = script.pi30_batteria_da_mantenere
		(the PI30 battery is already close to cut-off: do not discharge it further)
	OTHERWISE
		DISCHARGE = script.pi30_batteria_da_scaricare

WHICH MEANS
IF
	sensor.heltec_pi30_display_pi30_max_utility_charging_current = 2A
	AND
	sensor.potenza_contatore > 500 OR sensor.goodwe_battery_power > 200

THEN
	DESPITE "charging power at minimum" AND "goodwe not drawing much" AND "not drawing much from the grid"
	that is not enough, so DISCHARGE
```

**MAX MANUAL CURRENT.** Not a helper: a fixed variable inside the automation
itself, under `action > variables > max_manual_current` (default 60). To
change it, open the automation in YAML mode, edit that number, and save. If
set to, say, 40: the STEP UP phase will never go above 40A; if the current is
already above 40A (because the limit was lowered while the system was
charging at a higher step), the automation immediately brings it back down to
the highest valid step not exceeding 40 (i.e. 40).

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

### Real SOC via energy counting (voltage + energy in/out)

Files: [`home_assistant/automations/PI30 battery SOC/`](<home_assistant/automations/PI30 battery SOC/>)
- `Automation - PI30 Battery SOC Energy Counting.yaml`
- `Script - PI30 Battery SOC Recalibrate from Voltage.yaml`

The 8S LiFePO4 pack has a Volt/SOC curve that's very flat between roughly 20%
and 80%: a few hundredths of a volt correspond to tens of percentage points
of SOC. On top of that, the curve shifts depending on how much current the
battery is drawing or delivering at that moment (internal resistance drop).
A SOC sensor based only on instantaneous voltage (like
`sensor.heltec_pi30_battery_soc`, read from the PI30 protocol) is therefore
inaccurate exactly in the middle of the curve, where it matters most.

**How it works.** Instead of reading SOC from voltage, it counts the energy
that goes in and out of the pack against the pack's usable capacity in kWh:
once a minute (and at startup, and whenever you run the automation by hand)
it reads the battery charge and discharge power
(`sensor.heltec_pi30_batteria_potenza_carica` and
`sensor.heltec_pi30_batteria_potenza_scarica`, the same two sensors the
lifetime kWh counters are built on) and multiplies them by the real time
elapsed since the previous run. 26.6V at 5A for four hours says nothing
about the SOC; 0.5 kWh moved in four hours does. Pure counting drifts over
time (and inherits any error in the capacity), so the
estimate is re-anchored at the two extremes using a voltage compensated for
the internal resistance drop rather than the raw one (`voltage_ocv =
voltage - current * internal_resistance_ohm`, same sign convention as the
current sensor):

- **100%** (`full_hold` trigger) when `voltage_ocv` reaches the full
  threshold **and** the pack is not being pushed (`current <=
  tail_current_a`, `0` by default: idle or discharging), **both true
  continuously for 5 minutes**. The full threshold is the *higher* of the
  float voltage (`sensor.heltec_pi30_display_pi30_battery_float_voltage`
  minus 0.1V margin) and a fixed floor of **27.2V** (`full_floor_v`, 3.40V
  per cell × 8). The floor is there because the float voltage is whatever
  the inverter was programmed with: with a float of 26.8V or lower, "at
  float voltage" is the flat middle of the LiFePO4 curve (26.6V at rest is
  anywhere between 60% and 85%) and the anchor would certify a half-full
  pack as 100%. Below 3.40V per cell a resting LiFePO4 cell is not full,
  whatever the charger settings say. The second half is the meaningful test:
  if the pack holds the float voltage while nothing is charging it, that
  voltage comes from its own state of charge, so it really is full — no
  model needed. A pack still absorbing current may just be held up there
  by the charger. Note that a *low* charge current is not evidence of a
  full pack either: charging at 2A because there is no solar surplus is
  not the same thing as a charge that tapered off because the battery
  would take no more, which is why the default threshold is 0 rather
  than a "tail current" value. A count that says "4.5 kWh went in" is
  not evidence either: it stops at 99 and waits for this anchor. The
  5-minute hold filters out surface
  charge: right after the charger cuts off, a half-full LiFePO4 pack sits
  near the charge voltage for a minute or two before relaxing to its
  resting voltage.
  The inverter's *charging to floating mode* flag
  (`binary_sensor.heltec_pi30_display_pi30_charging_to_floating_mode`)
  is deliberately **not** part of this anchor: it describes the
  charger's stage, not the battery's state, and the PI30 keeps it
  raised after sunset, all night long while the pack is discharging,
  until the charger goes back to bulk. Used as an alternative to the
  voltage test it re-wrote 100% every 2 minutes for the whole night
  (a discharging pack always passes the "not being pushed" test),
  pinning the sensor at 100% whatever the real state of charge.
- **0%** (`empty_hold` trigger) when `voltage_ocv` drops below the
  under-voltage threshold
  (`sensor.heltec_pi30_display_pi30_battery_under_voltage`) plus a 0.2V
  margin, continuously for 1 minute, reaching 0% a bit before the BMS
  itself would disconnect the battery. The 1-minute hold ignores the sag
  of a load spike (a compressor start) that the resistive model does not
  fully compensate.

Both anchors are Home Assistant template triggers with a `for:` hold, so
each one writes its value **once**, on the false → true transition of its
condition, and re-arms only after the condition has been false again. Each
anchor also writes a **Logbook** entry with the readings it fired on
(voltage, current, float and under-voltage thresholds, both lifetime
energy counters, previous SOC), so a
wrong 100% or 0% can be traced back to the exact moment: open the Logbook
and filter on `input_number.pi30_battery_soc_calculated`. That
is what lets a full pack start counting down from 100 the moment current
flows out of it, instead of being re-written to 100 every 2 minutes for as
long as its voltage stays high. If the pack is already full (or empty)
when you first load the automation, the anchor waits for the next episode:
set the Number helper by hand once, as described in the setup below.

Between the two extremes, SOC only moves with the energy moved:

```
SOC += charge_kW × charge_efficiency × hours / capacity_kwh × 100
SOC -= discharge_kW × hours / capacity_kwh × 100
```

`hours` is the **measured** time since the previous run (from the
automation's own `last_triggered`), capped at 5 minutes so that a long
outage does not integrate the power read at boot over hours of unknown
history. `capacity_kwh` (4.5) is the energy the pack *delivers* from 100%
to 0% (discharge side). `charge_efficiency` (0.5) is how much of each kWh
the PI30 *says* it pushed in actually comes back out — **measured on this
system**, see "What two days of history say" below; physics alone would
give about 0.93 (charging at 27-28V, discharging at 26V, a few percent of
losses), but this inverter reports about twice the charging current that
really enters the pack. The power
sensors' unit is read from the sensor (W or kW). The value is stored with 3
decimals (at the 1-2A this pack idles at overnight one step is a few
hundredths of a percent, which a 1-decimal rounding would throw away
entirely); the template sensor rounds it for display.

Why not read the two lifetime kWh counters directly? They tick every 10
seconds, and counting their ticks means running the automation every 10
seconds, with the logbook and the history full of it. Using them once a
minute instead would need a second helper to remember the counter value of
the previous run, and this setup is meant to stay at one helper.
Integrating the same power once a minute gives the same kWh, only sampled
every 60 s instead of every 10 s, which for a battery is no loss at all.

Plain counting can never *claim* a full or empty pack: rising, it stops at
99; falling, it stops at 1. It may however keep going down from an anchored
100 (or up from an anchored 0). The reverse is deliberately **not**
allowed: any charge at all moves an anchored 100 down to 99, because a
pack that is still taking energy is no longer certified full. That costs a
100 ↔ 99 flicker while the inverter trickles in float, and it is worth it:
a stale 100 (from an earlier wrong anchor, or set by hand) must not sit
there while the pack swallows 5A for hours. Only the two anchors above write
exactly 100 and exactly 0.

**Setup — 2 helpers, all from the UI, no `configuration.yaml`:**

Prerequisite: the battery charge and discharge power sensors
`sensor.heltec_pi30_batteria_potenza_carica` and
`sensor.heltec_pi30_batteria_potenza_scarica` (W or kW, both ≥ 0), plus, for
the calibration notes the anchors write in the Logbook, the two lifetime
kWh counters `sensor.heltec_pi30_batteria_energia_caricata` and
`sensor.heltec_pi30_batteria_energia_scaricata` built on them.

Both helpers are in the same folder as the automation, each with the UI
recipe and the `configuration.yaml` equivalent:
`Helper 1 - PI30 Battery SOC calculated (Number).yaml` and
`Helper 2 - PI30 Battery SOC calculated (Template sensor).yaml`.

1. **Number helper** (Settings → Devices & services → Helpers → Create
   helper → Number): Name `PI30 battery SOC calculated`, icon
   `mdi:battery-unknown`, min `0`, max `100`, step `0.1`, unit `%`. This
   creates `input_number.pi30_battery_soc_calculated`, the raw value
   container the automation writes to. **The entity id must be exactly
   that one**: open the helper, gear icon, check "Entity ID" and fix it if
   the name produced something else. If the automation editor shows
   "entity not found" next to `input_number.pi30_battery_soc_calculated`,
   this helper is missing and nothing can work — and whatever SOC you are
   looking at is another sensor, most likely the inverter's own
   `sensor.heltec_pi30_battery_soc`, which is voltage-based and happily
   sits at 100% for hours. On first save, set it to something
   close to `sensor.heltec_pi30_battery_soc`'s current reading — the
   automation re-anchors it the first time the pack completes a charge
   (or runs empty) anyway. The automation writes 3 decimals into it; the
   `0.1` step only affects the slider, `set_value` is not limited by it.
2. **Template sensor helper** (Settings → Devices & services → Helpers →
   Create helper → Template → Sensor): Name `Heltec PI30 Display PI30
   battery SOC calculated`, unit `%`, device class `Battery`, state class
   `Measurement`, and as **State**:
   ```
   {{ states('input_number.pi30_battery_soc_calculated') | float(default=0) | round(0) }}
   ```
   This creates `sensor.heltec_pi30_display_pi30_battery_soc_calculated`,
   the proper battery sensor the dashboards in `home_assistant/dashboard`
   use, usable in graphs like any other SOC sensor. Create it after the
   Number helper (it reads that entity_id).

Then import `Automation - PI30 Battery SOC Energy Counting.yaml` (Settings
→ Automations → Edit in YAML) to do the integration and re-anchoring above.

Optionally, right after creating the Number helper, run
`Script - PI30 Battery SOC Recalibrate from Voltage.yaml` **once** (Settings
→ Automations & scenes → Scripts → Edit in YAML, then run it) so the counter
doesn't start at 0%: it linearly interpolates the compensated voltage
between the two real extremes and seeds the Number helper with that
estimate. It's a straight line, not the real LiFePO4 curve — fine as a
starting point, not a substitute for daily energy counting. **Don't run it
routinely**: doing so on every voltage tick-up turns the sensor back into
something based on instantaneous voltage alone, defeating the point of
energy counting (see the warning in the script's own description).

**Voltage correction.** The count alone cannot know where it started: set
wrong (a stale 100, a helper created mid-discharge) it would stay wrong until
the next full charge. So every minute the voltage, compensated for the current
with the steady-state resistance measured on this pack (11.3 mOhm), is turned
into a SOC through a table measured from two days of history, and the count is
pulled towards it — only when the voltage can be trusted, and only when it
clearly disagrees:

| Compensated voltage (V) | 24.00 | 25.40 | 25.90 | 26.18 | 26.30 | 26.42 | 26.53 | 26.63 | 26.67 | 26.70 | 26.72 | 26.75 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| SOC (%) | 0 | 10 | 30 | 50 | 60 | 70 | 75 | 80 | 85 | 90 | 95 | 99 |

- **Trusted** means discharging or idle, at most 30A, with the charger off for at
  least 30 minutes: right after a charge, surface charge makes any pack look
  full, and while charging the voltage says nothing.
- **Clearly disagrees** means outside the band of SOCs compatible with the
  reading ±0.1V (the PI30 reports 0.1V steps). Inside the band the count wins;
  outside, the count closes 1/20 of the gap per minute.
- On the flat top (85-99%) the band is about 20 points wide and the voltage
  rarely overrides the count; from about 80% down it does. Example: 26.3V at
  -9A is 26.40V compensated, band 60-74%, and a counter stuck at 98% comes
  down to about 73% within an hour.
- The 70-99% part of the table is measured (SOC reconstructed from the energy
  counters between two full charges, fitted as V = 25.32 + 0.0152·SOC +
  0.0113·I, residual 0.06V). Below 70%, never reached in the data, it follows
  the usual LiFePO4 curve down to the 0% anchor voltage. The correction never
  writes exactly 100 or 0: that stays with the two anchors.

**Tuning:**
- **Pack capacity**: `capacity_kwh` (4.5 kWh, the energy delivered from
  100% to 0%) and `charge_efficiency` (0.93) in the automation (`actions`
  → `variables`). Both are readable off the Logbook: between a 0% anchor
  and the next 100% anchor, the rise of the charged counter is
  `capacity_kwh / charge_efficiency`; between a 100% anchor and the next 0%
  anchor, the rise of the discharged counter is `capacity_kwh` itself. Each
  anchor's Logbook line carries both counters at that moment.
- **Cadence**: 1 minute (`cadence` trigger). It can be changed freely: the
  elapsed time is measured, nothing else depends on it. The cap on a single
  step is `max_dt_hours` (5 minutes).
- **Float trickle**: `tail_current_a` (2A, measured: see below). Do not raise
  it further, or a deliberate low-current charge would be mistaken for a
  tapered one.

**What two days of history say (20-22 Sep 2026, voltage, current and the
two kWh counters exported from Home Assistant).** Three facts that shaped
the defaults above:

- **The voltage is useless between the two extremes.** While discharging
  at 3-25A the pack read 26.2-26.7V for the whole night; at rest it read
  26.4-26.5V both mornings, after two nights that drew 1.0 and 1.2 kWh.
  Between "full" and "morning" the only thing that moves is the energy,
  which is why the SOC is counted, not read. The voltage becomes
  informative again only above 27.2V at rest (full) and near the
  under-voltage threshold (empty), and that is exactly where the two
  anchors sit.
- **The inverter floats at 27.5V with +2A, for hours.** Of the 587 minutes
  spent above 27.4V, 536 read exactly +2A, 48 read +1A and one single
  minute read 0A. A full pack cannot absorb 2A for five hours: it is the
  PI30's whole-Amp reading of a small float current. With
  `tail_current_a = 0` the 100% anchor never fired; it is now 2A, which
  with the 27.4V threshold is still a safe "full" test.
- **The charge counter is about twice the discharge counter between the
  same two states.** Morning rest at 26.4V → full: the charge counter rose
  2.50 kWh (day 1) and 2.05 kWh (day 2). Full → the same 26.4V rest: the
  discharge counter rose 1.20 and 1.11 kWh. The discharge side is right —
  it matches the inverter's output power integrated over the same nights
  (1.20 vs 1.27 kWh, the difference being the inverter's own losses) — so
  the PI30 reports roughly twice the charging current that really enters
  the pack (39A for two hours, while the pack could only have taken about
  45Ah). Hence `charge_efficiency = 0.5` instead of the textbook 0.93. If
  the pack or the inverter changes, redo this check from the Logbook lines
  the anchors write: rise of the charged counter between a 0% (or a known
  resting state) and the next 100%, against the rise of the discharged
  counter on the way back.

**Starting value.** The counter only moves with energy, so it needs a
sensible first value: with the pack resting at 26.4-26.5V after a normal
night (about 1.2 kWh drawn from full, 4.5 kWh capacity) that is roughly
**70-75%**. Set the Number helper to that by hand once; the next full
charge anchors it to 100% and from there the count is exact.
- **Anchor constants**: `tail_current_a` (0A), `internal_resistance_ohm`
  (0.0095), `full_margin_v` (0.1V below float for 100%), `full_floor_v`
  (27.2V, the lowest voltage that can ever count as full: change it only
  for another chemistry or cell count) and `empty_margin_v` (0.2V above
  under-voltage for 0%) live in the
  automation's `trigger_variables`, because the anchors are triggers and
  Home Assistant does not expose trigger variables to the actions.
- **Hold times**: the `for:` of the `full_hold` (5 minutes) and
  `empty_hold` (1 minute) triggers.

**Internal resistance calibration (`internal_resistance_ohm`).** Same pack
voltage, different currents, very different real SOC: 27.5V at a few Amps is
nearly 100%, 27.2V at 39A while charging can be a much lower SOC, because
current inflates (while charging) or deflates (while discharging) the
measured voltage relative to the true resting voltage (OCV).

Current value: **`internal_resistance_ohm = 0.0095` (9.5 mOhm)**, calibrated
on the real pack from a log exported from a JK-B2A8S20P BMS. **The BMS is
not connected via RS485** (or any other way) to Home Assistant or the ESP32:
the data was obtained by exporting the log history from the JK phone app and
analyzing it offline. Method: every time a "Cell XX over charge protection"
event fires in the log, the charger is cut off, and 2-3 seconds later a
"protection is released" event follows — in that short window the BMS's own
SOC ("SOC Cap. Remain (AH)") doesn't have time to change, but current drops
from ~35-39A to roughly 0/-0.6A. These are (V1,I1)/(V2,I2) pairs at the same
SOC, perfect for `R ≈ ΔV/ΔI`. There were 19 such pairs; a weighted average
(sum ΔV / sum ΔI) gives R ≈ 9.5 mOhm, individual samples ranging ~7-14 mOhm.
Cross-validated against the same log: near-100%-SOC resting voltage clusters
at 27.5-27.6V (confirms the float-voltage anchor), and the single recorded
deep-discharge event (BMS SOC = 0) sits at 21.41V, comfortably below the
24.0V conservative safety anchor used for 0%. **This value is considered
final for now** — not a placeholder, no open work on this point. To
recompute it later (different pack, noticeable drift): two
voltage/current readings at different currents close together in time, or a
new BMS log export with similar events.

**Possible future development, not in progress.** The JK-B2A8S20P BMS
already runs its own internal coulomb counting (factory calibration,
temperature compensation, per-cell balancing) — likely more accurate than
what's rebuilt here. Wiring it to the ESP32 over RS485 (or Bluetooth) to
read its SOC directly could replace this automation in whole or in part,
but this is only a future idea: neither planned nor started. The current
voltage+current solution is considered good enough and stable as-is.

This sensor is meant to sit alongside, not immediately replace,
`sensor.heltec_pi30_battery_soc` and the dynamic-charging automation above
(which today mainly uses the Goodwe SOC/voltage). Once verified for a few
days against real battery behavior, it can be used instead of (or alongside)
the other SOC sensors in that automation's conditions.

## Voltronic Axpert MAX (PI30) protocol guide

The manufacturer document is mirrored here:
[`docs/MAX Communication Protocol for HV7.2k-LV5k V00 20200717.pdf`](docs/MAX%20Communication%20Protocol%20for%20HV7.2k-LV5k%20V00%2020200717.pdf)
(Voltronic Power, *Axpert MAX Communication Protocol for HV7.2kW & LV5kW*, V00,
2020-07-17 — 27 pages). It is reproduced for reference; the copyright stays with
Voltronic Power.

### Serial format and framing

RS232, **2400 baud, 8 data bits, no parity, 1 stop bit**.

Every frame — request and response alike — is:

```
<payload> <CRC high> <CRC low> <CR>
```

* The CRC is **CRC-16/XMODEM** (polynomial `0x1021`, initial value `0x0000`)
  computed over the payload only.
* If a CRC byte comes out as `0x28` (`(`), `0x0D` or `0x0A`, it is **incremented
  by one**. This keeps the framing characters unambiguous.
* Responses start with `(`. `(ACK` means accepted, `(NAK` rejected — a `NAK`
  still proves the wiring and baud rate are right.

> **The CRC bytes are part of the frame, not part of the payload.** They are
> frequently printable ASCII, so a parser that only strips the trailing `<CR>`
> silently corrupts the last field. Real captures from this repository's test
> inverter: `(NAK` is followed by `73 73` (`ss`), `(ACK` by `39 20` (`9` and a
> **space**, which also splits off a phantom field).

### Inquiry commands

| Command | Purpose |
| :------ | :------ |
| `QPI` | Device protocol ID (a PI30 unit answers `(PI30`) |
| `QID` / `QSID` | Serial number (`QSID` for serials longer than 14) |
| `QVFW` / `QVFW3` | Main CPU / remote panel firmware version |
| `VERFW:` | Bluetooth version |
| `QPIRI` | Device rating information and setpoints (25 fields) |
| `QFLAG` | Device flag status |
| `QPIGS` / `QPIGS2` | General status parameters (21 fields) |
| `QPGSn` | Parallel information for unit *n* |
| `QMOD` | Device mode |
| `QPIWS` | Warning status (32 bits) |
| `QDI` | Default setting values |
| `QMCHGCR` / `QMUCHGCR` | Selectable max charging / utility charging currents |
| `QOPPT` / `QCHPT` | Output source / charger source priority time order |
| `QT` | Device time |
| `QBEQI` | Battery equalization status |
| `QMN` / `QGMN` | Model name / general model name |
| `QBOOT` | Whether the DSP has bootstrap |
| `QBATCD` | Charge and discharge status |
| `QLED` | LED status parameters |

### Setting commands

| Command | Purpose |
| :------ | :------ |
| `PE<x>` / `PD<x>` | Enable / disable a device flag |
| `PF` | Restore control parameters to factory defaults |
| `MNCHGC<mnnn>` / `MUCHGC<mnn>` | Max charging / utility charging current |
| `F<nn>` | Output rating frequency (`F50`, `F60`) |
| `V<nnn>` | Output rating voltage |
| `POP<NN>` | Output source priority |
| `PCP<NN>` | Charger source priority |
| `PGR<NN>` | Grid working range (`PGR00` appliance, `PGR01` UPS) |
| `PBT<NN>` | Battery type |
| `POPM<nn>` | Output mode |
| `PPCP<MNN>` | Parallel device charger priority |
| `PBCV<nn.n>` | Battery **re-charge** voltage |
| `PBDV<nn.n>` | Battery **re-discharge** voltage |
| `PSDV<nn.n>` | Battery cut-off (under) voltage |
| `PCVV<nn.n>` | Battery C.V. (bulk) charging voltage |
| `PBFT<nn.n>` | Battery float charging voltage |
| `PCVT<nnn>` | Max charging time at C.V. stage |
| `PBEQE<n>` / `PBEQA<n>` | Enable / activate battery equalization |
| `PBEQT<nnn>` / `PBEQP<nnn>` / `PBEQV<nn.nn>` / `PBEQOT<nnn>` | Equalization time / period / voltage / timeout |
| `DAT<YYMMDDHHMMSS>` | Set date and time |
| `PBATCD<abc>` | Battery charge/discharge control |
| `PBATMAXDISC<nnn>` | Max discharging current |
| `RTEY` | Reset stored PV/load energy |
| `RTDL` | Erase the data log |

> **The four battery voltages are easy to mix up**, and getting them wrong
> changes how the inverter behaves. `PBCV` is *when to start charging from the
> grid again* — it is **not** the bulk voltage. Bulk is `PCVV`, float is `PBFT`,
> cut-off is `PSDV`. Commands named `PBFTV`, `PBLWV` or `SCOV` do not exist in
> this protocol.

### `QPIGS` response fields

Verified field-by-field against ~24 000 real replies from a PI30 unit.

| # | Field | # | Field |
| -: | :---- | -: | :---- |
| 0 | Grid voltage | 11 | Inverter heat sink temperature |
| 1 | Grid frequency | 12 | PV input current for battery |
| 2 | AC output voltage | 13 | PV input voltage |
| 3 | AC output frequency | 14 | Battery voltage from SCC |
| 4 | AC output apparent power (VA) | 15 | Battery discharge current |
| 5 | AC output active power (W) | 16 | **Device status `b7…b0`** |
| 6 | Output load percent | 17 | Battery voltage offset for fans on |
| 7 | Bus voltage | 18 | EEPROM version |
| 8 | Battery voltage | 19 | PV charging power |
| 9 | Battery charging current | 20 | **Device status `b10b11b12`** |
| 10 | Battery capacity (SoC) | | |

Fields 16 and 20 are **bit strings, not numbers** — `00010101` parsed as a
decimal becomes `10101` and loses its leading zeros.

| Field 16 | Meaning | Field 20 | Meaning |
| :------- | :------ | :------- | :------ |
| `b7` | Add SBU priority version | `b10` | Charging to floating mode |
| `b6` | Configuration changed | `b11` | Switch on |
| `b5` | SCC firmware updated | `b12` | Dustproof installed |
| `b4` | Load on | | |
| `b3` | Battery voltage to steady while charging | | |
| `b2` | Charging on | | |
| `b1` | SCC charging on | | |
| `b0` | AC charging on | | |

### `QPIRI` response fields

| # | Field | # | Field |
| -: | :---- | -: | :---- |
| 0 | Grid rating voltage | 13 | Max AC charging current (`MUCHGC`) |
| 1 | Grid rating current | 14 | Max charging current (`MCHGC`) |
| 2 | AC output rating voltage | 15 | Input voltage range |
| 3 | AC output rating frequency | 16 | Output source priority (`POP`) |
| 4 | AC output rating current | 17 | Charger source priority (`PCP`) |
| 5 | AC output rating apparent power | 18 | Parallel max num |
| 6 | AC output rating active power | 19 | Machine type |
| 7 | Battery rating voltage | 20 | Topology |
| 8 | Battery re-charge voltage (`PBCV`) | 21 | Output mode |
| 9 | Battery under voltage (`PSDV`) | 22 | Battery re-discharge voltage (`PBDV`) |
| 10 | Battery bulk voltage (`PCVV`) | 23 | PV OK condition for parallel |
| 11 | Battery float voltage (`PBFT`) | 24 | PV power balance |
| 12 | Battery type | | |

## Identifying an unknown inverter

[`diagnostics/`](diagnostics/) contains two standalone sweep configurations for a
Heltec WiFi Kit 32 V3. They are kept as received and are **not** validated by CI:
they target one specific board and expect an `api_key_heltec_v3` secret.

| File | What it does |
| :--- | :----------- |
| [`ESP32_ESP8266_diagnostic_inverter_type.yaml`](diagnostics/ESP32_ESP8266_diagnostic_inverter_type.yaml) | One button per PI30 command (`QPI`, `QID`, `QVFW`, `QPIRI`, `QDI`, `QFLAG`, `QMOD`, `QPIGS`, `QPIWS`), replies dumped as HEX and ASCII, baud rate selectable at runtime |
| [`ESP32_ESP8266_test_protocol_solar_inverter_RS232.yaml`](diagnostics/ESP32_ESP8266_test_protocol_solar_inverter_RS232.yaml) | Sweeps PI30 / PI30MAX / PI30REVO / PI41 / PI18 / PI17 / PI16 / Qx / Modbus RTU across 2400, 4800, 9600 and 19200 baud |

[`tests/esp8266-test-protocols.yaml`](tests/esp8266-test-protocols.yaml) does the
same protocol sweep for an ESP8266 but only at 2400 baud, and it runs in CI. Use
the `diagnostics/` sweep when you also need to hunt for the baud rate; use the
`tests/` one when you already know it is 2400.

Look for any `RX` line in the log. Even `(NAK` is a success: it means the
inverter can hear you. If nothing answers at any baud rate, try swapping TX
and RX.

## Known issues

1. If you configure a lot of the possible sensors etc. it could be that you run out of memory (on esp32). If you configure nearly all sensors etc. you run in a stack-size issue. In this case you have to increase stack size: https://github.com/esphome/issues/issues/855

## Debugging

If this component doesn't work out of the box for your device please update your configuration to enable the debug output of the UART component and increase the log level to see outgoing and incoming serial traffic:

```yaml
logger:
  level: DEBUG
  # Don't write log messages to UART0 (GPIO1/GPIO3) if the inverter is connected to GPIO1/GPIO3
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

Every example ships a ready-made `…-example-debug.yaml` next to it that does
exactly this.

## References

* https://github.com/syssi/esphome-pipsolar
* https://github.com/esphome/esphome/pull/1664
* https://github.com/esphome/esphome-docs/pull/1084/files
* https://github.com/andreashergert1984/esphome/tree/feature_pipsolar_anh
* https://github.com/jblance/mpp-solar/tree/master/docs/protocols
