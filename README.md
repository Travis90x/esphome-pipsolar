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
| [`heltec-pi30-display-pipsolar.yaml`](examples/esp32/heltec-pi30/heltec-pi30-display-pipsolar.yaml) | core `pipsolar` component | 906 |
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
friendly name `PI30`) — it's the config actually producing the
entity naming (`sensor.pi30_battery_voltage`,
`sensor.pi30_*`, …) that the Home Assistant automations
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
(device name `heltec-inverter`, friendly name `PI30`, see "The
Heltec PI30 display examples" above): `sensor.pi30_battery_voltage`,
`sensor.pi30_battery_current` (positive while charging, negative while
discharging), and the `sensor.pi30_*` family — the QPIRI
setpoints read back from the inverter (float/under/recharge/redischarge/bulk
voltage, max charging currents, etc.) together with their writable
`number.pi30_set_*` / `select.pi30_set_*`
counterparts.

Every firmware entity has an id `<domain>.pi30_<name>` (for example
`number.pi30_set_battery_recharge_voltage`, `button.pi30_charger_solar_utility`,
`sensor.pi30_battery_charge_energy_today`): the friendly name `PI30` plus a
short English name. **If you come from the previous firmware** (entities
`…heltec_pi30_display_pi30_…`, `…heltec_pi30_pi30_…`, `sensor.heltec_pi30_…`):
after the update Home Assistant creates the new entities and leaves the old
ones "unavailable"; delete them from Settings > Devices & services > ESPHome
> PI30 device (or the Entities list, filtered on "unavailable"). The new
entities start with an empty history. The automations, scripts and
dashboards in this repository already use the new ids.

[`home_assistant/dashboard/inverter_ita.yaml`](home_assistant/dashboard/inverter_ita.yaml)
and [`inverter_eng.yaml`](home_assistant/dashboard/inverter_eng.yaml) are
complete dashboards (Italian / English) for whoever has just the inverter
and its battery, without GoodWe: an overview with the calculated SOC,
battery management (manual CHARGE and DISCHARGE/HOLD with the two scripts,
minimum voltage, charging bulk and float, SOC), charged and discharged
energy, 24-hour graphs, priorities, battery settings, configuration,
command console, diagnostics. Import them from Settings > Dashboards > Add
dashboard > New dashboard from scratch, then pencil, three dots > Raw
configuration editor, and paste the file.

### Dynamic utility-charging modulation

Files: [`home_assistant/automations/PI30 battery management/`](<home_assistant/automations/PI30 battery management/>)
- `Automazione - PI30 Batteria MAN.yaml`
- `Script - PI30 batteria da caricare.yaml`, `Script - PI30 batteria da scaricare.yaml`
- `Aiutanti - PI30 Ricarica Batteria.yaml` (the helpers to create)
- `Aiutante - PI30 Modalita MAN (Sensore template).yaml` (optional: the mode as one steady value)

The scripts and the automation are pasted with "Edit in YAML". The two
`Aiutante`/`Aiutanti` files are not: they say what to create under Settings >
Devices & services > Helpers > Create helper, and their YAML block is only for
`configuration.yaml`. The file, script and mode names are in Italian, as in
the owner's Home Assistant.

Goal: charge the PI30's LiFePO4 pack from the grid **only with the GoodWe's
PV surplus**, use it to power the loads when there is no surplus, and never
let it fall to the BMS cut-off. The automation runs on startup, every 2
minutes and on every GoodWe sensor change (held for 10 seconds), picks the
mode and, in CHARGE, sets the utility current.

Sensors read:

| Entity | Meaning |
| :--- | :--- |
| `sensor.goodwe_battery_state_of_charge` | GoodWe SOC |
| `sensor.goodwe_battery_voltage` | GoodWe voltage |
| `sensor.potenza_contatore` | grid meter power (negative = export) |
| `sensor.goodwe_battery_power` | GoodWe battery power (positive = delivering) |
| `sensor.pi30_output_source_priority` / `_charger_source_priority` | the two priorities, i.e. the current mode |
| `sensor.pi30_max_utility_charging_current` | utility charging current confirmed by the PI30 |
| `sensor.pi30_device_mode` | Line mode / Battery mode |
| `sensor.pi30_battery_voltage` | PI30 battery voltage |
| `sensor.pi30_battery_under_voltage` | inverter undervoltage threshold (24.0V if unreadable) |
| `sensor.pi30_battery_soc_calculated` | calculated SOC (next section) |
| `sensor.pi30_output_active_power` | PI30 loads |
| `sensor.pi30_grid_voltage` | grid voltage read by the PI30 (notification only) |

#### Diagram

```
EVERY RUN
(on startup, every 2 min, on every meter or GoodWe change,
 at once if the GoodWe delivers > 200 W or the meter imports > 300 W)
│
├─ 0. SAFETY FIRST
│   ├─ Charging off ("PI30 Ricarica Batteria" off) ..........► DISCHARGE
│   ├─ PI30 pack ≤ 24.0V (undervoltage threshold) ...........► DISCHARGE
│   ├─ In CHARGE but PI30 not in Line mode for 5 min ........► notification + 2A
│   │  (no grid on the AC input)
│   ├─ PI30 sensors unavailable .............................► wait
│   ├─ GoodWe sensor unavailable for < 10 min ...............► wait
│   └─ Meter or GoodWe power unreadable for > 10 min ........► DISCHARGE
│
├─ A. SURPLUS
│   │  = GoodWe full (100%, or 99% idle)
│   │  AND GoodWe battery not delivering (< 200 W)
│   │  AND export covering the PI30 loads + 60 W,
│   │      or ≥ 250 W (at the cap the GoodWe clips the PV)
│   ▼
│   CHARGE (utility first, solar + utility, bulk 29.0 / float 27.0)
│   │  always enters at 2A
│   │
│   ├─ UP one step (2→10→20→30→40→50→60, max "PI30 Max Manual Current")
│   │     if GoodWe full
│   │     AND export ≥ power of the next step (or ≥ 250 W)
│   │     AND GoodWe idle (< 100 W) AND current unchanged for 20 s
│   │
│   ├─ DOWN AT ONCE to the step that stops the draw
│   │     if the meter imports ≥ 300 W  OR  the GoodWe delivers ≥ 200 W
│   │
│   ├─ DOWN TO 2A AT ONCE
│   │     if a reading is missing: GoodWe SOC or voltage, PI30 pack voltage
│   │     or if the GoodWe drops below 98% (it is recharging: it has priority)
│   │
│   ├─ DOWN GRADUALLY, one step every 2 min, to 2A
│   │     if the heat sink is at the temperature limit, or unreadable
│   │
│   ├─ STAYS, nothing rewritten
│   │     otherwise (also with the GoodWe at 98-99%:
│   │     no step up and no exit, no 99 ↔ 100 flapping)
│   │
│   ├─ "TO ZERO" = goes to DISCHARGE (the inverter has no step below 2A)
│   │     if already at 2A AND (meter ≥ 300 W OR GoodWe ≥ 200 W
│   │     OR GoodWe below 98%) for 60 s
│   │
│   └─ full pack: the charger goes from bulk to float
│      by itself and holds it there ...................► helper: PIENA
│
└─ B. NO SURPLUS
    │  (GoodWe not full, GoodWe delivering, import, not enough export)
    ▼
    DISCHARGE (SBU, solar + utility, bulk = float = 25.5V, 10A)
    │  stays at least 10 minutes (anti-oscillation)
    │
    ├─ pack above 25.5V: powers the loads ..............► helper: IN SCARICA
    │
    ├─ pack down to 25.5V (recharge voltage):
    │  loads on the grid (BYPASS), charger holding
    │  it at 25.5V covering the ~50 W ..................► helper: MANTENIMENTO
    │  (the inverter does it by itself; 10A even with the
    │   temperature unreadable, as 2A cannot cover the hold)
    │
    └─ back to CHARGE when there is surplus again (branch A)
```

#### Modes and scripts

| Mode | Script | Output | Charger | Bulk and float | Utility current |
| :--- | :--- | :--- | :--- | :--- | :--- |
| IN CARICA (charge, and PIENA, full) | PI30 batteria da caricare | utility first | solar + utility | charging values (29.0 / 27.0V) | from 2A, modulated |
| IN SCARICA / MANTENIMENTO (discharge / hold) | PI30 batteria da scaricare | SBU | solar + utility | at the hold voltage (25.5V) | 10A |

- **CHARGE**: the PI30 loads go to the grid and the pack charges with the
  surplus. On entry the utility current starts at 2A; then the automation
  sets it (below). The pack looks after itself: the charger goes from bulk
  to float and, once full, holds it in float with the loads on the surplus.
  Until 24 Oct 2026 there was a separate FULL mode (utility first, solar
  only), from when every return to CHARGE on a full pack started at 15-30A
  and bulk reached 29.0V within a minute (five times in 40 minutes on 29
  Sep). With entry at 2A and the 10-minute anti-oscillation it is not needed.
- **DISCHARGE and HOLD** are the same script. The pack powers the loads until
  it falls to the inverter's recharge voltage; there the PI30 moves the loads
  to the grid and, with bulk and float at the hold voltage, the charger keeps
  the pack there, covering only the inverter's own consumption (about 50 W)
  and self-discharge: no recharge above it, no drift below it. The inverter
  does this by itself, the automation does not have to notice.

The scripts only write what differs: with nothing to write they finish at
once. The automation calls them on every run with `script.turn_on` by
**entity id** and waits until they are `off` again (at most 120 s), so two
scripts never overlap. Do not call them as direct actions
(`action: script.pi30_...`): that action uses the configuration id, which for
a script created in the UI is not the entity id (on 24 Oct 2026 every run
stopped with "unknown action" and nothing started with the pack at 24.0V).
The entity ids must be `script.pi30_batteria_da_caricare` and
`script.pi30_batteria_da_scaricare`.

**The scripts are not the mode.** A script is `on` only while it runs, a
moment at each run. The mode is read from the priorities; the optional
`PI30 Modalità MAN` helper (Template > Sensor, file
`Aiutante - PI30 Modalita MAN (Sensore template).yaml`) shows it as
`IN CARICA`, `PIENA` (in CHARGE with the charger in float), `IN SCARICA` or
`MANTENIMENTO` (SBU output with the loads on the grid, or the pack within 0.3V
of the hold voltage), `ALTRO` for priorities set by hand.

#### Helpers

| Helper | What it does | Without it |
| :--- | :--- | :--- |
| `input_boolean.pi30_ricarica_batteria` ("PI30 Ricarica Batteria", Toggle) | off: always DISCHARGE, the pack is never recharged but stays at the hold voltage | as on |
| `input_number.pi30_bulk_carica` / `_float_carica` ("PI30 bulk carica" / "PI30 float carica") | charging bulk and float, written by PI30 batteria da caricare: change them here, not on the inverter | 29.0 / 27.0V |
| `input_number.pi30_keep_battery_live` ("PI30 keep battery live") | hold voltage of DISCHARGE and HOLD; at least 24.0V and **below the inverter's redischarge voltage**, or in SBU the PI30 goes back to discharging and the grid recharges it every cycle | 25.5V |
| `input_number.pi30_max_manual_current` ("PI30 Max Manual Current") | highest utility current step (an in-between value counts as the lower step, 35 = 30) | 40A |
| `input_number.pi30_charging_max_temperature` ("PI30 Charging Max Temperature") | optional heat-sink temperature limit (below) | no limit |

Changing a helper re-runs the automation at once and applies it. Do not
disable the automation instead of the charging switch: disabled it does not
protect the pack (on 25 Sep 2026 the BMS shut the inverter down at 22:00).

#### Order of the checks

1. **Charging off, or pack at the undervoltage threshold** → DISCHARGE. At the
   threshold (24.0V), from any mode: with bulk and float at the hold voltage
   and 10A the pack comes back up. A trigger reacts within a minute of the
   threshold. 2A are not enough: on 26 Sep the PI30 read +2A while the pack
   fell from 23.6V to 22.8V and the BMS cut it.
2. **PI30 off the grid**: in CHARGE but not in Line mode for 5 minutes, with
   the priorities unchanged for as long, the PI30 is not using the grid.
   Persistent notification "PI30 non sta usando la rete" (id
   `pi30_fuori_rete`, with the grid voltage read by the PI30), current to 2A,
   no modulation. The notification goes away once it is back in Line mode.
   On 23 Oct 2026 the PI30 AC input read 0 V from 14:49 to 20:40: the PI30, in
   CHARGE, went to Battery mode with the meter at -300 W. The 10-second drops
   (voltage dips to 103-151 V) do not count.
3. **Missing GoodWe readings**: a GoodWe sensor `unavailable`/`unknown` for
   less than 10 minutes decides nothing (on 4-5 Oct sixteen gaps of a few
   seconds had caused eleven mode changes). Meter or GoodWe power unreadable
   for more than 10 minutes → DISCHARGE: without them the draw cannot be seen,
   and DISCHARGE holds the pack at the minimum by itself. Until 24 Oct 2026
   this case charged at 2A. With the PI30 sensors unavailable (for example
   while ESPHome reconnects) it decides nothing: there is nothing to write to.
   A GoodWe sensor that disappears during the 60 seconds of check 4 does not
   count as a draw.
4. **Charging at the minimum is not enough** ("WHICH MEANS"): in CHARGE at 2A
   with the meter importing >= 300 W, the GoodWe delivering >= 200 W or the
   GoodWe below 98% for 60 seconds → DISCHARGE, the same thresholds as the step-downs (500 W until 24
   Oct 2026). Under 60 s it is the load transfer, a transient.
5. **Anti-oscillation**: moved to DISCHARGE less than 10 minutes ago, it
   stays. Without it, with a borderline surplus the PI30 went CHARGE ↔
   DISCHARGE every 20-40 seconds (20-34 times a day between 27 Sep and 2 Oct).
6. **Surplus**: outside CHARGE the PI30 enters only with the GoodWe full (100%,
   or 99% with its battery idle) and an export covering its loads plus 60 W,
   or at the export cap minus 50 W (250 W: above 300 W the GoodWe clips the PV
   and the real surplus is not visible). Otherwise DISCHARGE. On 4 Oct the PI30 tried CHARGE with 500 W of loads and
   120-240 W of export, six times in one evening.
7. **CHARGE**: it enters at 2A and the current is modulated from the next run.

#### Current modulation in CHARGE

Steps: `2 10 20 30 40 50 60`, up to "PI30 Max Manual Current" and the
temperature limit.

- **Up** one step only with visible surplus: export at least as large as the
  next step ((step - current) × PI30 voltage) or at the 250 W cap, GoodWe
  battery below 100 W, and the current unchanged for 20 seconds (the GoodWe
  sensors are slower than the PI30).
- **Down at once**, as soon as the meter imports >= 300 W or the GoodWe
  delivers >= 200 W: to the highest step that stops the draw, leaving at most
  100 W (40A with 466 W from the GoodWe to 20A, 60A with 1.7 kW to 2A, 40A
  with +600 W at the meter to 20A). It never charges from the grid or the
  GoodWe battery. Two triggers (GoodWe over 200 W, meter over 300 W) react
  without waiting for the 10 seconds of the others.
- **Down to 2A at once** if a reading is missing (GoodWe SOC or voltage, PI30
  pack voltage) or if the GoodWe drops below 98%: it is recharging and has
  priority. Already at 2A, after 60 seconds like that, DISCHARGE.
- **Down gradually** only for temperature (below).
- **In between it stays** and is not rewritten to the inverter.
- It only goes up with the GoodWe full (100%, or 99% with its battery idle:
  its BMS may stop at 99 for hours). If the GoodWe drops to 98-99% during
  CHARGE the current does not go up but the PI30 does not leave (below 98%,
  see above): the GoodWe
  SOC flaps between 99 and 100, and on 4 Oct a momentary 99 had sent a PI30
  in float to DISCHARGE with -311 W at the meter. The old exceptions (GoodWe
  above 55V, 100% below 53V, step from 2 to 10A with the GoodWe not full) went
  on 24 Oct 2026: that morning the GoodWe read 55V at 91% while charging at
  3 kW.

Before 23 Oct 2026 the step-up rule was "meter < 300 W and GoodWe < 200 W",
which also fired with the meter at zero and the GoodWe already delivering
100-199 W, and above 250 W from the GoodWe the current always went back to 2A:
with the GoodWe full that was a 2-40-2A sawtooth every 1-3 minutes (114
current changes and 20 crashes to 2A between 16:00 and 17:00 on 22 Oct), and
the same value was rewritten to the inverter at every run.

**Temperature limit.** With `input_number.pi30_charging_max_temperature` (for
example 70°C) and `sensor.pi30_heat_sink_temperature`: from the limit
up the utility current drops one step every 2 minutes down to 2A, without
stopping the charge; between the limit minus 5°C and the limit it stays;
below it rises normally. With the limit set and the temperature unreadable it
counts as over the limit. It also applies to the 10A of DISCHARGE (passed to
the script as `current_limit`), but only with a temperature reading:
unreadable, DISCHARGE keeps 10A, as 2A cannot cover the hold. For the same
reason "PI30 Max Manual Current" only limits CHARGE, not the hold. The
2-minute periodic check makes the current step down even when no other sensor
changes.

#### Why only two scripts

Until 24 Oct 2026 DISCHARGE was "SBU + solar only" and a second script (KEEP)
set bulk and float to the hold voltage when the pack reached the threshold;
a third (keep battery live) did the same with charging off. With "solar
only" the grid never recharges: in Line mode at night the pack drifted down
on the inverter's own consumption to the threshold (on the morning of 24 Oct
from 24.9V to 23.8V in three hours, with the grid present) and the automation
had to step in. With bulk and float already at the hold voltage DISCHARGE
stops at the minimum by itself: the inverter moves to the grid at the
recharge voltage and the charger covers only the own consumption. The three
scripts became one, and the undervoltage threshold stays only as a safety
net. For the same reason FULL merged into CHARGE (above): in both cases the
charger looks after the pack. The hold is not a flat line: the PI30 charger switches on and off
around the setpoint, and in SBU the inverter returns to Battery mode after
float, so at night it alternates 10-15 minutes on the grid and 10-15 on the
battery near the hold voltage. At 24.0V (2%, steep curve) the voltage made a
0.5V sawtooth every 25 minutes; at 25.5-25.8V (15%, flat curve) the same
pulse moves it by a few hundredths.

