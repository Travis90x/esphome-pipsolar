# Helper 2: Modello → Sensore basato su modello (il "vero" sensore)

Questo e' l'helper con il campo "Stato {{ ... }}": trasforma il numero
grezzo dell'Helper 1 in un sensore batteria vero e proprio (icona
batteria, utilizzabile in dashboard/grafici energia come qualsiasi
altro sensore SoC). Richiede l'Helper 1 gia' creato.

Creazione (tutto da UI, niente `configuration.yaml`):

**Impostazioni → Dispositivi e servizi → Helper → + Crea helper →
Modello → Sensore basato su modello**

| Campo | Valore |
|---|---|
| Nome | `PI30 battery SoC calcolato` |
| Icona | `mdi:battery-unknown` |
| Unita' di misura | `%` |
| Classe del dispositivo | `Battery` |
| Classe di stato | `Measurement` |

**Stato** (questo e' il template richiesto dalla domanda "cosa metto
nello Stato"):

```
{{ states('input_number.pi30_battery_soc_calcolato') | float(default=0) | round(0) }}
```

Se l'entity_id dell'Helper 1 non e' esattamente
`input_number.pi30_battery_soc_calcolato` (controllalo in
Impostazioni → Entita'), aggiorna il nome qui dentro di conseguenza.

Salvando crea l'entita' `sensor.pi30_battery_soc_calcolato` (o simile:
verifica l'entity_id esatto dopo il salvataggio).
