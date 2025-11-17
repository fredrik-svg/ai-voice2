# Rhasspy + n8n projekt (Pi Zero WH satellit)

Det här paketet innehåller ett färdigt skelett för ett projekt där:

- **Raspberry Pi Zero WH** kör en lätt Rhasspy-satellit (wake word + mikrofon)
- En **Rhasspy-bas** (t.ex. Raspberry Pi 4 eller server) kör STT/TTS och skickar intents till n8n
- **n8n** tar emot intents via Webhook och kan svara via Rhasspys TTS-API

Mappstruktur:

- `rhasspy-pi-zero/` – filer för din Pi Zero WH (satellit)
- `rhasspy-base/` – exempel på profil & docker-compose för Rhasspy-bas
- `n8n/` – färdigt exempel-workflow för n8n

Anpassa IP-adresser, hostnamn och ev. användarnamn/lösenord innan du kör.
Alla ställen där du behöver ändra är markerade med VERSALER, t.ex. `MQTT_HOST`, `RHASSPY_BASE_HOST`, `N8N_WEBHOOK_URL`.
