#!/bin/bash
#
# This provisioning script has been derived from vagrant-up-github-pages, which was derived from Varying Vagrant Vagrants:
# https://github.com/kappataumu/vagrant-up-github-pages
# https://github.com/Varying-Vagrant-Vagrants/VVV
#
# It is meant to be a starting point and not a complete development environment.
# You should modify this file to suit your needs.
# 
# Check out the main project page for more resources on how to use Vagrant
# https://github.com/petarmihaylov/vagrant-up-base

CLONEREPO='XXX'
CLONEDIR="~/$(basename $CLONEREPO)"

start_seconds="$(date +%s)"
echo "Welcome to the initialization script."

ping_result="$(ping -c 2 8.8.4.4 2>&1)"
if [[ $ping_result != *bytes?from* ]]; then
	echo "Network connection unavailable. Try again later."
    exit 1
fi

# List of packages to install
apt_package_check_list=(
    vim
    curl
    git-core
    nodejs
)

# Loop through each of our packages that should be installed on the system. If
# not yet installed, it should be added to the array of packages to install.
apt_package_install_list=()
for pkg in "${apt_package_check_list[@]}"; do
	package_version="$(dpkg -s $pkg 2>&1 | grep 'Version:' | cut -d " " -f 2)"
	if [[ -n "${package_version}" ]]; then
		space_count="$(expr 20 - "${#pkg}")" #11
		pack_space_count="$(expr 30 - "${#package_version}")"
		real_space="$(expr ${space_count} + ${pack_space_count} + ${#package_version})"
		printf " * $pkg %${real_space}.${#package_version}s ${package_version}\n"
	else
		echo " *" $pkg [not installed]
		apt_package_install_list+=($pkg)
	fi
done


# If there are any packages to be installed in the apt_package_list array,
# then we'll run `apt-get update` and then `apt-get install` to proceed.
if [[ ${#apt_package_install_list[@]} = 0 ]]; then
    echo -e "No apt packages to install.\n"
else
    # Add anything that might beed to run before the packages in your List of Packages to install (above)

    # Provides add-apt-repository (including for Ubuntu 12.10)
    sudo apt-get update --assume-yes > /dev/null
    sudo apt-get install --assume-yes python-software-properties
    sudo apt-get install --assume-yes software-properties-common

    sudo add-apt-repository -y ppa:git-core/ppa

    # Needed for nodejs.
    wget -q -O - https://deb.nodesource.com/setup | sudo bash -

    sudo apt-get update --assume-yes > /dev/null

    # install required packages
    echo "Installing apt-get packages..."
    sudo apt-get install --assume-yes ${apt_package_install_list[@]}
    sudo apt-get clean
fi

# http://rvm.io/rvm/install
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable --ruby
source ~/.rvm/scripts/rvm

# https://github.com/github/pages-gem
gem install github-pages

# Preemptively accept Github's SSH fingerprint, but only
# if we previously haven't done so.
fingerprint="$(ssh-keyscan -H github.com)"
if ! grep -qs "$fingerprint" ~/.ssh/known_hosts; then
    echo "$fingerprint" >> ~/.ssh/known_hosts
fi

# Vagrant should've created /srv/www according to the Vagrantfile,
# but let's make sure it exists even if run directly.
if [[ ! -d '/srv/www' ]]; then
    sudo mkdir '/srv/www'
fi

# Our favorite user group for web stuff. These commands are idempotent.
#sudo chgrp www-data /srv/www
#sudo chmod g+rws /srv/www

# Time to pull the repo. If the directory is there, we do nothing,
# since git should be used to push/pull commits instead.
if [[ ! -d "$CLONEDIR" ]]; then
    git clone "$CLONEREPO" "$CLONEDIR"
fi

# Now, for the Jekyll part
jekyll serve --source "$CLONEDIR" --detach

end_seconds="$(date +%s)"
echo "-----------------------------"
echo "Provisioning complete in "$(expr $end_seconds - $start_seconds)" seconds"
