#!/bin/sh

set -e
set -u

HOSTNAME="$(hostname)"

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    git \
    curl \
    wget \
    make \
    vim \
    gnupg2 \
    python3 \
    software-properties-common

if [ "$HOSTNAME" = "node0" ]; then
	apt-get install -y \
		ansible

	# J'ajoute les deux clefs sur le noeud de server0e
	mkdir -p /root/.ssh
	cp /vagrant/ansible_rsa /home/vagrant/.ssh/ansible_rsa
	cp /vagrant/ansible_rsa.pub /home/vagrant/.ssh/ansible_rsa.pub
	chmod 0600 /home/vagrant/.ssh/*_rsa # ICI
	chown -R vagrant:vagrant /home/vagrant/.ssh

	sed -i \
		-e '/## BEGIN PROVISION/,/## END PROVISION/d' \
		/home/vagrant/.bashrc
	cat >> /home/vagrant/.bashrc <<-MARK
	## BEGIN PROVISION
	eval \$(ssh-agent -s)
	ssh-add ~/.ssh/ansible_rsa
	## END PROVISION
	MARK
fi

sed -i \
	-e '/^## BEGIN PROVISION/,/^## END PROVISION/d' \
	/etc/hosts
cat >> /etc/hosts <<MARK
## BEGIN PROVISION
192.168.50.250     node0
192.168.50.10      s0.infra
192.168.50.10      s1.infra
192.168.50.10      s2.infra
192.168.50.10      s3.infra
192.168.50.10      s4.infra
### END PROVISION
MARK


# J'autorise la clef sur tous les serveurs
mkdir -p /root/.ssh
cat /vagrant/ansible_rsa.pub >> /root/.ssh/authorized_keys

# Je vire les duplicata (potentiellement gênant pour SSH)
sort -u /root/.ssh/authorized_keys > /root/.ssh/authorized_keys.tmp
mv /root/.ssh/authorized_keys.tmp /root/.ssh/authorized_keys
# Je corrige les permissions
touch /root/.ssh/config
chmod 0600 /root/.ssh/*
chmod 0644 /root/.ssh/config
chmod 0700 /root/.ssh
#
# Configurer dhcp
if [ "$HOSTNAME" = "s0.infra" ]
then
    cat > /etc/resolv.conf <<-MARK
    nameserver 192.168.50.10/24
    nameserver 1.1.1.1
    MARK
else
    cat > /etc/resolv.conf <<-MARK
    nameserver 192.168.50.10
    MARK
fi

if [ "$PERFORM_DHCLIENT" = "true" ]
then
    echo "iface eth1 inet dhcp" > /etc/network/interfaces.d/eth1
    dhclient -v eth1
fi

echo "[SUCCESS] DHCP: $HOSTNAME."
