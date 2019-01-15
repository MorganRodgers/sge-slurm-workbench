#!/bin/bash
set -x

add_operator() {
  SGE_ROOT=/opt/sge /opt/sge/bin/lx-amd64/qconf -ao "$1"
}

export -f add_operator

yum install -y yum-plugin-copr
yum copr enable -y loveshack/SGE
yum install -y gridengine gridengine-qmaster gridengine-qmon gridengine-execd

(
  cd "/opt/sge" || exit 1
  /opt/sge/install_qmaster -munge -auto /vagrant/sge.conf
  /opt/sge/install_execd -munge -auto /vagrant/sge.conf
)

add_operator "vagrant"
add_operator "ood"

echo 'gridengine ready'