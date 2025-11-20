# Rhasspy + n8n projekt (Pi Zero WH satellit)

Det här paketet innehåller ett färdigt skelett för ett projekt där:

- **Raspberry Pi Zero WH** kör en lätt Rhasspy-satellit (wake word + mikrofon)
- En **Rhasspy-bas** (t.ex. Raspberry Pi 4 eller server) kör STT/TTS och skickar intents till n8n
- **n8n** tar emot intents via Webhook och kan svara via Rhasspys TTS-API

## 📚 Dokumentation

- **[LÖSNING.md](LÖSNING.md)** - Förklaring av Python 3.13+ kompatibilitetslösningen
- **[rhasspy-pi-zero/SNABBSTART.md](rhasspy-pi-zero/SNABBSTART.md)** - Snabbstartsguide för Pi Zero
- **[rhasspy-pi-zero/FELSÖKNING.md](rhasspy-pi-zero/FELSÖKNING.md)** - Felsökningsguide

## Mappstruktur

- `rhasspy-pi-zero/` – filer för din Pi Zero WH (satellit)
  - **Rekommenderad**: Docker-baserad installation (`install_pi_zero_docker.sh`)
  - **Legacy**: Källkodsbaserad installation (`install_pi_zero.sh`)
- `rhasspy-base/` – exempel på profil & docker-compose för Rhasspy-bas
- `n8n/` – färdigt exempel-workflow för n8n

## Installation

### Snabbstart

**Pi Zero WH (satellit)**:
```bash
cd rhasspy-pi-zero
nano profile.json    # Ändra MQTT_HOST, MQTT_USER, MQTT_PASS
./install_pi_zero_docker.sh
docker compose up -d
```

**Rhasspy-bas (server)**:
```bash
cd rhasspy-base
nano profiles/sv/profile.json    # Ändra N8N_WEBHOOK_URL
docker compose up -d
```

Se README-filerna i respektive mapp för detaljerade instruktioner.

## Konfiguration

Anpassa IP-adresser, hostnamn och ev. användarnamn/lösenord innan du kör.
Alla ställen där du behöver ändra är markerade med VERSALER, t.ex. `MQTT_HOST`, `RHASSPY_BASE_HOST`, `N8N_WEBHOOK_URL`.

## Varför Docker?

Båda Rhasspy-installationerna använder nu Docker som standard eftersom det:
- Fungerar med alla Python-versioner (inklusive 3.13+)
- Ger konsekventa miljöer över alla plattformar
- Är enklare att underhålla och uppdatera
- Undviker beroendeproblem och byggfel