**Triggers:**

```yaml
triggers:
  - trigger: homeassistant          # startup
  - trigger: time_pattern           # every 2 minutes
    minutes: /2
  - trigger: numeric_state          # GoodWe delivering over 200 W
    entity_id: sensor.goodwe_battery_power
    above: 200
  - trigger: numeric_state          # meter importing over 300 W
    entity_id: sensor.potenza_contatore
    above: 300
  - trigger: state                  # GoodWe sensors and meter, held 10 s
    entity_id:
      - sensor.goodwe_battery_state_of_charge
      - sensor.goodwe_battery_voltage
      - sensor.potenza_contatore
      - sensor.goodwe_battery_power
    for:
      seconds: 10
  - trigger: template               # PI30 pack at the threshold for 1 minute
  - trigger: template               # heat sink at the temperature limit
  - trigger: state                  # charging switch
  - trigger: state                  # number helpers
```

### Real SOC via energy counting (voltage + energy in/out)

Files: [`home_assistant/automations/PI30 battery SOC/`](<home_assistant/automations/PI30 battery SOC/>)
- `Automazione - PI30 SOC batteria.yaml`
- `Script - PI30 SOC ricalibra da tensione.yaml`
- `Aiutante 1 - PI30 SOC calcolato (Numero).yaml`
- `Aiutante 2 - PI30 SOC calcolato (Sensore template).yaml`

