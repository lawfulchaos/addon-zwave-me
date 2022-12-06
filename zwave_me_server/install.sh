#!/bin/bash

# Not to fail on old key we will not update package list from Z-Wave repo - this will be done later after key installation
rm -f /etc/apt/sources.list.d/z-wave-me.list

# Install additional packages that help to add Z-Wave.Me repository
apt update -y --allow-releaseinfo-change
apt install dirmngr apt-transport-https gnupg -y

# Check for distro
apt install lsb_release >/dev/null 2>&1 # built-in (no such package) starting from stretch
distro=$(lsb_release -a 2>/dev/null | grep Codename | awk '{print $2}')
if [ "${distro}" == "" -o "${distro}" == "n/a" ]
then
	distro=$(cat /etc/os-release | grep VERSION_CODENAME | awk -F"=" '{print $2}')
fi
distro_id=$(lsb_release -a 2>/dev/null | grep "Distributor ID" | awk '{print $3}' | tr '[:upper:]' '[:lower:]')
if [ "${distro_id}" == "" ]
then
	distro_id=$(cat /etc/os-release | grep -E "^ID=" | awk -F"=" '{print $2}')
fi

# Cancel installation if distribution is not supported
if [ "${distro}" != "buster" -a "${distro}" != "bullseye" -a "${distro}" != "focal" -a "${distro}" != "jammy" ];
then
	echo
	echo "Your Linux distribution is currently not supported by Z-Way"
	echo "Please contact Z-Wave.Me support for more information"
	echo "Supported Raspbian Buster and Bullseye"
	echo "Supported Debian Bullseye"
	echo "Supported Ubuntu 20.04 and 22.04"
	echo
	exit 1
fi

# Check architecture	
architecture=$(uname -m)

case "${architecture}" in
	armhf | armv7l)
		arch_tag=""
		arch_apt=""
		additional_packets="z-way-full${arch_apt} webif${arch_apt}"
		install_webif="ok"
		;;

	aarch64)
		arch_tag="[arch=armhf]"
		arch_apt=":armhf"
		install_webif="ok"
		additional_packets="z-way-full${arch_apt} webif${arch_apt}"
		# fix distro_id
		if [ "${distro_id}" == "debian" ];
		then
			distro_id="raspbian"
		fi
		;;

	x86_64)
		arch_tag="[arch=amd64]"
		arch_apt=""
		install_webif=""
		additional_packets=""
		;;
	*)
		echo
		echo "Your operating system architecture is not supported or unknown"
		echo "Please contact Z-Wave.Me support for more information"
		echo "Supported architectures: armhf, aarch64, x86_64"
		echo "Your architecture: ${architecture} and your distro is ${distro_id} ${distro}"
		echo
		exit 1
		;;
esac
minimal_packets="z-way-server${arch_apt} zbw${arch_apt}"

# Add Z-Wave.Me repository
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 5b2f88a91611e683
echo "deb ${arch_tag} https://repo.z-wave.me/z-way/${distro_id} ${distro} main" > /etc/apt/sources.list.d/z-wave-me.list

# Update packages list
apt update -y

# Install Z-Way
if [[ -z "$ZWAY_UPIF" ]];
then # don't update webif if running from webif
	apt install --reinstall -y ${minimal_packets} ${additional_packets}
else
	apt install --reinstall -y ${minimal_packets}
fi

# Override Z-Way/zbw/webif configs from the package (keep private files)
CONF_FILES=$(dpkg-query -W -f='${Conffiles}\n' z-way-server webif zbw | awk 'OFS="  "{print $2,$1}' | LANG=C md5sum --quiet -c 2>/dev/null | cut -f 1 -d :)
if [[ -n "$CONF_FILES" ]];
then
	echo "Package configuration files were changes:" $CONF_FILES

	RESTORE_CONFIG_FILE="yes"

	if [[ -z "$ZWAY_UPIF" ]];
	then
		read -p "Restore config files to the package default state? (type 'yes' to restore): " RESTORE_CONFIG_FILE < /dev/tty
	fi

	if [[ "$RESTORE_CONFIG_FILE" == "yes" ]];
	then

		echo "Replacing them by package configuration files"
		
		TMP_DIR=$(mktemp -d)
		chown _apt:root $TMP_DIR
		pushd $TMP_DIR
		
		apt download z-way-server${arch_apt}
		dpkg-deb --fsys-tarfile ./z-way-server*.deb | sudo tar -C / -x ./opt/z-way-server/config/Defaults.xml ./opt/z-way-server/config.xml ./etc/z-way/box_type ./etc/logrotate.d/z-way-server ./etc/init.d/z-way-server
		
		if [ "${install_webif}" != "" ];
		then
			apt download webif${arch_apt}
			dpkg-deb --fsys-tarfile ./webif*.deb | sudo tar -C / -x ./etc/webif.conf ./etc/mongoose/mongoose.conf
		fi

		#  no config files in zbw package
		# apt download zbw
		# dpkg-deb --fsys-tarfile ./zbw*.deb | sudo tar -C / -x ...
		
		popd
		rm -R $TMP_DIR
	else
		echo "Keeping your changed configuration files"
	fi
fi