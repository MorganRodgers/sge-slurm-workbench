#!/bin/bash
set -xe

add_worker () {
  QUEUE=$1
  HOSTNAME=$2
  SLOTS=$3

  # add to the execution host list
  TMPFILE=/tmp/sge.hostname-$HOSTNAME
  echo -e "hostname $HOSTNAME\nload_scaling NONE\ncomplex_values NONE\nuser_lists NONE\nxuser_lists NONE\nprojects NONE\nxprojects NONE\nusage_scaling NONE\nreport_variables NONE" > $TMPFILE
  sudo qconf -Ae $TMPFILE
  rm $TMPFILE

  # add to the all hosts list
  sudo qconf -aattr hostgroup hostlist $HOSTNAME @allhosts

  # enable the host for the queue, in case it was disabled and not removed
  sudo qmod -e $QUEUE@$HOSTNAME

  if [ "$SLOTS" ]; then
      qconf -aattr queue slots "[$HOSTNAME=$SLOTS]" $QUEUE
  fi
}

export -f add_worker

## ============ ##
## INSTALLATION ##
## ============ ##

sudo apt-get update

# Configure the master hostname for Grid Engine
echo "gridengine-master       shared/gridenginemaster string  $HOSTNAME" | sudo debconf-set-selections
echo "gridengine-master       shared/gridenginecell   string  default" | sudo debconf-set-selections
echo "gridengine-master       shared/gridengineconfig boolean false" | sudo debconf-set-selections
echo "gridengine-common       shared/gridenginemaster string  $HOSTNAME" | sudo debconf-set-selections
echo "gridengine-common       shared/gridenginecell   string  default" | sudo debconf-set-selections
echo "gridengine-common       shared/gridengineconfig boolean false" | sudo debconf-set-selections
echo "gridengine-client       shared/gridenginemaster string  $HOSTNAME" | sudo debconf-set-selections
echo "gridengine-client       shared/gridenginecell   string  default" | sudo debconf-set-selections
echo "gridengine-client       shared/gridengineconfig boolean false" | sudo debconf-set-selections
# Postfix mail server is also installed as a dependency
echo "postfix postfix/main_mailer_type        select  No configuration" | sudo debconf-set-selections

# Install Grid Engine
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y gridengine-master gridengine-client ruby

# Set up Grid Engine
sudo -u sgeadmin /usr/share/gridengine/scripts/init_cluster /var/lib/gridengine default /var/spool/gridengine/spooldb sgeadmin
sudo service gridengine-master restart

# Disable Postfix
sudo service postfix stop
sudo update-rc.d postfix disable

sleep 3

## ============= ##
## CONFIGURATION ##
## ============= ##

# Give $USER manager/operator rights
sudo qconf -am vagrant
sudo qconf -ao vagrant

sudo qconf -Msconf /vagrant_data/scheduler.conf
sudo qconf -Ahgrp /vagrant_data/hostlist.conf
sudo qconf -Aq /vagrant_data/queue.conf

sudo service gridengine-master restart

sleep 3

# Enable $HOSTNAME as a submit host
sudo qconf -as $HOSTNAME
sudo qconf -ah $HOSTNAME

add_worker general.q worker 1

## INSTALL CONVENIENCE DEV STUFF ##
sudo apt-get install -y ruby git

sudo apt-get install software-properties-common
sudo apt-add-repository -y ppa:rael-gc/rvm
sudo apt-get update
sudo apt-get install rvm -y
sudo usermod -a -G rvm vagrant
rvm install 2.4

# Remove the bloat
sudo apt-get autoremove -y