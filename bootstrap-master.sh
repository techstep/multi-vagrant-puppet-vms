#!/bin/sh

# Run on VM to bootstrap Puppet Master server

if ps aux | grep "puppet master" | grep -v grep 2> /dev/null
then
    echo "Puppet Master is already installed. Exiting..."
else
    PUPPET_URL="https://yum.puppetlabs.com/el/6/products/x86_64"
    # Install Puppet Master
    sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm && \
    sudo yum -y install puppet-3.7.5 && \
    sudo yum -y install puppetserver

    # Configure /etc/hosts file
    echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "# Host config for Puppet Master and Agent Nodes" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.5    puppet.example.com  puppet" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.10   node01.example.com  node01" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.20   node02.example.com  node02" | sudo tee --append /etc/hosts 2> /dev/null

    # Add optional alternate DNS names to /etc/puppet/puppet.conf
    sudo sed -i 's/.*\[main\].*/&\ndns_alt_names = puppet,puppet.example.com/' /etc/puppet/puppet.conf

    # Install some initial puppet modules on Puppet Master server
    sudo puppet module install puppetlabs-ntp
    sudo puppet module install garethr-docker
    sudo puppet module install puppetlabs-git
    sudo puppet module install puppetlabs-vcsrepo
    sudo puppet module install garystafford-fig

    # symlink manifest from Vagrant synced folder location
    ln -s /vagrant/site.pp /etc/puppet/manifests/site.pp
fi
