#!/bin/bash

#===============================================================>
#=====>		NAME:		auto_install_netbox.sh
#=====>		VERSION:	1.0
#=====>		DESCRIPTION:	Auto Instalação Netbox
#=====>		CREATE DATE:	03/01/2023
#=====>		WRITTEN BY:	Ivan da Silva Bispo Junior
#=====>		E-MAIL:		contato@ivanjr.eti.br
#=====>		DISTRO:		Debian GNU/Linux 11 (Bullseye)
#===============================================================>

apt update && apt upgrade -y

apt install sudo -y

sed -i "s/deb http://deb.debian.org/debian/ bullseye main/deb http://deb.debian.org/debian/ bullseye main contrib non-free/" /etc/apt/sources.list
sed -i "s/deb-src http://deb.debian.org/debian/ bullseye main/deb-src http://deb.debian.org/debian/ bullseye main contrib non-free/" /etc/apt/sources.list
sed -i "s/deb http://security.debian.org/debian-security bullseye-security main/deb http://security.debian.org/debian-security bullseye-security main contrib non-free/" /etc/apt/sources.list
sed -i "s/deb-src http://security.debian.org/debian-security bullseye-security main/deb-src http://security.debian.org/debian-security bullseye-security main contrib non-free/" /etc/apt/sources.list
sed -i "s/deb http://deb.debian.org/debian/ bullseye-updates main/deb http://deb.debian.org/debian/ bullseye-updates main contrib non-free/" /etc/apt/sources.list
sed -i "s/deb-src http://deb.debian.org/debian/ bullseye-updates main/deb-src http://deb.debian.org/debian/ bullseye-updates main contrib non-free/" /etc/apt/sources.list

apt update && apt upgrade -y

apt install firmware-linux firmware-linux-free firmware-linux-nonfree -y

clear

echo reboot o sistema e rode o script novamente, caso já tenha reiniciado o sistema, espere que o scrip continue automaticamente de onde parou.

sleep 15

apt install curl gnupg2 wget -y

curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt install nodejs -y

npm install -g npm@8.1.2

cd /tmp
echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/5.0 main" | tee /etc/apt/sources.list.d/mongodb-org-5.0.list
curl -sSL https://www.mongodb.org/static/pgp/server-5.0.asc  -o mongoserver.asc
gpg --no-default-keyring --keyring ./mongo_key_temp.gpg --import ./mongoserver.asc
gpg --no-default-keyring --keyring ./mongo_key_temp.gpg --export > ./mongoserver_key.gpg
mv mongoserver_key.gpg /etc/apt/trusted.gpg.d/

apt update
apt install mongodb-org node-mongodb -y

systemctl enable mongod
systemctl start mongod

npm install -g genieacs

useradd --system --no-create-home --user-group genieacs

mkdir /opt/genieacs
mkdir /opt/genieacs/ext

cat << EOF > /opt/genieacs/genieacs.env
GENIEACS_CWMP_ACCESS_LOG_FILE=/var/log/genieacs/genieacs-cwmp-access.log
GENIEACS_NBI_ACCESS_LOG_FILE=/var/log/genieacs/genieacs-nbi-access.log
GENIEACS_FS_ACCESS_LOG_FILE=/var/log/genieacs/genieacs-fs-access.log
GENIEACS_UI_ACCESS_LOG_FILE=/var/log/genieacs/genieacs-ui-access.log
GENIEACS_DEBUG_FILE=/var/log/genieacs/genieacs-debug.yaml
NODE_OPTIONS=--enable-source-maps
GENIEACS_EXT_DIR=/opt/genieacs/ext
GENIEACS_UI_JWT_SECRET=secret
EOF

chown genieacs. /opt/genieacs -R
chmod 600 /opt/genieacs/genieacs.env

mkdir /var/log/genieacs
chown genieacs. /var/log/genieacs

systemctl edit --force --full genieacs-cwmp

cat << EOF > /etc/systemd/system/genieacs-cwmp.service
[Unit]
Description=GenieACS CWMP
After=network.target
 
[Service]
User=genieacs
EnvironmentFile=/opt/genieacs/genieacs.env
ExecStart=/usr/bin/genieacs-cwmp
 
[Install]
WantedBy=default.target
EOF

cat << EOF > /etc/systemd/system/genieacs-nbi.service
[Unit]
Description=GenieACS NBI
After=network.target
 
[Service]
User=genieacs
EnvironmentFile=/opt/genieacs/genieacs.env
ExecStart=/usr/bin/genieacs-nbi
 
[Install]
WantedBy=default.target
EOF

cat << EOF > /etc/systemd/system/genieacs-fs.service
[Unit]
Description=GenieACS FS
After=network.target
 
[Service]
User=genieacs
EnvironmentFile=/opt/genieacs/genieacs.env
ExecStart=/usr/bin/genieacs-fs
 
[Install]
WantedBy=default.target
EOF

