#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

# Check $GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
  echo "\$GITHUB_TOKEN is not set"
  exit 1
fi

LATEST_ASSET_URL=$(curl -L https://api.github.com/repos/actions/runner/releases/latest | jq -r '.assets[] | select(.name | contains("linux-arm64")) | .browser_download_url')
if [ -z "$LATEST_ASSET_URL" ] || [ "$LATEST_ASSET_URL" = "null" ]; then
  echo "Failed to get runner download URL"
  exit 1
fi

ssh -t "pi@$1" "cat <<EOF > /tmp/script.sh
#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
export XDG_RUNTIME_DIR=/run/user/\$(id -u ubo)

cd
mkdir -p actions-runner && cd actions-runner
if [ ! -f ./config.sh ]; then
  if [ ! -f actions-runner-linux-arm64-latest.tar.gz ]; then
    curl -o actions-runner-linux-arm64-latest.tar.gz -L "$LATEST_ASSET_URL"
  fi
  tar xzf ./actions-runner-linux-arm64-latest.tar.gz
fi
./config.sh --url https://github.com/ubopod/ubo_app --token $GITHUB_TOKEN --unattended --labels ubo-pod

# Create systemd user service directory
mkdir -p "~/.config/systemd/user"

# Create systemd service file
cat << 'EOF_SERVICE' > "~/.config/systemd/user/github-actions-runner.service"
[Unit]
Description=GitHub Actions Runner

[Service]
WorkingDirectory=%h/actions-runner
ExecStart=%h/actions-runner/run.sh
Restart=always
Environment=PATH=\$PATH:~/.local/bin

[Install]
WantedBy=default.target
EOF_SERVICE

# Reload systemd user daemon, enable and start the service
systemctl --user daemon-reload
systemctl --user enable --now github-actions-runner.service

EOF
sudo -u ubo bash /tmp/script.sh
rm -f /tmp/script.sh
"
