#!/usr/bin/env sh

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

ssh ubo-development-pod "cat <<'EOF' > /tmp/run_script.sh
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

cd ~/actions-runner
PATH=\$PATH:~/.local/bin tmux new-session -d ./run.sh
EOF
sudo -u ubo bash /tmp/run_script.sh
rm -f /tmp/run_script.sh"
