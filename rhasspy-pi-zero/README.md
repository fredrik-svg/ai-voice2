# Rhasspy på Raspberry Pi Zero WH (satellit)

Denna mapp innehåller:

- `profile.json` – Rhasspy-profil för satelliten
- `rhasspy.service` – systemd-tjänst för att starta Rhasspy vid boot
- `install_pi_zero.sh` – enkel installationsscript

## Steg

1. Kopiera hela mappen `rhasspy-pi-zero` till din Pi Zero WH (t.ex. via `scp`).
2. SSH:a in på Pi Zero och kör:

   ```bash
   cd rhasspy-pi-zero
   nano profile.json    # Ändra MQTT_HOST, MQTT_USER, MQTT_PASS
   ./install_pi_zero.sh
   ```

3. Kontrollera att tjänsten kör:

   ```bash
   systemctl status rhasspy
   journalctl -u rhasspy -f
   ```

4. Säkerställ att din MQTT-broker är igång och att Rhasspy-bas är konfigurerad med samma `site_id` (`pi-zero-wh`).
