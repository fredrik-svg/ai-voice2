# Felsökningsguide - Rhasspy Pi Zero WH

## Docker-relaterade problem

### Problem: "docker: command not found"

**Orsak:** Docker är inte installerat.

**Lösning:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
# Logga ut och in igen
```

### Problem: "permission denied while trying to connect to the Docker daemon"

**Orsak:** Din användare är inte i docker-gruppen.

**Lösning:**
```bash
sudo usermod -aG docker $USER
# Logga ut och in igen
newgrp docker  # Alternativt: applicera gruppändringen utan omloggning
```

### Problem: "docker compose: command not found"

**Orsak:** Docker Compose plugin saknas.

**Lösning:**
```bash
sudo apt-get update
sudo apt-get install -y docker-compose-plugin
```

Eller använd äldre `docker-compose` (med bindestreck):
```bash
sudo apt-get install -y docker-compose
# Använd sedan 'docker-compose' istället för 'docker compose'
```

## MQTT-problem

### Problem: Rhasspy kan inte ansluta till MQTT-broker

**Kontroller:**

1. Verifiera att MQTT-brokern körs:
```bash
# På basen där MQTT-brokern körs:
docker ps | grep mosquitto
# eller
systemctl status mosquitto
```

2. Testa MQTT-anslutningen från Pi Zero:
```bash
# Installera MQTT-klientverktyg
sudo apt-get install -y mosquitto-clients

# Testa prenumeration
mosquitto_sub -h <MQTT_HOST> -t 'test/topic' -u <MQTT_USER> -P <MQTT_PASS>

# I ett annat terminal, testa publicering
mosquitto_pub -h <MQTT_HOST> -t 'test/topic' -m 'Hello' -u <MQTT_USER> -P <MQTT_PASS>
```

3. Kontrollera brandväggsinställningar:
```bash
# På basen:
sudo ufw status
sudo ufw allow 1883/tcp  # Om UFW är aktiverat
```

### Problem: "Connection refused" eller timeout

**Lösningar:**
- Kontrollera att `MQTT_HOST` i `profile.json` är korrekt (IP-adress, inte localhost)
- Verifiera att port 1883 är öppen på basen
- Testa nätverksanslutning: `ping <MQTT_HOST>`

## Ljudproblem

### Problem: Ingen ljud från mikrofon eller högtalare

**Kontroller:**

1. Lista tillgängliga ljudenheter:
```bash
arecord -l  # Mikrofoner
aplay -l    # Högtalare
```

2. Testa mikrofon:
```bash
arecord -d 5 -f cd test.wav
aplay test.wav
rm test.wav
```

3. Kontrollera ALSA-konfiguration:
```bash
# Se aktuell konfiguration
cat /etc/asound.conf

# Justera volymnivåer
alsamixer
```

4. Testa med en annan enhet:
```bash
# Redigera docker-compose.yml och lägg till:
# environment:
#   - PULSE_SERVER=unix:/run/user/1000/pulse/native
```

### Problem: "No such file or directory: '/etc/asound.conf'"

**Lösning:** Ta bort eller kommentera ut asound.conf-volymen i docker-compose.yml:

```yaml
volumes:
  - ./profiles:/profiles
  # - /etc/asound.conf:/etc/asound.conf:ro  # Kommentera ut denna rad
```

Sedan starta om:
```bash
docker compose down
docker compose up -d
```

## Profil- och konfigurationsproblem

### Problem: Profilen laddas inte

**Kontroller:**

1. Verifiera att profilen finns:
```bash
ls -la profiles/sv/profile.json
```

2. Kontrollera JSON-syntax:
```bash
cat profiles/sv/profile.json | python3 -m json.tool
```

3. Se Rhasspy-loggar för fel:
```bash
docker logs rhasspy-satellite | grep -i error
```

### Problem: Wake word fungerar inte

**Lösningar:**

1. Kontrollera wake word-konfiguration i profilen
2. Verifiera att mikrofonen fungerar (se Ljudproblem ovan)
3. Justera `probability_threshold` i profilen (lägre värde = känsligare)
4. Testa med ett enklare wake word först

## Container-problem

### Problem: Container startar inte eller kraschar

**Diagnostisering:**

```bash
# Se alla containers (inklusive stoppade)
docker ps -a

# Se fullständiga loggar
docker logs rhasspy-satellite

# Kontrollera resurser
docker stats rhasspy-satellite

# Starta om container
docker compose restart
```

### Problem: "no such device" för /dev/snd

**Lösning:** Kontrollera att ljudenheter finns:

```bash
ls -l /dev/snd/

# Om inga enheter finns:
# 1. Kontrollera att ljudkort är korrekt anslutet
# 2. Ladda om ALSA-moduler:
sudo modprobe snd-bcm2835
```

## Legacy-installation (från källkod)

### Problem: "ModuleNotFoundError: No module named 'distutils'"

**Detta är anledningen till att Docker-metoden rekommenderas!**

Om du ändå vill använda källkodsmetoden:

**Lösning 1 (Rekommenderad):** Använd Docker-installationen istället:
```bash
./install_pi_zero_docker.sh
```

**Lösning 2:** Använd Python 3.11 eller äldre:
```bash
# På Debian/Ubuntu:
sudo apt-get install python3.11 python3.11-venv python3.11-dev
# Sedan modifiera install_pi_zero.sh att använda python3.11
```

**Lösning 3:** Försök installera setuptools separat:
```bash
# I den trasiga virtualenv:
curl -sSL https://bootstrap.pypa.io/get-pip.py | .venv/bin/python
.venv/bin/pip install --upgrade pip setuptools wheel
```

## Prestanda

### Problem: Långsam start eller hög CPU-användning

**Tips:**
- Pi Zero är en begränsad enhet, det är normalt att Rhasspy tar några minuter att starta
- Överväg att använda Pi Zero WH endast som satellit (mikrofon/högtalare) och låt basen göra det tunga arbetet
- Kontrollera att wake word-systemet är satt till "raven" (lätt) och inte "porcupine" eller andra tunga modeller

### Problem: Ont om diskutrymme

**Lösning:**

```bash
# Rensa gamla Docker-bilder och containers
docker system prune -a

# Se diskutrymme
df -h
```

## Behöver mer hjälp?

1. Kontrollera Rhasspy's officiella dokumentation: https://rhasspy.readthedocs.io/
2. Se loggar för detaljerad information: `docker logs -f rhasspy-satellite`
3. Testa komponenter separat (MQTT, mikrofon, högtalare) för att isolera problemet
4. Skapa ett issue på GitHub med:
   - Beskrivning av problemet
   - Relevanta loggar
   - Din konfiguration (utan lösenord!)
   - Pi Zero-modell och OS-version
