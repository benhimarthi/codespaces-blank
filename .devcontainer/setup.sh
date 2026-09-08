#!/bin/bash
set -e

cd ~

# Install Flutter SDK
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi
export PATH="$PATH:$HOME/flutter/bin"

# Install Android command-line SDK tools
if [ ! -d "android-sdk" ]; then
  mkdir -p android-sdk/cmdline-tools
  cd android-sdk/cmdline-tools
  curl -o cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
  unzip -q cmdline-tools.zip
  mv cmdline-tools latest
  rm cmdline-tools.zip
  cd ~
fi

cat >> .devcontainer/setup.sh << 'EOF'

# Tailscale setup
if ! command -v tailscale &> /dev/null; then
  curl -fsSL https://tailscale.com/install.sh | sh
fi

sudo mkdir -p /var/run/tailscale
sudo tailscaled --tun=userspace-networking --socket=/var/run/tailscale/tailscaled.sock > ~/tailscaled.log 2>&1 &
sleep 3
sudo tailscale up --socket=/var/run/tailscale/tailscaled.sock
EOF

export ANDROID_HOME="$HOME/android-sdk"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-36" "build-tools;28.0.3"

flutter config --android-sdk "$ANDROID_HOME"

# Make PATH persistent in interactive shells too
echo 'export PATH="$PATH:$HOME/flutter/bin:$HOME/android-sdk/cmdline-tools/latest/bin:$HOME/android-sdk/platform-tools"' >> ~/.bashrc
echo 'export ANDROID_HOME="$HOME/android-sdk"' >> ~/.bashrc

flutter doctor