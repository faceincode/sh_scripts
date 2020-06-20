# Update
echo "()()>>>> UPDATING APT-GET..."
sudo apt-get -y update

# CLI tools
if ! [ -x "$(command -v vim)" ]; then
  echo "()()>>>> SETTING UP CLI"
  sudo apt-get install -y man vim npm tmux snapd tldr
  echo "export PATH=\$PATH:/snap/bin" >> ~/.bashrc

  sudo apt-get install -y make gcc g++
  sudo apt-get install -y pig-config libssl-dev libboost-all-dev

  sudo npm -i -g http-server
else
  echo "()()>>>> CLI ALREADY SETUP"
fi

# Python Installation
if ! [ -x "$(command -v python3)" ]; then
  echo "()()>>>> INSTALLING PYTHON"
  sudo apt-get install -y python3
  sudo apt-get install -y python3-pip
else
  python3 --version | xargs echo "()()>>>> PYTHON ALREADY INSTALLED"
  which python3
fi

# Install Chrome for Selenium
if ! [ -x "$(command -v google-chrome)" ]; then
  echo "()()>>>> INSTALLING CHROME"
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg -i google-chrome-stable_current_amd64.deb
else
  google-chrome --version | xargs echo "()()>>>> GOOGLE CHROME ALREADY INSTALLED"
  which google-chrome
fi

# Install Brave
if ! [ -x "$(command -v brave-browser)" ]; then
  sudo apt-get install -y apt-transport-https curl
  curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
  echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo apt-get -y update
  sudo apt-get install -y brave-browser
else
  brave-browser --version | xargs echo "()()>>>> BRAVE BROWSER ALREADY INSTALLED"
  which brave-browser
fi

# Open browser on PIA download page
if [ -x "$(test -n "$(find ~/Downloads -maxdepth 1 -name 'pia*' -print -quit)" )" ]; then
  echo "()()>>>> PLEASE DOWNLOAD PIA"
  brave-browser https://www.privateinternetaccess.com/installer/download_installer_linux_beta
else
  echo "()()>>>> PIA ALREADY DOWNLOADED"
  ls ~/Downloads/ | grep pia | xargs -l echo "~/Downloads/"
fi

# Update PopOS monitor configuration
# If monitor misbehaves, attempt to adjust physical settings in linux control panel
if cat "/lib/modprobe.d/nvidia-graphics-drivers.conf" | grep nodeset=1; then
  echo "()()>>>> UPDATING NVIDIA CONFIGURATION"
  sudo sed -i '/options nvidia-drm nodeset=1/coptions nvidia-drm nodeset=0' /lib/modprobe.d/nvidia-graphics-drivers.conf 
else
  echo "()()>>>> NVIDIA CONFIGURATION ALREADY SETUP"
  echo "/lib/modprobe.d/nvidia-graphics-drivers.conf"
fi

# Angular
if ! [ -x "$( command -v ng)" ]; then
  echo "()()>>>> INSTALLING ANGULAR" 
  sudo npm install -g @angular/cli
  sudo npm install angular-in-memory-web-api --save
else
  echo "()()>>>> ANGULAR ALREADY INSTALLED"
  which ng
fi

# Firebase
if ! [ -x "$( command -v firebase)" ]; then
  echo "()()>>>> INSTALLING FIREBASE CLI"
  sudo npm install -g firebase-tools
else
  echo "()()>>>> FIREBASE CLI ALREADY INSTALLED"
  which firebase
fi

# VLC
if ! [ -x "$( command -v vlc)" ]; then
  echo "()()>>>> INSTALLING VLC"
  sudo snap install vlc
else
  echo "()()>>>> VLC ALREADY INSTALLED"
  which vlc
fi
