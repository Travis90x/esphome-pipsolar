# LiFePO4 8S SOC (voltage + current)

*[Versione italiana](README.md)*

## Why voltage alone isn't enough

The 8S LiFePO4 pack has a Volt/SOC curve that's very flat between
roughly 20% and 80%: a few hundredths of a volt correspond to tens of
percentage points of SOC. On top of that, the curve "shifts" depending
on how much current the battery is drawing or delivering at that
moment (internal resistance drop): the same measured voltage can
correspond to different SOC depending on whether the battery is
charging hard, discharging hard, or resting. A SOC sensor based only
on instantaneous voltage (like `sensor.heltec_pi30_battery_soc`, the
one read from the PI30 protocol) is therefore inaccurate exactly in
the middle of the curve, where it matters most.

## How this solution works

Instead of reading SOC from voltage, it integrates over time the
current from `sensor.heltec_pi30_battery_current` (positive while
charging, negative while discharging: already the case for this
sensor) against the pack's nominal capacity (155Ah): the classic
"coulomb counting" used by BMSs.

The problem with pure coulomb counting is that it accumulates error
over time (drift). To eliminate it, the estimate is "re-anchored" at
the two extremes using voltage — but not the raw one, the one
compensated for the internal resistance drop (see the dedicated
section below), otherwise it would snap too early while charging and
too late while discharging:

- **100%**: when the compensated voltage (voltage_ocv) reaches the
  charger's float voltage
  (`sensor.heltec_pi30_display_pi30_battery_float_voltage` minus 0.1V
  margin). At that point the battery is by definition full, whatever
  the Ah count says.
- **0%**: when voltage_ocv drops below the under-voltage threshold
  (`sensor.heltec_pi30_display_pi30_battery_under_voltage`) plus a
  0.2V margin, so we reach 0% a bit before the BMS itself disconnects
  the battery for low voltage.

Between these two extremes, SOC only moves by integrating current,
every 2 minutes.

## Components (all from UI, no `configuration.yaml`)

The automation, the script and the helpers are in English (alias,
descriptions, UI field text): this file and its Italian counterpart
are the only bilingual documentation.

1. **`Helper 1 - SOC Calculated Number.md`**: create the "Number"
   helper `input_number.pi30_battery_soc_calculated` from the UI.
   It's the container the automation writes to, no template.
2. **`Automation - PI30 Battery SOC Coulomb Counting.yaml`**: regular
   import in Settings > Automations > Edit in YAML (stays inside the
   automation editor, doesn't touch `configuration.yaml`). Does the
   integration and the re-anchoring described above.
3. **`Helper 2 - SOC Calculated Template Sensor.md`**: create the
   "Template > Sensor" helper `sensor.pi30_battery_soc_calculated`
   from the UI, which reads Helper 1 and exposes it as a proper
   battery sensor (`device_class: battery`), usable in
   dashboards/graphs like any other SOC sensor.
4. **`Script - PI30 Battery SOC Recalibrate from Voltage.yaml`**
   (optional but recommended on first setup): import in Settings >
   Automations & scenes > Scripts > Edit in YAML. Run it once right
   after creating Helper 1, so it doesn't start at 0%: it linearly
   interpolates the compensated voltage between the two real extremes
   (under-voltage+0.2V = 0%, float-0.1V = 100%) and immediately sets
   Helper 1 to that estimate, instead of waiting for coulomb counting
   to climb up from zero or for the pack to touch one of the two
   extremes. It's a straight line, not the real LiFePO4 curve: fine as
   a starting point, not as a substitute for daily coulomb counting —
   don't run it routinely (see the warning in the script's
   description).

