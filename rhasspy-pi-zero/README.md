# Rhasspy på Raspberry Pi Zero WH (satellit)

Denna mapp innehåller två installationsmetoder för Rhasspy på Pi Zero WH:

## 📚 Dokumentation

- **[SNABBSTART.md](SNABBSTART.md)** - Steg-för-steg guide för att komma igång snabbt
- **[FELSÖKNING.md](FELSÖKNING.md)** - Lösningar på vanliga problem
- **README.md** (denna fil) - Fullständig dokumentation

## Filer

- `profile.json` – Rhasspy-profil för satelliten
- `docker-compose.yml` – Docker Compose-konfiguration
- `install_pi_zero_docker.sh` – **Rekommenderad** Docker-baserad installation
- `rhasspy-docker.service` – systemd-tjänst för Docker-versionen
- `install_pi_zero.sh` – **Legacy** källkodsbaserad installation (kan ha problem med Python 3.13+)
- `rhasspy.service` – systemd-tjänst för källkodsversionen

## Installation med Docker (Rekommenderad)

Docker-baserad installation är den rekommenderade metoden eftersom den:
- Fungerar med alla Python-versioner (inklusive 3.13+)
- Är enklare att underhålla och uppdatera
- Har samma arkitektur som Rhasspy-basen
- Undviker beroendeproblem

### Steg

1. Kopiera hela mappen `rhasspy-pi-zero` till din Pi Zero WH (t.ex. via `scp`).
2. SSH:a in på Pi Zero och kör:

   ```bash
   cd rhasspy-pi-zero
   nano profile.json    # Ändra MQTT_HOST, MQTT_USER, MQTT_PASS
   ./install_pi_zero_docker.sh
   ```

3. Starta Rhasspy:

   ```bash
   docker compose up -d
   ```

   **Om du får "permission denied"-fel:**
   ```bash
   # Applicera docker-gruppändringen direkt:
   newgrp docker
   # Sedan försök igen:
   docker compose up -d
   ```

4. Kontrollera att tjänsten kör:

   ```bash
   docker logs -f rhasspy-satellite
   ```

5. (Valfritt) Aktivera automatisk start vid boot:

   ```bash
   sudo cp rhasspy-docker.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable rhasspy-docker
   ```

### Hantering av Docker-tjänsten

```bash
# Starta
docker compose up -d

# Stoppa
docker compose down

# Se loggar
docker logs -f rhasspy-satellite

# Starta om
docker compose restart
```

## Legacy: Installation från källkod

**OBS:** Denna metod kan ha problem med Python 3.13+ på grund av saknad `distutils`-modul.

<details>
<summary>Klicka för att visa legacy-installationsinstruktioner</summary>

### Python 3.13+ Kompatibilitet

Installationsskriptet hanterar automatiskt problemet med `distutils` som togs bort i Python 3.13:

1. **Proaktiv kontroll**: Skriptet testar om pip fungerar innan det används
2. **Automatisk reparation**: Om pip är trasigt (försöker importera saknad `distutils`), installeras det om från scratch med `get-pip.py`
3. **Dubbel verifiering**: Efter Rhasspy's `configure` skapar `.venv`, verifieras och repareras pip igen innan `make` körs
4. **Robusthet**: Skriptet avslutar med fel om pip inte kan repareras, istället för att misslyckas halvvägs

Detta säkerställer att både `~/rhasspy-venv` och Rhasspy's interna `.venv` har fungerande pip, även på Python 3.13+.

### Steg

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

</details>

## Generella tips

Säkerställ att:
- Din MQTT-broker är igång och nåbar från Pi Zero
- Rhasspy-bas är konfigurerad med samma `site_id` (`pi-zero-wh`)
- Ljudenheterna fungerar korrekt (testa med `arecord` och `aplay`)
