#!/bin/bash

FITS="1.2.0"
RAILS="5.1.4"

if [ ! fits-$FITS.zip]; then
 echo "Add fits-$FITS.zip to the folder"
fi

########################
# Install dependencies #
########################
echo 'Installing all the things'
yes | sudo yum install -y git-core zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel bzip2 autoconf automake libtool bison curl sqlite-devel wget unzip
# Need make for installing the pg gem
yes | sudo yum install -y make


########
# Java #
########
# http://bhargavamin.com/how-to-do/setting-up-java-environment-variable-on-ec2/

yes | sudo yum install -y java-1.8.0-openjdk.x86_64
sudo update-alternatives --config java <<< '2'

# file $(which java)
# file /etc/alternatives/java
# file /usr/lib/jvm/java-8-openjdk.x86_64/bin/java

# add to ~/.bashrc
if ! grep -q "jre-1.8.0-openjdk.x86_64" "/home/ec2-user/.bashrc"; then
    echo 'JAVA_HOME="/usr/lib/jvm/jre-1.8.0-openjdk.x86_64"' >> /home/ec2-user/.bashrc
    echo 'PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
else
    echo 'Java location is already in bashrc'
fi

source ~/.bashrc


########
# EPEL #
########
yes | sudo yum install -y epel-release
# If the above doesn't work
if sudo yum repolist | grep epel; then
  echo 'EPEL is enabled'
else
  echo 'Adding the EPEL Repo'
  wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  rpm -Uvh epel-release-latest-7*.rpm
fi

#######################################
# Install LibreOffice and ImageMagick #
#######################################
echo 'Installing LibreOffice, ImageMagick and Redis'
yes | sudo yum install –y ImageMagick


if [ ! -d /opt/libreoffice6.0 ]
then
    mkdir tmp
    cd tmp
    yes | sudo yum install -y dbus-glib cairo cups
    wget https://mirrors.ukfast.co.uk/sites/documentfoundation.org/tdf/libreoffice/stable/6.0.4/rpm/x86_64/LibreOffice_6.0.4_Linux_x86-64_rpm.tar.gz
    tar -xvf LibreOffice_6.0.4_Linux_x86-64_rpm.tar.gz
    cd LibreOffice_6.0.4.2_Linux_x86-64_rpm/RPMS
    yes | sudo yum localinstall *.rpm # --skip-broken
    sudo ln -s /opt/libreoffice6.0/program/soffice /usr/bin/soffice
    cd ..
else
    echo 'Libreoffice is already installed, moving on ...'
fi

##################################
# Install Mediainfo (needs EPEL) #
##################################
# Mediainfo is needed for Fits; it requires the EPEL repo
# otherwise fits "Error loading native library for MediaInfo please check that fits_home is properly set"
echo 'Installing Mediainfo'
yes | sudo yum install -y libmediainfo libzen mediainfo

################
# Install Fits #
################
# See https://github.com/projecthydra-labs/hyrax#characterization
if [ ! -d /usr/local/fits ]
then
  # echo 'Downloading Fits '$FITS
  # because of problems with the download, we use a local copy of fits
  # wget http://projects.iq.harvard.edu/files/fits/files/fits-$FITS.zip
  sudo unzip fits-$FITS.zip
  sudo mv fits-$FITS/ /usr/local/fits
  sudo chmod a+x fits/fits.sh
  # do both shortcuts
  sudo ln -s /usr/local/fits/fits.sh /usr/bin/fits
  sudo ln -s /usr/local/fits/fits.sh /usr/bin/fits.sh
  sudo chmod -R 777 /usr/local/fits # TODO don't use 777!
else
  echo 'Fits is already here, moving on ... '
fi

##################
# Install nodejs #
##################
# Temporary workaround for http-parser issue: https://bugs.centos.org/view.php?id=13669&nbn=1
# or sudo yum--enablerepo=cr
echo 'Installing nodejs'
# rpm -ivh https://kojipkgs.fedoraproject.org//packages/http-parser/2.7.1/3.el7/x86_64/http-parser-2.7.1-3.el7.x86_64.rpm
yes | sudo yum install -y nodejs

##############################
# Install Redis (needs EPEL) #
##############################
# See https://support.rackspace.com/how-to/install-epel-and-additional-repositories-on-centos-and-red-hat/

yes | sudo sudo yum install -y redis

##################################
# Start Redis and enable at boot #
##################################

echo 'Starting Redis'
sudo service redis start
echo 'Enable Redis start at boot'
# https://geekflare.com/how-to-auto-start-services-on-boot-in-linux/
cd /etc/init.d
sudo chkconfig --add redis
sudo chkconfig redis on

####################
# Install postgres #
####################
# See https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-centos-7

yes | sudo yum install -y postgresql-server postgresql-contrib postgresql-devel

sudo service postgresql initdb
# Use MD5 Authentication
sudo sed -i -e 's/ident$/md5/' -e 's/peer$/md5/' /var/lib/pgsql9/data/pg_hba.conf
#start
sudo /sbin/chkconfig --levels 235 postgresql on
sudo service postgresql start

sudo psql -U postgres -d postgres -c "CREATE USER \"ec2-user\" WITH SUPERUSER;"

gem uninstall rails -v 5.2.0
gem install  rails -v $RAILS