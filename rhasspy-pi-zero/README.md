# Rhasspy på Raspberry Pi Zero WH (satellit)

Denna mapp innehåller:

- `profile.json` – Rhasspy-profil för satelliten
- `rhasspy.service` – systemd-tjänst för att starta Rhasspy vid boot
- `install_pi_zero.sh` – installationsscript som klonar Rhasspy från GitHub och installerar det i en virtualenv

**OBS:** Rhasspy installeras från GitHub-källkod eftersom det inte finns som ett PyPI-paket.

## Steg

1. Kopiera hela mappen `rhasspy-pi-zero` till din Pi Zero WH (t.ex. via `scp`).
2. SSH:a in på Pi Zero och kör:

   ```bash
   cd rhasspy-pi-zero
   nano profile.json    # Ändra MQTT_HOST, MQTT_USER, MQTT_PASS
   ./install_pi_zero.sh
   ```

   > Tips: Scriptet försöker installera `python3-distutils` där paketet finns kvar (äldre Debian/
   > Ubuntu-versioner). På nyare system där distutils redan är borttaget hanteras pip istället via
   > ensurepip/get-pip fallback i scriptet.

3. Kontrollera att tjänsten kör:

   ```bash
   systemctl status rhasspy
   journalctl -u rhasspy -f
   ```

4. Säkerställ att din MQTT-broker är igång och att Rhasspy-bas är konfigurerad med samma `site_id` (`pi-zero-wh`).
