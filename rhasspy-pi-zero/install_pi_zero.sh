#!/usr/bin/env bash
set -e

echo "Uppdaterar system..."
sudo apt update
sudo apt install -y python3 python3-venv alsa-utils

echo "Skapar virtualenv..."
python3 -m venv ~/rhasspy-venv
source ~/rhasspy-venv/bin/activate

echo "Installerar Rhasspy (kan ta lite tid)..."
pip install --upgrade pip
pip install rhasspy

echo "Skapar profilkatalog..."
mkdir -p ~/.config/rhasspy/profiles/sv
cp profile.json ~/.config/rhasspy/profiles/sv/profile.json

echo "Installerar systemd-tjänst..."
sudo cp rhasspy.service /etc/systemd/system/rhasspy.service
sudo systemctl daemon-reload
sudo systemctl enable rhasspy
sudo systemctl start rhasspy

echo "Klart! Kontrollera loggar med:"
echo "  journalctl -u rhasspy -f"
