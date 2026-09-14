# Helper 2: Template → Sensor (the "real" sensor)

This is the helper with the "State {{ ... }}" field: it turns
Helper 1's raw number into a proper battery sensor (battery icon,
usable in dashboards/energy graphs like any other SOC sensor).
Requires Helper 1 to already exist.

Creation (all from UI, no `configuration.yaml`):

**Settings → Devices & services → Helpers → Create helper →
Template → Sensor**

(the exact menu wording can vary slightly by Home Assistant
version/language: look for the "Template" category and, inside it,
the "Sensor" type — it's the same helper.)

| Field | Value |
|---|---|
| Name | `PI30 battery SoC calculated` |
| Icon | `mdi:battery-unknown` |
| Unit of measurement | `%` |
| Device class | `Battery` |
| State class | `Measurement` |

**State** (this is the template requested by "what do I put in
State"):

```
{{ states('input_number.pi30_battery_soc_calculated') | float(default=0) | round(0) }}
```

If Helper 1's entity_id is not exactly
`input_number.pi30_battery_soc_calculated` (check in Settings →
Entities), update the name here accordingly.

Saving creates the `sensor.pi30_battery_soc_calculated` entity (or
similar: check the exact entity_id after saving).
