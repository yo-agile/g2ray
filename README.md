# @Kakoolnews

> Automated VLESS proxy setup via GitHub Codespaces with Cloudflare Tunnel — works anywhere Codespaces is available.

## Warning

**Use a secondary GitHub account (not your main account)** when forking and running this project. Running proxy servers may trigger GitHub's automated security systems or account restrictions.

## Features

- **Fixed UUID** — consistent identity across all sessions: `12345678-1234-1234-1234-123456789abc`
- **Cloudflare Tunnel** — automatically exposes proxy via `*.trycloudflare.com` domain
- **Latest Xray-core** — automatically fetches the newest stable release at build time
- **WebSocket Transport** — VLESS over WebSocket for better compatibility
- **Bandwidth Tracking** — uses vnstat to monitor network usage
- **Interactive Commands** — restart Xray on demand from terminal

## Quick Start

1. Fork this repository (use a secondary account)
2. Click **Code** > **Codespaces** > **Create codespace on main**
3. Wait 3–5 minutes for setup to complete
4. Copy the VLESS link printed in the terminal (starts with `🔗 YOUR VLESS LINK:`)
5. The VLESS link is also saved to `/workspaces/vless_link.txt`

### Import the Link

Use the generated VLESS link in any compatible proxy client:

- [V2RayNG](https://github.com/2dust/v2rayNG) (Android)
- [V2RayN](https://github.com/2dust/v2rayN) (Windows)
- [Netch](https://github.com/netchx/netch) (Windows — gaming/TUN mode)
- [Clash Meta](https://github.com/MetaCubeX/ClashMetaForAndroid) (Android)
- [Nekoray](https://github.com/MatsuriDayo/nekoray) (Linux/Windows)

## Configuration

### Fixed UUID

This repository uses a fixed UUID for all sessions:

```
12345678-1234-1234-1234-123456789abc
```

### Xray Config

The proxy configuration is in `.devcontainer/config.json`. Key settings:

| Setting | Value | Description |
|---------|-------|-------------|
| Protocol | VLESS | Proxy protocol |
| Transport | WebSocket (ws) | Stream transport type |
| Path | /ws | WebSocket path |
| Internal Port | 10000 | Xray listening port |
| TLS | enabled | TLS encryption via Cloudflare |

### Cloudflare Tunnel

The proxy is exposed via Cloudflare Tunnel (`cloudflared`) which provides:
- Automatic HTTPS/TLS termination
- Dynamic hostname (`*.trycloudflare.com`)
- No port forwarding required

## Commands

Once your Codespace is running, you can use these commands in the terminal:

| Command | Description |
|---------|-------------|
| `1` | Restart Xray proxy |
| `q` | Quit and stop all services |

### Bandwidth Usage

To check network traffic usage:

```bash
bash /workspaces/usage.sh
```

Example output:
```
Total received: 1.23 GB
Total sent: 0.45 GB
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
| Connection timeout | Wait a moment and try again; tunnel may still be establishing |
| Tunnel hostname not found | Check if cloudflared is running properly |

## Project Structure

```
.devcontainer/
  Dockerfile          # Container image definition (Xray, cloudflared, vnstat)
  config.json         # Xray VLESS/WebSocket configuration
  devcontainer.json   # Codespace settings and lifecycle hooks
  setup.sh            # Main setup script (starts Xray, cloudflared tunnel)
  usage.sh            # Bandwidth monitoring script
docs/
  screenshot.png      # Terminal screenshot for reference
```

## VLESS Link Format

The generated VLESS link follows this format:

```
vless://12345678-1234-1234-1234-123456789abc@<HOSTNAME>:443?encryption=none&security=tls&type=ws&host=<HOSTNAME>&path=%2Fws#Kakool%20news
```

Where `<HOSTNAME>` is dynamically assigned by Cloudflare Tunnel (e.g., `abc123.trycloudflare.com`).

## Disclaimer

This tool is for educational and legitimate use only. Users are responsible for complying with local laws and regulations regarding proxy usage. The author is not responsible for any misuse.

## License

This project is open-source. See the LICENSE file for details.
