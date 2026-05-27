# @Kakoolnews

> Automated VLESS proxy setup via GitHub Codespaces — works anywhere Codespaces is available.

## Warning

**Use a secondary GitHub account (not your main account)** when forking and running this project. Running proxy servers may trigger GitHub's automated security systems or account restrictions.

## Features

- **Static UUID** — consistent identity: `db9c5b9e-06b9-40cf-b987-575afcb30aea`
- **Latest Xray-core** — automatically fetches the newest stable release
- **WebSocket Transport** — ws protocol for better compatibility
- **Bandwidth Tracking** — uses vnstat to monitor usage
- **Quick Restart** — type `1` to restart Xray

## Quick Start

1. Fork this repository (use a secondary account)
2. Click **Code** > **Codespaces** > **Create codespace on master**
3. Wait 2–5 minutes for setup to complete
4. Copy the VLESS links printed in the terminal

### Import the Link

Use the generated VLESS link in any compatible proxy client:

- [V2RayNG](https://github.com/2dust/v2rayNG) (Android)
- [V2RayN](https://github.com/2dust/v2rayN) (Windows)
- [Netch](https://github.com/netchx/netch) (Windows)
- [Clash Meta](https://github.com/MetaCubeX/ClashMetaForAndroid) (Android)

## VLESS Connection Strings

```
vless://db9c5b9e-06b9-40cf-b987-575afcb30aea@20.103.221.187:443?encryption=none&security=tls&type=ws&path=%2F#@Kakoolnews-1

vless://db9c5b9e-06b9-40cf-b987-575afcb30aea@20.90.66.7:443?encryption=none&security=tls&type=ws&path=%2F#@Kakoolnews-2
```

## Commands

| Command | Description |
|---------|-------------|
| `1` | Restart Xray |
| `bash /workspaces/usage.sh` | Check bandwidth usage |

## Codespace Quota

GitHub provides **120 free core-hours/month**:

| Cores | Hours/Month |
|-------|-------------|
| 2 | 60 |
| 4 | 30 |
| 8 | 15 |

**Stop your Codespace when not in use** to conserve hours.

## Project Structure

```
.devcontainer/
  Dockerfile          # Container image definition
  config.json         # Xray WebSocket configuration
  devcontainer.json   # Codespace settings
  entrypoint.sh       # Startup script (prints VLESS links)
  install.sh          # Xray installation
  usage.sh           # Bandwidth monitoring
```

## Disclaimer

This tool is for educational and legitimate use only. The author is not responsible for any misuse.
