# Helper 1: Numero (contenitore del valore)

Questo e' l'helper "di memoria": l'automazione di coulomb counting
legge e scrive qui. Non ha nessun campo template ("Stato"), e' solo
un numero.

Creazione (tutto da UI, niente `configuration.yaml`):

**Impostazioni → Dispositivi e servizi → Helper → + Crea helper → Numero**

| Campo | Valore |
|---|---|
| Nome | `PI30 battery SOC calcolato` |
| Icona | `mdi:battery-unknown` |
| Valore minimo | `0` |
| Valore massimo | `100` |
| Passo | `0.1` |
| Unita' di misura | `%` |
| Modalita' di visualizzazione | Casella di testo |

Salvando crea l'entita' `input_number.pi30_battery_soc_calcolato`
(verifica l'entity_id esatto dopo il salvataggio: se HA ne genera uno
diverso, aggiorna i riferimenti nell'automazione e nell'Helper 2).

Al primo salvataggio imposta come valore corrente il SOC letto da
`sensor.heltec_pi30_battery_soc` (o una stima a occhio): l'automazione
lo ricalibrera' comunque al primo passaggio per la tensione di float o
di under-voltage, quindi non serve che sia preciso.

## Nota sul riavvio di Home Assistant

Se dopo un riavvio l'helper riparte da un valore diverso dall'ultimo
calcolato, non e' un problema grave: l'automazione ricalibra comunque
la stima a 100% o 0% ogni volta che la batteria tocca la tensione di
float o la soglia di under-voltage + margine (vedi README.md).
