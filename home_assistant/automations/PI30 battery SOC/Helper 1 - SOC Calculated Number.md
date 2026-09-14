# Helper 1: Number (the raw value container)

This is the "memory" helper: the coulomb-counting automation reads
and writes here. It has no template field at all, it's just a number.

Creation (all from UI, no `configuration.yaml`):

**Settings → Devices & services → Helpers → Create helper → Number**

| Field | Value |
|---|---|
| Name | `PI30 battery SOC calculated` |
| Icon | `mdi:battery-unknown` |
| Minimum value | `0` |
| Maximum value | `100` |
| Step | `0.1` |
| Unit of measurement | `%` |
| Display mode | Box |

Saving creates the `input_number.pi30_battery_soc_calculated` entity
(check the exact entity_id after saving: if HA generates a different
one, update the references in the automation and in Helper 2 to
match).

On first save, set the current value to something close to the SOC
read from `sensor.heltec_pi30_battery_soc` (or a rough guess): the
automation will re-anchor it anyway the first time it touches the
float or under-voltage threshold, so it doesn't need to be precise.

## Note on Home Assistant restarts

If after a restart the helper comes back at a different value than
the last calculated one, it's not a serious problem: the automation
re-anchors the estimate to 100% or 0% every time the pack touches the
float voltage or the under-voltage + margin threshold (see
README.md).
