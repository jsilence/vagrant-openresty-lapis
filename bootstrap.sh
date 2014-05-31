#!/usr/bin/env bash


OPENRESTY=ngx_openresty-1.5.12.1
LUAROCKS=luarocks-2.1.2

if ! grep -Fxq 'Europe/Berlin' /etc/timezone
then
echo "Europe/Berlin" >/etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi


# General stuff that is needed. Feel free to omit emacs and to include your favourite editor.
#apt-get update
apt-get install -y libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl make unzip git emacs24-nox


# Database access with Postgresql needs to be installed before building openresty
sudo apt-get -y install postgresql postgresql-server-dev-all
sudo -u postgres createdb sample


# Lapis is based on OpenResty
cd /vagrant && wget -q http://openresty.org/download/${OPENRESTY}.tar.gz
tar xzf ${OPENRESTY}.tar.gz

cd ${OPENRESTY}
./configure --with-luajit --with-http_postgres_module --with-http_realip_module
make
sudo make install
ln -s /usr/local/openresty/luajit/bin/luajit-2.1.0-alpha /usr/local/openresty/luajit/bin/lua
cd ..


# luarocks rocks.
wget -q http://luarocks.org/releases/${LUAROCKS}.tar.gz
tar xfz ${LUAROCKS}.tar.gz
cd ${LUAROCKS}
./configure --prefix=/usr/local/openresty/luajit --with-lua=/usr/local/openresty/luajit --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1
make build
sudo make install

# tup is for building and for monitoring changes to the files
sudo apt-add-repository 'deb http://ppa.launchpad.net/anatol/tup/ubuntu precise main'
sudo apt-get update
sudo apt-get -y --force-yes install tup


sudo chgrp -R vagrant /usr/local/openresty/
sudo chmod -R g+wr /usr/local/openresty/

export PATH=/usr/local/openresty/luajit/bin/:$PATH
echo "export PATH=/usr/local/openresty/luajit/bin/:$PATH" >> /home/vagrant/.bashrc


# installing moonscript and lapis via luarocks
luarocks install moonscript
luarocks install lapis


# SCSS via pyScss without Ruby stack
sudo apt-get install -y python-dev python-setuptools
sudo easy_install pip
sudo pip install pyscss


# Coffeescript
# https://www.digitalocean.com/community/articles/how-to-install-node-js-on-an-ubuntu-14-04-server
sudo apt-get -y install nodejs npm
sudo npm install -g coffee-script


# Benchmark with httperf
sudo apt-get -y install httperf


rm -rf /var/www
ln -fs /vagrant/www /var/www
