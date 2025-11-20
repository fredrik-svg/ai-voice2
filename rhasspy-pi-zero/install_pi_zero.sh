#!/usr/bin/env bash
set -e

# Spara nuvarande katalog (där skriptet körs från)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Uppdaterar system..."
sudo apt update
sudo apt install -y python3 python3-venv python3-pip git alsa-utils

echo "Klonar Rhasspy från GitHub..."
cd ~
if [ -d "rhasspy" ]; then
  echo "Rhasspy-katalog finns redan, tar bort..."
  rm -rf rhasspy
fi
git clone https://github.com/rhasspy/rhasspy.git
cd rhasspy

echo "Skapar virtualenv..."
python3 -m venv ~/rhasspy-venv
source ~/rhasspy-venv/bin/activate

echo "Installerar Rhasspy (kan ta lite tid)..."
pip install --upgrade pip
pip install .

echo "Skapar profilkatalog..."
mkdir -p ~/.config/rhasspy/profiles/sv
cp "$SCRIPT_DIR/profile.json" ~/.config/rhasspy/profiles/sv/profile.json

echo "Installerar systemd-tjänst..."
sudo cp "$SCRIPT_DIR/rhasspy.service" /etc/systemd/system/rhasspy.service
sudo systemctl daemon-reload
sudo systemctl enable rhasspy
sudo systemctl start rhasspy

echo "Klart! Kontrollera loggar med:"
echo "  journalctl -u rhasspy -f"