Create the helpers in order, 1 then 2 (2 reads 1's entity_id). After
creating everything you'll have `sensor.pi30_battery_soc_calculated`
(exact name depends on the entity_id HA assigns, check in Settings >
Entities).

## Tuning

- **Pack capacity**: 155Ah, set in the `capacity_ah` variable of the
  automation. If you change/add cells, just edit that number.
- **Integration cadence**: 2 minutes (`cadence` trigger). If you
  change it, also update `dt_hours` in the same automation
  (`dt_hours = trigger_minutes / 60`), otherwise the integration will
  be wrong.
- **Re-anchoring margins** (0.1V below float for 100%, 0.2V above
  under-voltage for 0%): in the `full_threshold`/`empty_threshold`
  variables, adjustable if you want a wider or narrower anchor.

### Internal resistance calibration (`internal_resistance_ohm`)

Same pack voltage, different currents, very different real SOC: 27.5V
at a few Amps is nearly 100%, 27.2V at 39A while charging can be a
much lower SOC, because current "inflates" (while charging) or
"deflates" (while discharging) the measured voltage relative to the
true resting voltage (OCV). Both the automation and the script correct
for this with:

```
voltage_ocv = voltage - (current * internal_resistance_ohm)
```

(same sign convention as the current sensor: positive while charging,
negative while discharging — the formula works both ways without
needing two separate branches).

**Current value: `internal_resistance_ohm = 0.0095` (9.5 mOhm)**,
calibrated on the real pack from a log exported from the JK BMS
(JK-B2A8S20P). The BMS **is not connected via RS485** or any other way
to Home Assistant or the ESP32: the data was obtained by exporting the
log history from the JK phone app and passing it here for analysis.

Method: in the log, every time a "Cell XX over charge protection"
event fires, the charger is cut off, and 2-3 seconds later a
"protection is released" event follows — in this short window the
real SOC (the BMS's "SOC Cap. Remain (AH)" column) doesn't have time
to change, but current drops from ~35-39A (charging) to roughly
0/-0.6A. These are therefore (V1,I1)/(V2,I2) pairs at the same SOC,
perfect for `R ≈ ΔV/ΔI`. There were 19 such pairs in the log; taking
a weighted average of ΔV and ΔI (sum ΔV / sum ΔI, more robust than
averaging the individual ratios) gives R ≈ 9.5 mOhm, with individual
samples ranging roughly 7-14 mOhm (noise from the log's 0.01V
resolution).

Cross-validation from the same log:
- When current is near 0 and the BMS's SOC is near 100%, pack voltage
  settles around 27.5-27.6V: confirms that the "float_voltage=27.5V →
  100%" anchor is correct.
- The single deep-discharge event recorded (BMS SOC = 0.0Ah) shows
  21.41V: well below the conservative safety threshold used for 0%
  (under_voltage+0.2V = 24.0V), confirming that safety margin is ample
  relative to the pack's true bottom (not a risk, intentionally
  conservative).

**This value is considered final for now**: it is not a placeholder
awaiting more data, and there are no open action items or ongoing work
on this point. If the pack changes in the future (new cells, different
wiring) or an obvious drift is noticed, the method to recompute R
stays the same: two readings of
`sensor.heltec_pi30_battery_voltage` / `sensor.heltec_pi30_battery_current`
at different currents close together in time, or a new BMS log export
with events similar to the ones used here.

## Possible future development: BMS connected via RS485

The JK-B2A8S20P BMS already runs its own internal coulomb counting
(the "SOC Cap. Remain (AH)" / "SOC Full Charge Cap. (AH)" columns in
the log), likely more accurate than what is rebuilt here (factory
calibration, temperature compensation, per-cell balancing). In the
future the BMS could be wired to the ESP32 over RS485 (or Bluetooth)
to read its SOC directly, which could replace this automation in
whole or in part.

**This is not currently a work in progress**: it's just a future idea,
neither planned nor started. The current solution (voltage + current,
with internal resistance calibrated as above) is considered good
enough and stable.

## Integration with the existing charge/discharge automation

This sensor is meant to sit alongside, not immediately replace,
`sensor.heltec_pi30_battery_soc` and the logic already present in
"PI30 battery management" (which today mainly uses
`sensor.goodwe_battery_state_of_charge` and voltages). Once you've
verified for a few days that the calculated value is plausible
(compare it against the battery's real behavior: it settles at 100%
when you know it's full, drops consistently under load), you can
decide to use it instead of (or alongside) the other SOC sensors in
the main automation's conditions.
