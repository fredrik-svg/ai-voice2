#!/usr/bin/env bash
set -e

# Spara nuvarande katalog (där skriptet körs från)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Uppdaterar system..."
sudo apt update
sudo apt install -y python3 python3-dev python3-venv python3-pip python3-setuptools git alsa-utils \
    build-essential swig portaudio19-dev libopenblas-dev

echo "Klonar Rhasspy från GitHub..."
cd ~
if [ -d "rhasspy" ]; then
  echo "Rhasspy-katalog finns redan, tar bort..."
  rm -rf rhasspy
fi
git clone --recursive https://github.com/rhasspy/rhasspy.git
cd rhasspy

echo "Skapar virtualenv..."
python3 -m venv --upgrade-deps ~/rhasspy-venv
source ~/rhasspy-venv/bin/activate

echo "Installerar Rhasspy (kan ta lite tid)..."
pip install --upgrade pip setuptools wheel

echo "Konfigurerar Rhasspy..."
./configure --enable-in-place --disable-dependency-check

echo "Uppgraderar pip i Rhasspy virtualenv..."
if [ -d ".venv" ]; then
    # Använd ensurepip för att installera en ny pip om den gamla är trasig
    .venv/bin/python -m ensurepip --upgrade 2>/dev/null || true
    
    # Försök uppgradera pip, setuptools och wheel
    # Om pip är trasigt (t.ex. på Python 3.13 där distutils saknas), använd get-pip.py
    .venv/bin/python -m pip install --upgrade pip setuptools wheel 2>/dev/null || {
        echo "Pip är trasigt (troligen på grund av saknad distutils), använder get-pip.py..."
        curl -sSL https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
        .venv/bin/python /tmp/get-pip.py
        rm /tmp/get-pip.py
        # Efter get-pip.py, installera setuptools och wheel
        .venv/bin/python -m pip install --upgrade setuptools wheel
    }
fi

echo "Bygger Rhasspy..."
make

echo "Installerar Rhasspy..."
make install

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
