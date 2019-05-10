#!/bin/sh -eux

major_version="`sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}'`";

#Install puppet repo
case "$major_version" in
    6)
    yum -y localinstall http://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm
    ;;
    7)
    yum -y localinstall http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
    ;;
esac

#Install puppet-agent
yum install -y puppet-agent

#Remove repo
yum remove -y puppetlabs-release-pc1