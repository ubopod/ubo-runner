# Ubo - GitHub Actions Runner Setup

This repository contains scripts to set up and manage GitHub Actions self-hosted runners for the Ubo project.

## Setup

### Prerequisites

- **GitHub Token**: Set the `GITHUB_TOKEN` environment variable with a GitHub personal access token that has repository access
- **SSH Access**: SSH access to the target device (typically a Raspberry Pi)
- **Dependencies**: The target device needs `curl`, `jq`, and `systemd` support

### Stop Ubo App

Before setting up the runner, you need to stop the Ubo app and disable it from starting on boot on the target device.

```bash
ssh pi@ubo-name.local
> sudo su ubo
> systemctl --user stop ubo-app
> systemctl --user disable ubo-app
```

### Usage

Run the setup script with SSH address and runner label:

```bash
export GITHUB_TOKEN="your_github_token_here"
./scripts/setup.sh <ssh-address> <runner-label>
```

**Example:**
```bash
./scripts/setup.sh pi@ubo-8u.local ubo-pod-pi5-2
```

### What the Setup Script Does

The `setup.sh` script performs the following operations on the remote device:

1. **Downloads GitHub Actions Runner**: Fetches the latest ARM64 Linux runner from GitHub releases
2. **Configures Runner**: Sets up the runner to connect to the `ubopod/ubo_app` repository with the specified label
3. **Creates Systemd Service**: Installs a user systemd service for automatic startup and management
4. **Enables Auto-start**: Configures the runner to start automatically and restart on failure

### Runner Management

Once set up, the runner runs as a systemd user service on the target device:

- **Service name**: `github-actions-runner.service`
- **Auto-restart**: Enabled (restarts on failure)
- **Working directory**: `~/actions-runner`
- **User**: `ubo`

### Manual Service Management

On the target device, you can manage the runner service:

```bash
# Check status
systemctl --user status github-actions-runner.service

# Stop the service
systemctl --user stop github-actions-runner.service

# Start the service
systemctl --user start github-actions-runner.service

# Restart the service
systemctl --user restart github-actions-runner.service
```

## Future Plans

We will have an image for this purpose which automatically runs the runner after boot.
