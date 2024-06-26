#!/usr/bin/env sh

ssh ubo-development-pod "cat <<'EOF' > /tmp/run_script.sh
cd ~/actions-runner
PATH=\$PATH:~/.local/bin tmux new-session -d ./run.sh
EOF
sudo -u ubo bash /tmp/run_script.sh
rm -f /tmp/run_script.sh"
