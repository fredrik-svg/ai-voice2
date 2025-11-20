#!/usr/bin/env bash
set -e

# Spara nuvarande katalog (där skriptet körs från)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "====================================="
echo "Rhasspy Pi Zero Docker Installation"
echo "====================================="
echo ""

# Kontrollera om Docker är installerat
if ! command -v docker &> /dev/null; then
    echo "Docker är inte installerat. Installerar Docker..."
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sudo sh /tmp/get-docker.sh
    rm /tmp/get-docker.sh
    
    # Lägg till nuvarande användare i docker-gruppen
    sudo usermod -aG docker $USER
    echo "Docker installerat! Du behöver logga ut och in igen för att köra Docker utan sudo."
    echo "Efter omloggning, kör detta skript igen."
    exit 0
fi

# Kontrollera om användaren är i docker-gruppen
if ! groups | grep -q docker; then
    echo "Din användare är inte i docker-gruppen."
    echo "Lägger till dig i docker-gruppen..."
    sudo usermod -aG docker $USER
    echo "Du behöver logga ut och in igen för att ändringen ska träda i kraft."
    echo "Efter omloggning, kör detta skript igen."
    exit 0
fi

# Kontrollera att Docker Compose är tillgängligt
if ! docker compose version &> /dev/null; then
    if ! command -v docker-compose &> /dev/null; then
        echo "Varken 'docker compose' eller 'docker-compose' hittades."
        echo "Installerar docker-compose-plugin..."
        sudo apt-get update
        sudo apt-get install -y docker-compose-plugin
    fi
fi

echo "Skapar profilkatalog..."
mkdir -p "$SCRIPT_DIR/profiles/sv"

# Kopiera profilen om den inte redan finns
if [ ! -f "$SCRIPT_DIR/profiles/sv/profile.json" ]; then
    echo "Kopierar standardprofil..."
    cp "$SCRIPT_DIR/profile.json" "$SCRIPT_DIR/profiles/sv/profile.json"
    echo ""
    echo "⚠️  VIKTIGT: Redigera profilen innan du startar tjänsten!"
    echo "   Fil: $SCRIPT_DIR/profiles/sv/profile.json"
    echo "   Ändra MQTT_HOST, MQTT_USER, MQTT_PASS till dina värden"
    echo ""
fi

echo "Drar ner Rhasspy Docker-image (kan ta några minuter)..."
docker pull rhasspy/rhasspy:2.5.11

echo ""
echo "✓ Installation klar!"
echo ""
echo "Nästa steg:"
echo "1. Redigera profilen om du inte redan gjort det:"
echo "   nano $SCRIPT_DIR/profiles/sv/profile.json"
echo ""
echo "2. Starta Rhasspy-satelliten:"
echo "   cd $SCRIPT_DIR"
echo "   docker compose up -d"
echo ""
echo "3. Se loggar:"
echo "   docker logs -f rhasspy-satellite"
echo ""
echo "4. Stoppa tjänsten:"
echo "   docker compose down"
echo ""
echo "5. (Valfritt) Aktivera automatisk start vid boot:"
echo "   sudo systemctl enable docker"
echo "   # Och skapa en systemd-tjänst som kör 'docker compose up -d' i denna katalog"
echo ""
