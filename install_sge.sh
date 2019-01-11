#!/bin/bash
set -e

add_operator() {
	SGE_ROOT=/opt/sge /opt/sge/bin/lx-amd64/qconf -ao "$1"
}

export -f add_operator

yum install -y yum-plugin-copr
yum copr enable -y loveshack/SGE

# head
yum install -y gridengine gridengine-qmaster gridengine-qmon gridengine-execd expect
(
	cd "/opt/sge" || exit 1
	/vagrant/expect_files/run_install_qmaster.exp
	SGE_ROOT=/opt/sge /vagrant/expect_files/run_install_execd.exp
)

add_operator "vagrant"
add_operator "ood"

echo 'gridengine ready'