# Rhasspy på Raspberry Pi Zero WH (satellit)

Denna mapp innehåller:

- `profile.json` – Rhasspy-profil för satelliten
- `rhasspy.service` – systemd-tjänst för att starta Rhasspy vid boot
- `install_pi_zero.sh` – installationsscript som klonar Rhasspy från GitHub och installerar det i en virtualenv

**OBS:** Rhasspy installeras från GitHub-källkod eftersom det inte finns som ett PyPI-paket.

## Python 3.13+ Kompatibilitet

Installationsskriptet hanterar automatiskt problemet med `distutils` som togs bort i Python 3.13:

1. **Proaktiv kontroll**: Skriptet testar om pip fungerar innan det används
2. **Automatisk reparation**: Om pip är trasigt (försöker importera saknad `distutils`), installeras det om från scratch med `get-pip.py`
3. **Dubbel verifiering**: Efter Rhasspy's `configure` skapar `.venv`, verifieras och repareras pip igen innan `make` körs
4. **Robusthet**: Skriptet avslutar med fel om pip inte kan repareras, istället för att misslyckas halvvägs

Detta säkerställer att både `~/rhasspy-venv` och Rhasspy's interna `.venv` har fungerande pip, även på Python 3.13+.

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
