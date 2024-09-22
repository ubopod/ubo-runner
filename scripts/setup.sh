#!/usr/bin/env sh

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

# Check $GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
  echo "\$GITHUB_TOKEN is not set"
  exit 1
fi

LATEST_ASSET_URL=$(curl https://api.github.com/repos/actions/runner/releases/latest | jq -r '.assets[] | select(.name | contains("linux-arm64")) | .browser_download_url')

ssh ubo-development-pod sudo apt install tmux
ssh -t ubo-development-pod "cat <<'EOF' > /tmp/run_script.sh
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

if [ ! -f ~/.local/bin/poetry ]; then
  curl -sSL https://install.python-poetry.org | python3 -
fi
cd
mkdir -p actions-runner && cd actions-runner
if [ ! -f ./config.sh ]; then
  if [ ! -f actions-runner-linux-arm64-latest.tar.gz ]; then
    curl -o actions-runner-linux-arm64-latest.tar.gz -L "$LATEST_ASSET_URL"
  fi
  tar xzf ./actions-runner-linux-arm64-latest.tar.gz
fi
./config.sh --url https://github.com/ubopod/ubo_app --token $GITHUB_TOKEN --unattended --labels ubo-pod
EOF
sudo -u ubo bash /tmp/run_script.sh
rm -f /tmp/run_script.sh"
