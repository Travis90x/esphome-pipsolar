# Logica umana - PI30 Battery Charging Intelligent Modulation

Sensori usati:
- `sensor.goodwe_battery_state_of_charge` (SOC goodwe)
- `sensor.goodwe_battery_voltage` (VOLT goodwe)
- `sensor.potenza_contatore` (potenza al contatore/rete)
- `sensor.goodwe_battery_power` (potenza batteria goodwe)
- `sensor.heltec_pi30_display_pi30_max_utility_charging_current` (lettura corrente carica da rete confermata dall'inverter)
- `sensor.heltec_pi30_display_pi30_max_total_charging_current` (lettura corrente totale confermata dall'inverter)
- `max_manual_current` (variabile fissa dentro l'automazione, non un helper: limite massimo che la modulazione automatica non deve superare - vedi sezione "MAX MANUAL CURRENT" sotto)

Scritture:
- `select.heltec_pi30_display_pi30_set_max_utility_charging_current`
- `select.heltec_pi30_display_pi30_set_max_total_charging_current`
- `script.pi30_batteria_da_caricare` (CARICA)
- `script.pi30_batteria_da_scaricare` (SCARICA)

Step possibili corrente da rete: `2 10 20 30 40 50 60`

---

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
				(Potenza carica al minimo, ma comunque NON preleva tanto dalla rete o NON consuma tanto la goodwe)
				(VALORI PIU' ALTI di MODULAZIONE per avere isteresi)
				Potenza carica sensor.heltec_pi30_display_pi30_max_utility_charging_current = 2 A
				AND
					sensor.potenza_contatore < 500
					OR
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

---

## MAX MANUAL CURRENT

Non è un helper: è una variabile fissa dentro l'automazione stessa, in `action > variables > max_manual_current` (di default 60). Per cambiarla, apri l'automazione in modalità YAML, modifica quel numero e salva.

Se impostata ad esempio a 40:
- la fase AUMENTA STEP non salirà mai oltre 40A;
- se la corrente è già sopra 40A (perché il limite è stato abbassato mentre il sistema stava caricando a uno step più alto), l'automazione la riporta subito al gradino valido più alto non superiore a 40 (quindi 40).

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
