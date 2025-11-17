# Rhasspy-bas (server)

Denna mapp innehåller ett enkelt exempel på en Rhasspy-bas som:

- Kör Rhasspy i Docker
- Kör en lokal MQTT-broker (Mosquitto)
- Skickar intents vidare till n8n via `N8N_WEBHOOK_URL`

## Steg

1. Ändra `profile.json` i `profiles/sv/` och sätt `N8N_WEBHOOK_URL` till din riktiga webhook-URL från n8n, t.ex:

   ```
   https://DIN-N8N-HOST/webhook/rhasspy-intent
   ```

2. Starta tjänsterna:

   ```bash
   docker compose up -d
   ```

3. Öppna Rhasspy Web UI på:

   ```
   http://RHASSPY_BASE_HOST:12101
   ```

4. Kontrollera att `site_id` (`pi-zero-wh`) matchar konfigurationen på din Pi Zero WH.
