#version=RHEL8
ignoredisk --only-use=sda
autopart --type=lvm
# Partition clearing information
clearpart --none --initlabel
# Use text install and not graphical
text
# Use CDROM installation media
cdrom
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=static --device=ens3 --gateway=192.168.100.1 --ip=192.168.100.253 --nameserver=192.168.100.254 --netmask=255.255.255.0 --ipv6=auto --activate
network  --hostname=workstation.lab.example.com
repo --name="AppStream" --baseurl=file:///run/install/repo/AppStream
# Root password redhat
# python -c 'import crypt,getpass;pw=getpass.getpass();print(crypt.crypt(pw) if (pw==getpass.getpass("Confirm: ")) else exit())'
rootpw --iscrypted $6$LwMuSOzhl/mBzGx.$4vco9HD/QpJfbkYi33HU8Kg0gi0McxTHe0RPt1pRTMNh/k5MjNBNuXf.ZgGO5qsG5ZAJPXTfwtYJDk2JNHhpC/

# Do not run the Setup Agent on first boot
firstboot --disable
# Configure the X Window System
xconfig --startxonboot
# System services
services --disabled="chronyd"
# System timezone
timezone Europe/Amsterdam --isUtc --nontp
# Student password student
user --groups=wheel --name=student --password=$6$SLIfZs.v77RUQvQv$muLteoaXizPSZVE4hVZyRtty2CDuvLU/z7all2D2AdP4BV4KBRCxtz4/lU10jWqZpq4soAO9d2Jmt3at2JPdS. --iscrypted --gecos="student"
reboot

%packages
@^graphical-server-environment
wget
git
bind-utils
vim
tar
bash-completion
tmux

%end

%addon com_redhat_kdump --disable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end
