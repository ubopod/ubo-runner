#!/usr/bin/env sh

# Check $GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
  echo "\$GITHUB_TOKEN is not set"
  exit 1
fi

ssh ubo-development-pod sudo apt install tmux
ssh ubo-development-pod "cat <<'EOF' > /tmp/run_script.sh
curl -sSL https://install.python-poetry.org | python3 -
cd
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-arm64-2.317.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-linux-arm64-2.317.0.tar.gz
echo '7e8e2095d2c30bbaa3d2ef03505622b883d9cb985add6596dbe2f234ece308f3  actions-runner-linux-arm64-2.317.0.tar.gz' | shasum -a 256 -c
tar xzf ./actions-runner-linux-arm64-2.317.0.tar.gz
./config.sh --url https://github.com/ubopod/ubo_app --token $GITHUB_TOKEN --unattended
cat /tmp/get-poetry.py | python3 -
EOF
sudo -u ubo bash /tmp/run_script.sh
rm -f /tmp/run_script.sh"
