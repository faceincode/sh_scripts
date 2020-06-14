# CLI tools
if ! [ -x "$(command -v vim)" ]; then
  echo "()()>>>> SETTING UP CLI"
  sudo apt install man
  sudo apt install vim
  sudo apt install npm
  sudo apt install snapd
  echo "export PATH=\$PATH:/snap/bin" >> ~/.bashrc
else
  echo "()()>>>> CLI ALREADY SETUP"
fi

# Update
echo "()()>>>> UPDATING APT-GET..."
sudo apt-get update

# Python Installation
if ! [ -x "$(command -v python3)" ]; then
  echo "()()>>>> INSTALLING PYTHON"
  sudo apt install python3
  sudo apt install python3-pip
else
  python3 --version | xargs echo "()()>>>> PYTHON ALREADY INSTALLED"
fi

# Install Brave
if ! [ -x "$(command -v brave-browser)" ]; then
  sudo apt install apt-transport-https curl
  curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
  echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo apt update
  sudo apt install brave-browser
else
  brave-browser --version | xargs echo "()()>>>> BRAVE BROWSER ALREADY INSTALLED"
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
if [ -f "/lib/modprobe.d/nvidia-graphics-drivers.conf" ]; then
   echo "()()>>>> UPDATING NVIDIA CONFIGURATION"
   sudo sed -i '/options nvidia-drm nodeset=1/coptions nvidia-drm nodeset=0' /lib/modprobe.d/nvidia-graphics-drivers.conf 
fi

# Angular
if ! [ -x "$( command -v ng)"]; then
  echo "()()>>>> INSTALLING ANGULAR" 
  sudo npm install -g @angular/cli
else
  echo "()()>>>> ANGULAR ALREADY INSTALLED" 
fi

# VLC
if ! [ -x "$( command -v vlc)"]; then
  echo "()()>>>> INSTALLING VLC"
  sudo snap install vlc
else
  echo "()()>>>> VLC ALREADY INSTALLED"
fi
