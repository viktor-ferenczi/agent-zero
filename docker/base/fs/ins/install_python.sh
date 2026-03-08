#!/bin/bash
set -e

echo "====================PYTHON START===================="

# Python 3.13 and uv are already provided by the base image
# (ghcr.io/astral-sh/uv:python3.13-bookworm)

echo "====================PYTHON 3.13 VENV===================="

# create and activate default venv
python3 -m venv /opt/venv
source /opt/venv/bin/activate

# upgrade pip and install static packages
pip install --no-cache-dir --upgrade pip pipx ipython

# preinstall common packages
pip install --no-cache-dir \
    requests pydantic httpx lxml openai \
    Pillow numpy pandas scipy \
    tree-sitter tree-sitter-c-sharp tree-sitter-markdown \
    tree-sitter-python tree-sitter-xml

echo "====================PYTHON PYVENV===================="

# Install pyenv build dependencies.
apt-get install -y --no-install-recommends \
    make build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev \
    libxmlsec1-dev libffi-dev liblzma-dev

# Install pyenv globally
git clone https://github.com/pyenv/pyenv.git /opt/pyenv

# Setup environment variables for pyenv to be available system-wide
cat > /etc/profile.d/pyenv.sh <<'EOF'
export PYENV_ROOT="/opt/pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
EOF

# fix permissions
chmod +x /etc/profile.d/pyenv.sh

# Source pyenv environment to make it available in this script
source /etc/profile.d/pyenv.sh

# Install Python 3.12.4
echo "====================PYENV 3.12 VENV===================="
pyenv install 3.12.4

/opt/pyenv/versions/3.12.4/bin/python -m venv /opt/venv-a0
source /opt/venv-a0/bin/activate

# upgrade pip and install static packages
pip install --no-cache-dir --upgrade pip

# Install some packages in specific variants
pip install --no-cache-dir \
    torch==2.4.0 \
    torchvision==0.19.0 \
    --index-url https://download.pytorch.org/whl/cpu

# clean up pip cache
pip cache purge

echo "====================PYTHON END===================="
