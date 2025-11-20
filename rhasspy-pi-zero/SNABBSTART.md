# Snabbstartsguide - Rhasspy Pi Zero WH Satellit med Docker

Denna guide visar hur du snabbt kommer igång med Rhasspy på din Pi Zero WH med Docker.

## Förutsättningar

- Raspberry Pi Zero WH med Raspberry Pi OS (Bullseye eller senare)
- Internetuppkoppling
- Mikrofon och högtalare anslutna till Pi Zero
- En fungerande MQTT-broker (kan köras på Rhasspy-basen)

## Steg 1: Förbereda Pi Zero

SSH:a in på din Pi Zero:

```bash
ssh pi@<PI_ZERO_IP>
```

## Steg 2: Kopiera installationsfilerna

Det enklaste sättet är att klona hela repot:

```bash
cd ~
git clone https://github.com/fredrik-svg/ai-voice2.git
cd ai-voice2/rhasspy-pi-zero
```

Eller kopiera bara `rhasspy-pi-zero`-mappen med `scp` från din dator:

```bash
# På din dator:
scp -r rhasspy-pi-zero pi@<PI_ZERO_IP>:~/
```

## Steg 3: Konfigurera profilen

Redigera `profile.json` och ändra MQTT-inställningarna:

```bash
nano profile.json
```

Ändra dessa värden:
- `MQTT_HOST` → IP-adressen till din MQTT-broker (t.ex. `192.168.1.100`)
- `MQTT_USER` → Ditt MQTT-användarnamn (eller ta bort raden om ingen autentisering används)
- `MQTT_PASS` → Ditt MQTT-lösenord (eller ta bort raden om ingen autentisering används)

Exempel:
```json
{
  "locale": "sv-SE",
  "mqtt": {
    "enabled": true,
    "host": "192.168.1.100",
    "port": 1883,
    "site_id": "pi-zero-wh"
  },
  ...
}
```

Spara filen (Ctrl+O, Enter, Ctrl+X).

## Steg 4: Installera Docker och Rhasspy

Kör installationsskriptet:

```bash
chmod +x install_pi_zero_docker.sh
./install_pi_zero_docker.sh
```

**OBS:** Om Docker inte är installerat kommer skriptet att installera det och be dig logga ut och in igen. Gör det, och kör sedan skriptet igen.

## Steg 5: Starta Rhasspy

```bash
docker compose up -d
```

## Steg 6: Verifiera att det fungerar

Kontrollera loggarna:

```bash
docker logs -f rhasspy-satellite
```

Du bör se Rhasspy starta och ansluta till MQTT-brokern.

## Steg 7: (Valfritt) Aktivera automatisk start vid boot

```bash
sudo cp rhasspy-docker.service /etc/systemd/system/
# Redigera servicefilen om din användare inte heter 'pi'
sudo nano /etc/systemd/system/rhasspy-docker.service
sudo systemctl daemon-reload
sudo systemctl enable rhasspy-docker
```

## Användbara kommandon

```bash
# Starta tjänsten
docker compose up -d

# Stoppa tjänsten
docker compose down

# Starta om tjänsten
docker compose restart

# Se loggar (Ctrl+C för att avsluta)
docker logs -f rhasspy-satellite

# Uppdatera Rhasspy-imagen
docker compose pull
docker compose up -d
```

## Felsökning

### Docker-kommandot kräver sudo
Du behöver logga ut och in igen efter att Docker installerats.

### Ingen ljud
Kontrollera att mikrofon och högtalare fungerar:
```bash
# Testa mikrofon (Ctrl+C för att stoppa)
arecord -d 5 test.wav
aplay test.wav

# Kontrollera att enheter fungerar
arecord -l
aplay -l
```

### MQTT-anslutning fungerar inte
- Kontrollera att MQTT-brokern körs
- Verifiera IP-adress, port och autentiseringsuppgifter i `profiles/sv/profile.json`
- Testa MQTT-anslutningen med `mosquitto_pub` och `mosquitto_sub`

### Containern startar inte
```bash
# Se fullständiga loggar
docker logs rhasspy-satellite

# Kontrollera Docker-status
docker ps -a
```

## Nästa steg

1. Konfigurera Rhasspy-basen med samma `site_id`
2. Testa wake word-detektering
3. Konfigurera n8n för att hantera intents
4. Träna egna kommandon i Rhasspy

Se huvuddokumentationen i respektive README-fil för mer information.
