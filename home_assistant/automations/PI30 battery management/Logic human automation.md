# Human logic - PI30 Battery Charging Intelligent Modulation

Sensors used:
- `sensor.goodwe_battery_state_of_charge` (Goodwe SOC)
- `sensor.goodwe_battery_voltage` (Goodwe voltage)
- `sensor.potenza_contatore` (grid meter power)
- `sensor.goodwe_battery_power` (Goodwe battery power)
- `sensor.heltec_pi30_display_pi30_max_utility_charging_current` (utility charging current confirmed by the inverter)
- `sensor.heltec_pi30_display_pi30_max_total_charging_current` (total charging current confirmed by the inverter)
- `input_number.pi30_max_manual_current` (helper to create manually: upper limit the automatic modulation must never exceed)

Writes:
- `select.heltec_pi30_display_pi30_set_max_utility_charging_current`
- `select.heltec_pi30_display_pi30_set_max_total_charging_current`
- `script.pi30_batteria_da_caricare` (CHARGE)
- `script.pi30_batteria_da_scaricare` (DISCHARGE)

Possible utility current steps: `2 10 20 30 40 50 60`

---

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
				(Charging power at minimum, but still NOT drawing much from the grid or NOT drawing much from goodwe)
				(HIGHER VALUES than modulation, for hysteresis)
				Charging power sensor.heltec_pi30_display_pi30_max_utility_charging_current = 2 A
				AND
					sensor.potenza_contatore < 500
					OR
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
		THE STEP CAN NEVER EXCEED input_number.pi30_max_manual_current (MAX MANUAL CURRENT)
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

---

## MAX MANUAL CURRENT

Helper to create manually in Home Assistant (Settings > Automations & Scenes > Helpers > Number):
- entity_id: `input_number.pi30_max_manual_current`
- min: 2, max: 60, step: 1 (any step works: the automation always rounds down to the nearest valid step)

If set to, say, 40:
- the STEP UP phase will never go above 40A;
- if the current is already above 40A (because the limit was lowered while the system was charging at a higher step), the automation immediately brings it back down to the highest valid step not exceeding 40 (i.e. 40).

## Trigger

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
