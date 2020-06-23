VOLUMES=$HOME/volumes/

# Add all files to load into DB @ $HOME/volumes/pg_analytics.
DB_ANALYTICS_NAME=pg_analytics
DB_ANALYTICS_VOLUME=$HOME/volumes/pg_analytics/
DB_ANALYTICS_PORT=5432:5432
DB_ANALYTICS_ENV=./docker_analytics_db.env

if ! [ -d "$VOLUMES" ]; then
  echo "()()>>>> SETTING UP VOLUMES"
  mkdir $VOLUMES
fi

# Update
echo "()()>>>> UPDATING APT..."
sudo apt-get -y update

# CLI tools
if ! [ -x "$(command -v vim)" ]; then
  echo "()()>>>> SETTING UP CORE SYSTEM TOOLS"
  sudo apt-get install -y npm snapd curl tmux vim man tldr
  echo "export PATH=\$PATH:/snap/bin" >> ~/.bashrc

  sudo apt-get install -y make gcc g++
  sudo apt-get install -y pig-config libssl-dev libboost-all-dev

  sudo npm -i -g http-server
  echo"()()>>>> SUCCESS: CORE SYSTEM TOOLS INSTALLED"
else
  echo "()()>>>> CORE SYSTEM TOOLS ALREADY SETUP"
fi

# Docker Installation
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
if ! [ -x "$(command -v docker)" ]; then
  echo "()()>>>> PREPARING DOCKER FOR INSTALLATION"
  sudo apt-get install -y \
	apt-transport-https \
	ca-certificates \
	gnupg-agent \
	software-properties-common \

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg > docker.asc 
  
  # We're going to use GPG to test the docker.asc signature
  # This verifies that this is an official Docker file before installing it
  # CLI Command 'add-key' should not be consumed from the stdout
  if [ $(gpg -n -q --import --import-options import-show docker.asc | grep 9DC858229FC7DD38854AE2D88D81803C0EBFCD88) ]; then
    echo "()()>>>> INSTALLING DOCKER"
    sudo apt-key add docker.asc
    
    sudo add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) \
   	stable"

    sudo apt-get update

    # #1 - List docker-ce versions available \
    # & take the last version (3rd most recent) from the list.
    # OR 
    # #2 - Assign any docker version you want to docker_version
    docker_version=$(apt-cache madison docker-ce | \
	    tail -n -1 | \
	    awk -F '|' '{print $2}' | \
	    sed -e 's/ *//g')
    echo "$docker_version"
    
    sudo apt-get install -y docker-ce=$docker_version docker-ce-cli=$docker_version containerd.io

    echo "()()>>>> ADD USER TO DOCKER GROUP"
    sudo groupadd docker
    sudo usermod -aG docker $USER

    # Restart docker group
    newgrp docker

    echo "()()>>> TEST DOCKER INSTALLATION"
    sudo docker run hello-world

    # Configure Docker to start on boot
    sudo systemctl enable docker

    docker --version | xargs echo "()()>>>> SUCCESS: DOCKER INSTALLED"
    which docker | xargs echo "()()>>>> LOCATION:"
  else
    echo "()()>>>> DOCKER CHECKSUM INVALID!"
  fi
else
  docker --version | xargs echo "()()>>>> DOCKER ALREADY INSTALLED"
  sudo docker run hello-world | xargs echo "()()>>>> LOCATION:"
fi

if ! [ -x "$(command -v docker-compose)" ]; then
  echo "()()>>>> INSTALLING DOCKER COMPOSE"
  sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose

  # if fails try to set PATH
  # sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

  docker-compose --version | xargs echo "()()>>>> SUCCESS: DOCKER COMPOSE INSTALLED"
  which docker-compose | xargs echo "()()>>>> LOCATION:"
else
  docker-compose --version | xargs  echo "()()>>>> DOCKER COMPOSE IS ALREADY INSTALLED"
  which docker-compose | xargs echo "()()>>>> LOCATION:"
fi

# Postgres Analytics DB Setup
if ! docker ps -a | grep $DB_ANALYTICS_NAME -q; then
  echo "()()>>>> SETTING UP POSTGRES - DOCKER - [$DB_ANALYTICS_NAME]"

  if ! [ -d $DB_ANALYTICS_VOLUME ]; then
    mkdir $DB_ANALYTICS_VOLUME
  fi

  # 1 - Connect to DB using $DB_ANALYTICS_ENV parameters
  # 2 - Put all .csv files in $DB_ANALYTICS_PATH
  # 3 - Load data using SQL:
  # copy table_name() from '/data/file_name.csv' delimiter ',' null as '' csv;
  docker run --name $DB_ANALYTICS_NAME --env-file $DB_ANALYTICS_ENV -d -p $DB_ANALYTICS_PORT -v $DB_ANALYTICS_PATH:/data postgres
