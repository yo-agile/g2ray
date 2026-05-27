# @Kakoolnews

> Automated VLESS proxy setup via GitHub Codespaces — works anywhere Codespaces is available.

## Warning

**Use a secondary GitHub account (not your main account)** when forking and running this project. Running proxy servers may trigger GitHub's automated security systems or account restrictions.

## Features

- **Fixed UUID** — consistent identity across all sessions: `12345678-1234-1234-1234-123456789abc`
- **Latest Xray-core** — automatically fetches the newest stable Xray-core release
- **Multi-architecture** — supports amd64, arm64, and armv7
- **Bandwidth Tracking** — uses vnstat to monitor network usage
- **Quick Restart** — type `1` to restart Xray anytime

## Quick Start

1. Fork this repository (use a secondary account)
2. Click **Code** > **Codespaces** > **Create codespace on main**
3. Wait 2–5 minutes for setup to complete
4. Copy the VLESS links printed in the terminal
5. Import the link into your proxy client

### Import the Link

Use the generated VLESS link in any compatible proxy client:

- [V2RayNG](https://github.com/2dust/v2rayNG) (Android)
- [V2RayN](https://github.com/2dust/v2rayN) (Windows)
- [Netch](https://github.com/netchx/netch) (Windows — gaming/TUN mode)
- [Clash Meta](https://github.com/MetaCubeX/ClashMetaForAndroid) (Android)
- [Nekoray](https://github.com/MatsuriDayo/nekoray) (Linux/Windows)

## Configuration

### Fixed UUID

This repository uses a fixed UUID for all sessions. You will never need to re-import the link:

```
12345678-1234-1234-1234-123456789abc
```

### Xray Config

The proxy configuration is in `.devcontainer/config.json`. Key settings:

| Setting | Value | Description |
|---------|-------|-------------|
| Protocol | VLESS | Proxy protocol |
| Port | 443 | Inbound port |
| Transport | xhttp | Stream transport type |
| Path | / | HTTP request path |
| Mode | packet-up | Packet mode |

## Commands

Once your Codespace is running, you can use these commands in the terminal:

| Command | Description |
|---------|-------------|
| `1` | Restart Xray proxy |
| `bash /workspaces/usage.sh` | Check bandwidth usage |

## VLESS Connection Strings

The VLESS links are displayed when you open the terminal:

```
vless://12345678-1234-1234-1234-123456789abc@20.103.221.187:443?encryption=none&security=tls&type=xhttp&mode=packet-up&path=%2F#Kakool%20news-1

vless://12345678-1234-1234-1234-123456789abc@20.90.66.7:443?encryption=none&security=tls&type=xhttp&mode=packet-up&path=%2F#Kakool%20news-2
```

## Codespace Quota

GitHub provides **120 free core-hours/month**:

| Cores | Hours/Month |
|-------|-------------|
| 2 | 60 |
| 4 | 30 |
| 8 | 15 |

**Stop your Codespace when not in use** to conserve hours.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Codespace fails to start | Delete it and create a new one |
| No VLESS link shown | Check the terminal output for errors |
| Connection timeout | Try a different datacenter or ISP |

## Project Structure

```
.devcontainer/
  Dockerfile          # Container image definition
  config.json         # Xray configuration with fixed UUID
  devcontainer.json   # Codespace settings and lifecycle hooks
  setup.sh           # Downloads and installs Xray binary
  usage.sh           # Bandwidth monitoring script
docs/
  screenshot.png      # Terminal screenshot for reference
```

## Disclaimer

This tool is for educational and legitimate use only. Users are responsible for complying with local laws and regulations regarding proxy usage. The author is not responsible for any misuse.

## License

This project is open-source. See the LICENSE file for details.
