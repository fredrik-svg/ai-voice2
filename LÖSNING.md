# Lösning: Python 3.13+ Kompatibilitet

## Problemet

I Python 3.13+ har `distutils`-modulen tagits bort. Detta orsakade följande fel när man försökte installera Rhasspy från källkod:

```
ModuleNotFoundError: No module named 'distutils'
make: *** [Makefile:149: install-init] Error 1
```

Detta problem uppstod eftersom:
1. Rhasspy's `Makefile` försökte använda pip i en virtualenv
2. pip i äldre versioner är beroende av `distutils`
3. Python 3.13+ har ingen `distutils`-modul

## Den gamla lösningen (install_pi_zero.sh)

Den ursprungliga källkodsbaserade installationen försökte lösa detta genom att:
- Installera `python3-distutils` från apt (men detta paket finns inte i nyare distributioner)
- Återinstallera pip med `get-pip.py` om pip var trasigt
- Dubbelkontrollera och reparera pip både före och efter Rhasspy's `configure`-steg

**Problem:** Även med dessa fixar kunde Rhasspy's interna Makefile misslyckas med att använda pip innan reparationen hann ske.

## Den nya lösningen (Docker)

Istället för att kämpa mot Python-versionsproblem, använder vi nu Docker:

### Fördelar:
1. **Fungerar med alla Python-versioner** - Docker-imagen innehåller sin egen Python-miljö
2. **Konsistent med basen** - Rhasspy-basen använder redan Docker
3. **Enklare underhåll** - Inga virtualenvs, pip-problem eller byggfel
4. **Samma arkitektur** - Båda installationerna (bas och satellit) använder samma metod
5. **Enklare uppdatering** - `docker compose pull && docker compose up -d`

### Vad har ändrats:

#### Nya filer:
- `install_pi_zero_docker.sh` - Docker-baserad installation
- `docker-compose.yml` - Container-konfiguration för satelliten
- `rhasspy-docker.service` - systemd-tjänst för Docker-versionen
- `SNABBSTART.md` - Steg-för-steg guide
- `FELSÖKNING.md` - Omfattande felsökningsguide
- `profiles/` - Katalogstruktur för användarkonfigurationer

#### Uppdaterade filer:
- `README.md` - Docker som primär metod, källkod som legacy
- Alla `docker-compose.yml` - Borttagen obsolet `version`-fält

### Teknisk implementation:

**docker-compose.yml:**
```yaml
services:
  rhasspy-satellite:
    image: rhasspy/rhasspy:2.5.11
    container_name: rhasspy-satellite
    restart: unless-stopped
    network_mode: host
    devices:
      - /dev/snd:/dev/snd
    volumes:
      - ./profiles:/profiles
      - /etc/asound.conf:/etc/asound.conf:ro
    command: >
      --user-profiles /profiles
      --profile sv
    privileged: true
```

**Viktiga detaljer:**
- `network_mode: host` - Ger åtkomst till MQTT-broker utan portkonfiguration
- `devices: /dev/snd` - Ger åtkomst till ljudenheter
- `privileged: true` - Nödvändigt för ljudåtkomst på vissa system
- Samma Rhasspy-version (2.5.11) som basen

## Migration från källkodsinstallation

Om du redan har en källkodsbaserad installation:

1. **Stoppa den gamla tjänsten:**
   ```bash
   sudo systemctl stop rhasspy
   sudo systemctl disable rhasspy
   ```

2. **Säkerhetskopiera din profil:**
   ```bash
   cp ~/.config/rhasspy/profiles/sv/profile.json ~/profile_backup.json
   ```

3. **Installera Docker-versionen:**
   ```bash
   cd ~/rhasspy-pi-zero
   ./install_pi_zero_docker.sh
   cp ~/profile_backup.json profiles/sv/profile.json
   docker compose up -d
   ```

4. **(Valfritt) Rensa gamla filer:**
   ```bash
   rm -rf ~/rhasspy ~/rhasspy-venv ~/.config/rhasspy
   ```

## Jämförelse

| Funktion | Källkodsinstallation | Docker-installation |
|----------|---------------------|-------------------|
| Python 3.13+ kompatibilitet | ❌ Problematisk | ✅ Fungerar |
| Installationstid | 30-60 minuter | 5-10 minuter |
| Diskutrymme | ~2 GB (venv + källkod) | ~800 MB (image) |
| Uppdateringar | Komplex (rebuild) | Enkel (pull + restart) |
| Felsökning | Svår (många beroenden) | Enklare (isolerad miljö) |
| Kompatibilitet med bas | Olika metoder | Samma metod |
| Systemd-integration | ✅ Stöds | ✅ Stöds |
| Prestanda | Native | Minimal overhead |

## Framtida arbete

Med denna lösning är projektet nu:
- **Framtidssäkert** - Fungerar med nuvarande och framtida Python-versioner
- **Underhållbart** - Docker-baserat, lätt att uppdatera
- **Konsistent** - Samma arkitektur för både bas och satellit
- **Väldokumenterat** - Snabbstart, README och felsökningsguider

## Referenser

- [Docker för Raspberry Pi](https://docs.docker.com/engine/install/debian/)
- [Rhasspy dokumentation](https://rhasspy.readthedocs.io/)
- [Docker Compose dokumentation](https://docs.docker.com/compose/)
- [Python 3.13 ändringslogg](https://docs.python.org/3/whatsnew/3.13.html) - Borttagning av distutils
