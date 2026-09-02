# esphome-pipsolar

![GitHub actions](https://github.com/Travis90x/esphome-pipsolar/actions/workflows/ci.yaml/badge.svg)
![GitHub stars](https://img.shields.io/github/stars/Travis90x/esphome-pipsolar)
![GitHub forks](https://img.shields.io/github/forks/Travis90x/esphome-pipsolar)

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