(the files and their descriptions are in Italian; the entity ids are the same)

The 8S LiFePO4 pack has a Volt/SOC curve that's very flat between roughly 20%
and 80%: a few hundredths of a volt correspond to tens of percentage points
of SOC. On top of that, the curve shifts depending on how much current the
battery is drawing or delivering at that moment (internal resistance drop).
A SOC sensor based only on instantaneous voltage (like
`sensor.pi30_battery_soc`, read from the PI30 protocol) is therefore
inaccurate exactly in the middle of the curve, where it matters most.

**How it works.** Instead of reading SOC from voltage, it counts the energy
that goes in and out of the pack against the pack's usable capacity in kWh:
once a minute (and at startup, and whenever you run the automation by hand)
it reads the battery charge and discharge power
(`sensor.pi30_battery_charge_power` and
`sensor.pi30_battery_discharge_power`, the same two sensors the
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
  float voltage (`sensor.pi30_battery_float_voltage`
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
  than a "tail current" value. A count that says "3.9 kWh went in" is
  not evidence either: it stops at 99 and waits for this anchor. The
  5-minute hold filters out surface
  charge: right after the charger cuts off, a half-full LiFePO4 pack sits
  near the charge voltage for a minute or two before relaxing to its
  resting voltage.
  The inverter's *charging to floating mode* flag
  (`binary_sensor.pi30_charging_to_floating_mode`)
  is deliberately **not** part of this anchor: it describes the
  charger's stage, not the battery's state, and the PI30 keeps it
  raised after sunset, all night long while the pack is discharging,
  until the charger goes back to bulk. Used as an alternative to the
  voltage test it re-wrote 100% every 2 minutes for the whole night
  (a discharging pack always passes the "not being pushed" test),
  pinning the sensor at 100% whatever the real state of charge.
- **0%** (`empty_hold` trigger) when `voltage_ocv` drops below the
  under-voltage threshold
  (`sensor.pi30_battery_under_voltage`) plus a 0.2V
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
SOC -= (discharge_kW + idle_drain) × hours / capacity_kwh × 100
```

`hours` is the **measured** time since the previous run (from the
automation's own `last_triggered`), capped at 5 minutes so that a long
outage does not integrate the power read at boot over hours of unknown
history. The constants are **measured on this system** over a complete
full → empty → full cycle and rechecked on ten more half cycles (see
"What three days of history say" and "What seven more days say" below):

- `capacity_kwh` = **3.9 kWh**, the energy the pack delivers from 100% to 0%
  (the nominal 155Ah × 25.6V is 3.97 kWh).
- `charge_efficiency` = **0.91**, the share of each charged kWh the PI30
  reports that ends up stored in the pack (three full charges took 4.23,
  4.26 and 4.33 kWh from 0% to 100%).
- `idle_drain_light_w` = **65 W** and `idle_drain_heavy_w` = **15 W**, the
  power the pack loses that the PI30 never reports: the inverter's own
  consumption plus what its current reading misses, taken from the battery
  whenever the charger is not really running. The light value applies when
  the reported discharge is at most `light_load_w` (150 W, 0A included),
  the heavy one above: compared with the inverter's AC output power, the
  reported battery power is 60-65 W short at light load and only 10-20 W
  short above about 150 W. It is subtracted every minute in which the
  charge power is 60 W or less (`small_charge_w`), except at float.

**Phantom charge.** A reported charge of 60 W or less (1-2A) is not counted
as charge: it is the PI30's own consumption or an offset of its current
reading. On 24-26 Sep 2026 the PI30 read +1A for 8 hours at night in Battery
mode with the charger off (the old count went up from 61% to 65%, the voltage
said 50%), +1A on 25 Sep evening in Line mode with the charger on "solar
only" in the dark while the pack went from 24.5V to 22.7V and the BMS cut it
(the old count went from 5% to 6%), and +2A on 26 Sep night while grid
charging at 2A and the pack went from 23.6V to 22.8V. The only exception is
float (voltage >= `full_floor_v`, nothing discharging): there the charger holds
the full pack and feeds the inverter itself, so nothing is counted and an
anchored 100% stays 100%. Replayed minute by minute on 24-26 Sep, the new
count ends the night at 51% instead of 65% and reaches 0% together with the
voltage on the 25th evening instead of rising.

The power
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

Prerequisite: none. The battery charge and discharge power sensors
(`sensor.pi30_battery_charge_power` and
`sensor.pi30_battery_discharge_power`, W, both ≥ 0) and the lifetime kWh
counters (`sensor.pi30_battery_charge_energy` and
`sensor.pi30_battery_discharge_energy`, plus today's
`sensor.pi30_battery_charge_energy_today` and
`sensor.pi30_battery_discharge_energy_today`) are computed by the ESPHome
firmware. The Home Assistant helpers that used to do the same job
(`sensor.heltec_pi30_batteria_potenza_carica` and the like) are no longer
needed and can be deleted.

Both helpers are in the same folder as the automation, each with the UI
recipe and the `configuration.yaml` equivalent:
`Aiutante 1 - PI30 SOC calcolato (Numero).yaml` and
`Aiutante 2 - PI30 SOC calcolato (Sensore template).yaml`.

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
   `sensor.pi30_battery_soc`, which is voltage-based and happily
   sits at 100% for hours. On first save, set it to something
   close to `sensor.pi30_battery_soc`'s current reading — the
   automation re-anchors it the first time the pack completes a charge
   (or runs empty) anyway. The automation writes 3 decimals into it; the
   `0.1` step only affects the slider, `set_value` is not limited by it.
2. **Template sensor helper** (Settings → Devices & services → Helpers →
   Create helper → Template → Sensor): Name `PI30 battery SOC
   calculated`, unit `%`, device class `Battery`, state class
   `Measurement`, and as **State**:
   ```
   {{ states('input_number.pi30_battery_soc_calculated') | float(default=0) | round(0) }}
   ```
   This creates `sensor.pi30_battery_soc_calculated`,
   the proper battery sensor the dashboards in `home_assistant/dashboard`
   use, usable in graphs like any other SOC sensor. Create it after the
   Number helper (it reads that entity_id).

Then import `Automazione - PI30 SOC batteria.yaml` (Settings → Automations
& scenes → Create automation → Create new automation, three dots → Edit in
YAML) to do the integration and re-anchoring above. If you already have
the SOC automation, paste the file over its YAML instead of creating a new
one: its entity id stays the same.

**Hold and float: counting frozen.** While the charger holds the battery
at the programmed float voltage — float on a full pack, or the
MANTENIMENTO (hold) state of "PI30 Batteria MAN" (SBU, loads on the grid,
bulk and float at the minimum voltage) — the SOC does not move: voltage at
least float − 0.1V, no discharge, charge below 60W and, below 27.2V, Line
mode. There the charger covers the inverter's own consumption, so the
hidden drain (65W) must not be subtracted: before, the count ran down to 0
in a few hours while the pack sat at 25.5V. The voltage correction is off
too, because the voltage is the one the charger imposes.

Optionally, right after creating the Number helper, run
`Script - PI30 SOC ricalibra da tensione.yaml` **once** (Settings
→ Automations & scenes → Scripts → Add script → Create new script, three
dots → Edit in YAML, then run it) so the counter doesn't start at 0%: it
reads the compensated voltage on the same voltage/SOC table as the
automation and seeds the Number helper. It does nothing while the battery
is charging or in Line mode, where the voltage says nothing about the SOC.
It is accurate at the ends and wide in the middle — fine as a starting
point, not a substitute for daily energy counting. **Don't run it
routinely**: doing so on every voltage tick-up turns the sensor back into
something based on instantaneous voltage alone, defeating the point of
energy counting (see the warning in the script's own description).

**Voltage correction.** The count alone cannot know where it started: set
wrong (a stale 100, a helper created mid-discharge) it would stay wrong until
the next full charge. So every minute the voltage, compensated for the real
current (the reported one plus the 50 W idle drain) with the steady-state
resistance measured on this pack (10 mOhm), is turned into a SOC through a
table measured from 0% to 99% on this pack, and the count is pulled towards
it — only when the voltage can be trusted, and only when it clearly
disagrees:

| Compensated voltage (V) | 22.70 | 23.40 | 24.00 | 24.50 | 25.00 | 25.60 | 25.96 | 26.22 | 26.42 | 26.57 | 26.67 | 26.75 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| SOC (%) | 0 | 1 | 2 | 4 | 6 | 9 | 20 | 30 | 50 | 65 | 75 | 99 |

- **Trusted** means discharging or idle (a phantom +1/+2A counts as 0A), at
  most 30A, not at float, with the charger off for at least 60 minutes:
  charge power at most 60 W and either 0 W unchanged for 60 minutes or both
  charger flags (`binary_sensor.pi30_ac_charging` and
  `..._scc_charging`) off for 60 minutes. Right after a charge, surface charge
  makes any pack look fuller (with 30 minutes, on 26 Sep a pack at about 7%
  read 25.8V after a 1.5-hour charge and the count was pulled up to 11%), and
  while charging the voltage says nothing. The flags matter because a phantom
  +1A keeps the charge power above 0 for hours, which used to switch the
  correction off exactly while the pack was draining.
- **Clearly disagrees** means outside the band of SOCs compatible with the
  reading ±0.15V (the PI30 reports 0.1V steps). Inside the band the count
  wins; outside, the count closes the gap with a 5-minute time constant
  (about 1/5 per minute).
- The band is 25-30 points wide on the flat top (70-99%), 10-15 points below
  50%, and only a few points below 10%, where the curve bends (25.0V is 6%,
  24.0V is 2%): there the voltage leads. Example: 26.3V at -9A is 26.41V
  compensated, band 33-64%, and a counter stuck at 96% comes down to about
  65% in about 15 minutes.
- The table comes from the SOC reconstructed with the calibrated count over
  the 22-23 Sep cycle (median compensated voltage per 5% of SOC, and per
  minute in the five hours at rest before the BMS cut, 25.1V → 22.7V). The
  correction never writes exactly 100 or 0: that stays with the two anchors.

The same model written as a voltage × current table (discharge side, reported
current; while charging the voltage is not used). Each Amp drawn lowers the
reading by about 10 mV; the flat hump near 26.4-26.7V is the LiFePO4
plateau, where the voltage says little and the count decides; below 25.5V
the knee makes the voltage precise:

| Voltage | -30 A | -20 A | -10 A | -5 A | 0 A |
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

**Tuning:**
- **Pack model**: `capacity_kwh` (3.9), `charge_efficiency` (0.91),
  `idle_drain_light_w` (65), `idle_drain_heavy_w` (15) and `light_load_w`
  (150) in the automation (`actions` → `variables`), all measured (see
  below). Each anchor's Logbook line carries both lifetime
  energy counters, so a new full → empty → full cycle gives them again.
- **Cadence**: 1 minute (`cadence` trigger). It can be changed freely: the
  elapsed time is measured, nothing else depends on it. The cap on a single
  step is `max_dt_hours` (5 minutes).
- **Float trickle**: `tail_current_a` (2A, measured: see below). Do not raise
  it further, or a deliberate low-current charge would be mistaken for a
  tapered one.
- **Voltage correction**: `ocv_v` / `ocv_soc` (the table),
  `correction_band_v` (0.15V), `correction_tau_min` (5),
  `correction_resistance_ohm` (0.010), `correction_max_current_a` (30),
  `correction_rest_min` (60).
- **Phantom charge**: `small_charge_w` (60 W) and `full_floor_v` (27.2V,
  repeated in `actions` → `variables`: keep it equal to the trigger one).
- **Anchor constants**: `tail_current_a` (0A), `internal_resistance_ohm`
  (0.0095), `full_margin_v` (0.1V below float for 100%), `full_floor_v`
  (27.2V, the lowest voltage that can ever count as full: change it only
  for another chemistry or cell count) and `empty_margin_v` (0.2V above
  under-voltage for 0%) live in the
  automation's `trigger_variables`, because the anchors are triggers and
  Home Assistant does not expose trigger variables to the actions.
- **Hold times**: the `for:` of the `full_hold` (5 minutes) and
  `empty_hold` (1 minute) triggers.

**What three days of history say (21-23 Sep 2026: voltage, current, battery
power, inverter mode and priorities exported from Home Assistant).**

- **One complete cycle happened.** Full in float on 22 Sep at 15:59, empty
  when the BMS cut the pack at 22.7V (2.84V per cell) on 23 Sep at 10:00,
  full again at 15:10. Together with a full → morning → full cycle on 21-22
  Sep that gives three energy balances for three unknowns, solved exactly:
  capacity 3.91 kWh, charge efficiency 0.874, idle drain 50 W. With those
  values the count reads 0.2% at the moment of the BMS cut and 100.0% at the
  end of the next charge.
- **The PI30 hides about 50 W.** From 04:36 to 10:00 on 23 Sep, in Line mode,
  it reported exactly 0A for five and a half hours while the pack went from
  25.1V to 22.7V at rest. That is the inverter's own consumption, never shown
  in the battery current. Over a night it is 0.6-0.9 kWh: ignoring it is
  what made the charge counter look "twice" the discharge counter in an
  earlier calibration (which had set the charge factor to 0.5 and the
  capacity to 4.5 kWh; both were wrong).
- **The voltage is almost useless from 55% to 99%.** 26.42V compensated is
  50%, 26.73V is 95%: 0.3V for 45 points, with the PI30 reading in 0.1V
  steps. Below 50% it becomes informative, and below 10% the curve bends
  sharply: 25.0V at rest is 6%, 24.0V is 2%, 22.7V is the BMS cut.
- **The inverter floats at 27.5V with +2A, for hours.** Of the minutes spent
  above 27.4V, almost all read exactly +2A and only one read 0A. With
  `tail_current_a = 0` the 100% anchor never fired; it is now 2A.

**What seven more days say (27 Sep - 3 Oct 2026: five full → empty and five
empty → full cycles, replayed minute by minute against the automation).**

- **The ends are real.** Every charge ended with the charger holding 29.0V
  and the current tapering from 39A to 2A in about ten minutes (a true CV
  tail), every discharge ended at 23.5-23.6V with 0A, where the
  under-voltage hold takes over. So the moments of true full and true empty
  are known, and the count can be checked against them.
- **The old constants were short on both sides.** The count arrived at the
  true full at 94-97 (the 100% anchor then added 3-6 points each day) and at
  the true empty with +6, -5, -5, -3 and -6 points left (the voltage correction
  below 25V mopped that up). Mid-cycle the displayed SOC was therefore off by
  up to about 5 points, right at the ends.
- **The hidden drain depends on the load.** Against the inverter's own AC
  output power, the reported battery power is about 60-65 W short on the
  2-3A nights (90 W of load reported as 55-70 W) and only 10-20 W short
  above about 150 W of load. A single 50 W made the light-load discharge
  (25 hours at 2-3A) end at +6 and the heavy ones at -5. With 65 W up to
  150 W of reported discharge and 15 W above, the same five discharges end
  within ±2 points of the true empty (the 2-3 Oct cycle, not used for the
  fit, ends at -0.3).
- **Charge efficiency is 0.91, not 0.87.** The three full charges took
  4.23, 4.26 and 4.33 kWh (0% → 100%): 3.9 / 4.27 = 0.91. With it the count
  reaches 99 at the true full and the anchor confirms it instead of
  correcting it (the 3 Oct charge, not used for the fit, ends at 99.5).
- **The pack is what the label says.** From 100% to the 23.5V hold it
  delivers 3.95-4.0 kWh and about 152 Ah (reported plus hidden), five
  cycles within 0.1 kWh of each other; refilling it takes 4.3 kWh and about
  159 Ah of reported charge (the difference is charge losses plus the PI30's
  current offset). The nominal 155 Ah × 25.6 V = 3.97 kWh is confirmed, and
  `capacity_kwh` stays 3.9. The 28 Sep day with no charge at all (the pack
  went from 52% to 32% under a full Goodwe) was the charging helper switched
  off by hand from 07:25 to 00:29 the next day, not the automation.
- **The charging automation oscillated.** Every morning (and on the 29th
  evening) the PI30 flipped CHARGE ↔ DISCHARGE every 20-40 seconds for
  about ten minutes, 20-34 switches a day, and each return to CHARGE with a
  full pack restarted the bulk stage at 29.0V. The SOC count is not
  affected (it sees the real power either way), the pack and the inverter
  are; see the anti-oscillation and the 2A entry into CHARGE of the
  charging automation above.

**Starting value.** Not needed any more: with the voltage correction, a
wrong starting value is fixed within about 15-20 minutes of discharge
wherever the voltage is informative, and the next full charge anchors it to
100% anyway.

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
`sensor.pi30_battery_soc` and the dynamic-charging automation above
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