else
  if docker ps -a | grep $DB_ANALYTICS_NAME -q; then
    echo "()()>>>> RESTART POSTGRES - DOCKER - [$DB_ANALYTICS_NAME]"
    docker restart $DB_ANALYTICS_NAME
  else
    echo "()()>>>> POSTGRES - DOCKER [$DB_ANALYTICS_NAME] - ALREADY SETUP."
  fi
fi

# Python Installation
if ! [ -x "$(command -v python3)" ]; then
  echo "()()>>>> INSTALLING PYTHON"
  sudo apt-get install -y python3
  sudo apt-get install -y python3-pip

  python3 --version | xargs echo "()()>>>> SUCCESS: PYTHON INSTALLED"
  which python3 | xargs echo "()()>>>> LOCATION:"
else
  python3 --version | xargs echo "()()>>>> PYTHON ALREADY INSTALLED"
  which python3 | xargs echo "()()>>>> LOCATION:"
fi

# Install Chrome for Selenium
if ! [ -x "$(command -v google-chrome)" ]; then
  echo "()()>>>> INSTALLING CHROME"
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg -i google-chrome-stable_current_amd64.deb

  google-chrome --version | xargs echo "()()>>>> SUCCESS: GOOGLE CHROME INSTALLED"
  which google-chrome | xargs echo "()()>>>> LOCATION:"
else
  google-chrome --version | xargs echo "()()>>>> GOOGLE CHROME ALREADY INSTALLED"
  which google-chrome | xargs echo "()()>>>> LOCATION:"
fi

# Install Brave
if ! [ -x "$(command -v brave-browser)" ]; then
  sudo apt-get install -y apt-transport-https curl
  curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
  echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo apt-get -y update
  sudo apt-get install -y brave-browser

  brave-browser --version | xargs echo "()()>>>> SUCCCESS: BRAVE BROWSER INSTALLED"
  which brave-browser | xargs echo "()()>>>> LOCATION:"
else
  brave-browser --version | xargs echo "()()>>>> BRAVE BROWSER ALREADY INSTALLED"
  which brave-browser | xargs echo "()()>>>> LOCATION:"
fi

# Open browser on PIA download page
if [ -x "$(test -n "$(find ~/Downloads -maxdepth 1 -name 'pia*' -print -quit)" )" ]; then
  echo "()()>>>> PLEASE DOWNLOAD PIA MANUALLY"
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

  echo "()()>>>> SUCCESS: NVIDIA CONFIGURED"
  echo "()()>>>> LOCATION: /lib/modprobe.d/nvidia-graphics-drivers.conf"
else
  echo "()()>>>> NVIDIA CONFIGURATION ALREADY SETUP"
  echo "()()>>>> LOCATION: /lib/modprobe.d/nvidia-graphics-drivers.conf"
fi

# Angular
if ! [ -x "$( command -v ng)" ]; then
  echo "()()>>>> INSTALLING ANGULAR" 
  sudo npm install -g @angular/cli
  sudo npm install angular-in-memory-web-api --save

  ng --version | xargs echo "()()>>>> SUCCESS: ANGULAR INSTALLED"
  which ng | xargs echo "()()>>>> LOCATION:"
else
  ng --version | xargs echo "()()>>>> ANGULAR ALREADY INSTALLED"
  which ng | xargs echo "()()>>>> LOCATION:"
fi

# Firebase
if ! [ -x "$( command -v firebase)" ]; then
  echo "()()>>>> INSTALLING FIREBASE CLI"
  sudo npm install -g firebase-tools

  firebase --version | xargs echo "()()>>>> SUCCESS: FIREBASE CLI INSTALLED"
  which firebase | xargs echo "()()>>>> LOCATION:"
else
  firebase --version | xargs echo "()()>>>> FIREBASE CLI ALREADY INSTALLED"
  which firebase | xargs echo "()()>>>> LOCATION:"
fi

# VLC
if ! [ -x "$( command -v vlc)" ]; then
  echo "()()>>>> INSTALLING VLC"
  sudo snap install vlc

  vlc --version | xargs echo "()()>>>> SUCCESS: VLC INSTALLED"
  which vlc | xargs echo "()()>>>> LOCATION:"
else
  vlc --version | xargs echo "()()>>>> VLC ALREADY INSTALLED"
  which vlc | xargs echo "()()>>>> LOCATION:"
fi
