# n8n-workflow för Rhasspy

Filen `rhasspy-n8n-workflow.json` är ett exempel-workflow som:

- Tar emot Rhasspy-intents via en Webhook (`/webhook/rhasspy-intent`)
- Gör enkel logik baserat på `intent.name`
- Skickar tillbaka en textsträng till Rhasspy-basens TTS-API

## Import i n8n

1. Öppna din n8n-instans i webbläsaren.
2. Skapa ett nytt workflow.
3. Klicka på menyn (⋮) och välj **Import from file**.
4. Välj `rhasspy-n8n-workflow.json`.
5. Ändra i noden **Send TTS to Rhasspy** så att `RHASSPY_BASE_HOST` pekar på din Rhasspy-bas, t.ex. `rhasspy-base.local` eller IP-adress.
6. Aktivera workflowet.

Kopiera sedan webhook-URL:en (börjar med `https://DIN-N8N/webhook/rhasspy-intent`) och klistra in den i Rhasspy-basens `profile.json` (fältet `N8N_WEBHOOK_URL`).
