#!/bin/bash
clear
echo "
 _____                 ______
 |_   _|               |  ____|
   | |  _ __ ___  _ __ | |__ _____  __
   | | | '__/ _ \| '_ \|  __/ _ \ \/ /
  _| |_| | | (_) | | | | | | (_) >  <
 |_____|_|  \___/|_| |_|_|  \___/_/\_\


 By: Innovera Technology
 CodeName: The Desert Fox (0.0.5)
"

#define variables
SERVER_IP="0.0.0.0"
IRON_FOX_ROOT=$PWD
NGINX_PATH=$IRON_FOX_ROOT/nginx-1.19.2
MODULES_PATH=$IRON_FOX_ROOT/modules
SETUP_PATH=/home/ironfox/iron
BIN_PATH=/home/ironfox/iron/sbin

echo "Start setup..."
if [[ $(id -u) -ne 0 ]]; then
  echo "error: please run as the installer with root privilege. exit(1)"
  exit 1
fi
echo "shutdown service and clean up path..."
sudo rm -R $SETUP_PATH
sudo rm -R  nginx-1.19.2
tar xfv nginx-1.19.2.tar.gz
sudo systemctl stop innovera
sudo kill 9 `ps -aux | grep nginx | awk '{print $2}'`

#build embedded file
echo "#!/bin/bash
sudo java -jar $SETUP_PATH/sbin/panel.jar  --spring.config.location=$SETUP_PATH/sbin/application.properties
" > manager/runservice.sh

echo "[Unit]
Description=IronFox panel service
[Service]
User=root
# The configuration file application.properties should be here:
#change this to your workspace
WorkingDirectory=$BIN_PATH
#path to executable.
#executable is a bash script which calls jar file
ExecStart=$BIN_PATH/runservice.sh
SuccessExitStatus=143
TimeoutStopSec=10
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target
" > manager/innovera.service

echo "check and setup dependencies..."
sudo apt install build-essential
sudo apt install redis
sudo apt install libpcre3-dev
sudo apt install libhiredis-dev
sudo apt install libssl-dev
sudo apt install zlib1g-dev
sudo apt install openjdk-8-jdk

#todo install postgresql, db and config username

echo "apply iptables settings..."
#sudo iptables -P INPUT ACCEPT
#sudo iptables -P OUTPUT ACCEPT
#sudo iptables -F
#sudo iptables -A INPUT -i lo -j ACCEPT
#sudo iptables -A OUTPUT -o lo -j ACCEPT
#
#sudo iptables -t nat -F
##sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 443
#sudo iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
#sudo iptables -A OUTPUT -p tcp -m tcp --sport 443 -j ACCEPT
#
#sudo iptables -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
#sudo iptables -A OUTPUT -p tcp -m tcp --sport 8080 -j ACCEPT
#sudo iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
#sudo iptables -A OUTPUT -p tcp -m tcp --sport 22 -j ACCEPT
#sudo iptables -P INPUT DROP
#sudo iptables -P OUTPUT DROP

echo "compiling source..."
sudo mkdir $SETUP_PATH
sudo mkdir $SETUP_PATH/sbin/
sudo mkdir $SETUP_PATH/cert/
sudo mkdir $SETUP_PATH/html/

echo "apply nginx patch..."
patch  -p0 < $IRON_FOX_ROOT/nginx.patch

cd $NGINX_PATH
./configure --prefix=$SETUP_PATH --with-ld-opt='-Wl,-rpath,/usr/local/lib' \
  --sbin-path=$SETUP_PATH/sbin/ \
  --with-http_sub_module \
  --with-debug \
  --with-http_ssl_module \
  --with-compat \
  --add-dynamic-module=${MODULES_PATH}/ngx_http_bot_protection_module \
  --add-dynamic-module=${MODULES_PATH}/ngx_http_header_inspect \
  --add-dynamic-module=${MODULES_PATH}/replace-filter-nginx-module 

make CFLAGS="-Wno-error=format-truncation"
make CFLAGS="-Wno-error=format-truncation" install


cd $IRON_FOX_ROOT
echo "copy files..."
cp -vv html/* $SETUP_PATH/html/
cp -vv manager/panel.jar $BIN_PATH
cp -vv manager/application.properties $BIN_PATH

cp -vv cert/* $SETUP_PATH/cert/
sudo chmod +x -R $SETUP_PATH/html/*

echo "service configuration..."
sudo cp -vv manager/innovera.service /etc/systemd/system/innovera.service
sudo cp -vv manager/runservice.sh $BIN_PATH
sudo chmod u+x $BIN_PATH/runservice.sh
# figure and start service
sudo systemctl daemon-reload
sudo systemctl enable innovera.service
sudo systemctl start innovera
echo "setup done."