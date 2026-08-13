# Home assistant configurations

## Remote access

- Add the domain in Nginx Proxy Manager with Websocket support
- In `Settings > System > Network > Home Assistant URL > Internet` add the HA domain url.

## Configuration.yaml

```yml
## Custom setting by Jure ##

# add file for customization for specific entities
homeassistant:
  customize: !include customize.yaml
```

## Customize.yaml

test

```yml
sensor.solar_cells_energy_total:
  device_class: energy
  state_class: total_increasing
  unit_of_measurement: kWh
sensor.solar_cells_power_total:
  device_class: power
  unit_of_measurement: W
```