cat << EOF > /etc/systemd/system/genieacs-ui.service
[Unit]
Description=GenieACS UI
After=network.target
 
[Service]
User=genieacs
EnvironmentFile=/opt/genieacs/genieacs.env
ExecStart=/usr/bin/genieacs-ui
 
[Install]
WantedBy=default.target
EOF

cat << EOF > /etc/logrotate.d/genieacs
/var/log/genieacs/*.log /var/log/genieacs/*.yaml {
    daily
    rotate 30
    compress
    delaycompress
    dateext
}
EOF

systemctl enable genieacs-cwmp genieacs-nbi genieacs-fs genieacs-ui
systemctl start genieacs-cwmp genieacs-nbi genieacs-fs genieacs-ui

sudo apt install bash-completion fzf grc -y

clear

=========
echo '' >> /etc/bash.bashrc
echo '# Autocompletar extra' >> /etc/bash.bashrc
echo 'if ! shopt -oq posix; then' >> /etc/bash.bashrc
echo '  if [ -f /usr/share/bash-completion/bash_completion ]; then' >> /etc/bash.bashrc
echo '    . /usr/share/bash-completion/bash_completion' >> /etc/bash.bashrc
echo '  elif [ -f /etc/bash_completion ]; then' >> /etc/bash.bashrc
echo '    . /etc/bash_completion' >> /etc/bash.bashrc
echo '  fi' >> /etc/bash.bashrc
echo 'fi' >> /etc/bash.bashrc
sed -i 's/"syntax on/syntax on/' /etc/vim/vimrc
sed -i 's/"set background=dark/set background=dark/' /etc/vim/vimrc
cat <<EOF >/root/.vimrc
set showmatch " Mostrar colchetes correspondentes
set ts=4 " Ajuste tab
set sts=4 " Ajuste tab
set sw=4 " Ajuste tab
set autoindent " Ajuste tab
set smartindent " Ajuste tab
set smarttab " Ajuste tab
set expandtab " Ajuste tab
"set number " Mostra numero da linhas
EOF
sed -i "s/# export LS_OPTIONS='--color=auto'/export LS_OPTIONS='--color=auto'/" /root/.bashrc
sed -i 's/# eval "`dircolors`"/eval "`dircolors`"/' /root/.bashrc
sed -i "s/# export LS_OPTIONS='--color=auto'/export LS_OPTIONS='--color=auto'/" /root/.bashrc
sed -i 's/# eval "`dircolors`"/eval "`dircolors`"/' /root/.bashrc
sed -i "s/# alias ls='ls \$LS_OPTIONS'/alias ls='ls \$LS_OPTIONS'/" /root/.bashrc
sed -i "s/# alias ll='ls \$LS_OPTIONS -l'/alias ll='ls \$LS_OPTIONS -l'/" /root/.bashrc
sed -i "s/# alias l='ls \$LS_OPTIONS -lA'/alias l='ls \$LS_OPTIONS -lha'/" /root/.bashrc
echo '# Para usar o fzf use: CTRL+R' >> ~/.bashrc
echo 'source /usr/share/doc/fzf/examples/key-bindings.bash' >> ~/.bashrc
echo "alias grep='grep --color'" >> /root/.bashrc
echo "alias egrep='egrep --color'" >> /root/.bashrc
echo "alias ip='ip -c'" >> /root/.bashrc
echo "alias diff='diff --color'" >> /root/.bashrc
echo "alias tail='grc tail'" >> /root/.bashrc
echo "alias ping='grc ping'" >> /root/.bashrc
echo "alias ps='grc ps'" >> /root/.bashrc
echo "PS1='\${debian_chroot:+(\$debian_chroot)}\[\033[01;31m\]\u\[\033[01;34m\]@\[\033[01;33m\]\h\[\033[01;34m\][\[\033[00m\]\[\033[01;37m\]\w\[\033[01;34m\]]\[\033[01;31m\]\\$\[\033[00m\] '" >> /root/.bashrc
echo "echo;echo 'SXZhbiBKciAtIENvbnN1bHRvcmlhIGVtIFRJQy4NCg0KV2Vic2l0ZSAuLi4uLi4uLi4uLjogaXZhbmpyLmV0aS5icg0KQ29udGF0byAuLi4uLi4uLi4uLi46IGNvbnRhdG9AaXZhbmpyLmV0aS5icg=='|base64 --decode; echo;" >> /root/.bashrc
=========
cat << EOF > /etc/issue
- Hostname do sistema ............: \n
- Data do sistema ................: \d
- Hora do sistema ................: \t
- IPv4 address ...................: \4
- Acess Web ......................: http://\4:3000
- Contato ........................: contato@ivanjr.eti.br
- Ivan Jr - Consultoria em TIC.

EOF
clear

IPVAR=`ip addr show | grep global | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' | sed -n '1p'
`
echo http://$IPVAR:3000

