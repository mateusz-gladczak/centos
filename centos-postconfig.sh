#!/bin/bash
#run with:
#sh -c "$(wget -O- https://raw.githubusercontent.com/mateusz-gladczak/centos/master/centos-postconfig.sh)"

echo ######################################
echo #  CENTOS 8 Post installation config #
echo ######################################

#Configure repos
sudo sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/CentOS-PowerTools.repo
sudo bash -c 'echo baseurl =  http://mirror.centos.org/centos-8/8/AppStream/x86_64/os/repodata/repomd.xml >> /etc/yum.repos.d/CentOS-AppStream.repo'
sudo yum -y install epel-release
sudo yum clean all
sudo dnf makecache

#perform basic installations
sudo yum -y update
sudo yum -y install util-linux-user zsh dnf-automatic git p7zip python3 python3-pip lynx htop nfs-utils chrony cockpit cockpit-storaged cockpit-pcp

#configure python
sudo ln -fs /usr/bin/python3 /usr/bin/python
sudo ln -fs /usr/bin/pip3 /usr/bin/pip

#configure autoupdates
sudo sed -i 's/apply_updates = no/apply_updates = yes/g' /etc/dnf/automatic.conf
sudo systemctl enable --now dnf-automatic.timer

#configure ssh
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
mkdir ~/.ssh
touch ~/.ssh/authorized_keys
echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDLBfDPMab8T41TEJXeoB9BlId+RL56cyK5V3P7vmYFVF6IX/ZfViek0V6og9srwYOhWg/t7T7Aiu/qMwz8pDchui/xHZsB0aBiiZc1fjmzUIs8WOFFGVSVj4/Xv900vSmRwvbbI6kLyrbW20RSJdNK8/CqNn+zSL/KUYKEeq6WHW7n3rMcNSWna9LityR8GUcu481e4CEMhB6jtDR9Q9idZ1Em1zSTCwt5dMg5M9JpHsVfGRFbCfB9GIvxdzcg+mljSWW9iraDIyAXAv6uc4ouxkdla11IRWRA+VhB10TUB+PbOYRbqbxJTO2nowDjJYpfZsYGz95QzERxNbbF2Dg4FcFhziWO48N58OwVMQXSNez7V0ja0vIIqZoHsZ41J/eRf1WDYd3BeB2PDA/8i8mYZ+ftCIL+AoWJSlLDnlVzAG/hAt20mfeR+u++mnmaOPHls6GXhvZpoDfmmhN0vVPt2/b92QwHmGfdKeDD8kEuA94vccm9zNJ5ucwzSWrmy68= 69:21:93:c4:df:f5:46:aa:42:fb:b4:68:d7:0a:5f:cf >> ~/.ssh/authorized_keys
chmod 700 -R .ssh
sudo systemctl restart sshd.service

#configure zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' ~/.zshrc
echo bindkey  "^[[H"   beginning-of-line >> ~/.zshrc
echo bindkey  "^[[F"   end-of-line >> ~/.zshrc

#configure datetime
sudo mv /etc/localtime /etc/localtime.backup
sudo ln -s /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
sudo mv /etc/chrony.conf /etc/chrony.conf.bak

sudo bash -c 'cat >> /etc/chrony.conf <<EOL
pool pool.ntp.org iburst
driftfile /var/lib/chrony/drift
makestep 1 3
rtcsync
EOL'

sudo systemctl enable chronyd
sudo systemctl start chronyd

#disable selinux
#sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

#configure sudoers
echo $LOGNAME | xargs -I user sudo bash -c 'echo "user  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'

#enable cockpit
sudo systemctl enable --now cockpit.socket

echo 
echo Configuration completed... rebooting
sleep 5
sudo reboot


