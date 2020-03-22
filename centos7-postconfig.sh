#!/bin/bash
#run with:
#sh -c "$(wget -O- https://raw.githubusercontent.com/mateusz-gladczak/centos/master/centos7-postconfig.sh)"

sudo yum -y install epel-release
sudo yum clean all
sudo dnf makecache

sudo yum install -y util-linux-user dnf-automatic git p7zip python3 python3-pip lynx htop nfs-utils cockpit cockpit-storaged cockpit-pcp realmd


#perform basic installations
sudo yum -y update

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

echo $LOGNAME | xargs -I user sudo bash -c 'echo "user  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'

​sudo firewall-cmd --add-service=cockpit --permanent
​sudo firewall-cmd --reload
