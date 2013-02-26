#Rollout Installation and Basic Configuration Instructions

# Server Installation
##Required Information

  ```bash
BASEDIR=</base/directoy/for/rolloutd/>
USER=<username_rolloutd_will_run_as>
GROUP=<groupname_rolloutd_will_run_as>
ROLLOUT_SERVER=<resolvable hostname | ip address>
ROLLOUT_PORT=<some port number>
  ```

1.  You'll need the following perl modules

  <pre>
Net::Netmask
IO::Socket::SSL
Error
LWP
  </pre>

1.  Get rollout source, and extract

  ```bash
ROLLOUT_TMP_DIR='/tmp/rollout'
cd /tmp
  ```
  * Using wget

    ```bash
wget http://github.com/dparrish/rollout/archive/master.tar.gz
tar xzf master.tar.gz
mv rollout-master rollout
    ```
  * Using git

    ```bash
git clone https://github.com/dparrish/rollout.git
    ```


1.  After extraction, run the following commands as root

  ```bash
BASEDIR=/usr/local/rollout
USER=nobody
GROUP=group
ROLLOUT_TMP_DIR="/tmp/rollout"
groupadd $GROUP
useradd -g $GROUP $USER
cp -i $ROLLOUT_TMP_DIR/rolloutd /usr/local/sbin/rolloutd
cp -i $ROLLOUT_TMP_DIR/rollout.init /etc/init.d/rollout
cp -i $ROLLOUT_TMP_DIR/rollout.default /etc/default/rollout
mkdir -p $BASEDIR
mkdir -p $BASEDIR/fragments
cp -ir $ROLLOUT_TMP_DIR/steps $BASEDIR/
cp -i $ROLLOUT_TMP_DIR/RolloutConfigValidator.pm $BASEDIR/
cp -i $ROLLOUT_TMP_DIR/rollout $BASEDIR/
chmod 750 /usr/local/sbin/rolloutd
chmod 755 /etc/init.d/rollout
chmod 600 /etc/default/rollout
chown -R $USER:$GROUP $BASEDIR
  ```

1.  Edit /etc/default/rollout to configure your server

1.  Add required symlinks to /etc/rc?.d/S??rollout to /etc/init.d/rollout

  ```bash
ln -s /etc/init.d/rollout /etc/rc1.d/K20rollout
ln -s /etc/init.d/rollout /etc/rc3.d/S70rollout
ln -s /etc/init.d/rollout /etc/rc2.d/S70rollout
  ```

1.  Copy the default configuration (rollout.cfg) or your own configuration into
$BASEDIR.

1.  Decide which webserver to use.

  + Use rolloutd

  1.  Start rolloutd

  ```bash
/etc/init.d/rollout start
  ```

  + Use Apache2

  1.  Edit the Apache2 default configuration file

  **/etc/apache2/sites-enabled/000-default**

  ```apache
Alias /rollout /usr/local/rollout
<Directory /usr/local/rollout>
  Options Indexes FollowSymlinks
  AllowOverride None
  Order allow,deny
  allow from all
</Directory>
  ```

  1.  Restart Apache2

  ```bash
/etc/init.d/apache2 restart
  ```


# Client Installation

1. Install required perl modules

  ```bash
apt-get -y install libapache2-mod-php5 libio-socket-ssl-perl liberror-perl libwww-perl
  ```

1. Install rollout on a client

  ```bash
URL=http://$ROLLOUT_SERVER:$ROLLOUT_PORT
wget -O- $URL/rollout | perl - -u $URL -o setup
  ```


# Example Server Installation and setup
The following example is the initial setup and configuration on
a new installation of Ubuntu Server 12.10 32bit

##Server details
* Hostname - **server**
* OS - **Linux**
* Distribution - **Ubuntu Server 12.10**
* Architecture - **i386**
* IP Addresses - **10.9.8.1**
* Web Server - **Apache2 w/ PHP5**

I needed to have Apache2 installed for other reasons on this server, and have
little control over the firewall, so Apache2 was chosen instead of the
provided rolloutd which would be required to run an additional network port.

##Install and Configure
1.  Run the following commands

  ```bash
ROLLOUT_TMP_DIR="/tmp/rollout"
BASEDIR="/app/rollout"
ROLLOUT_SERVER="10.9.8.1"
ROLLOUT_PORT="80"
GROUP="rollout"
USER="rollout"
mkdir -p $BASEDIR
groupadd $GROUP
useradd -g $GROUP $USER
cd /tmp
wget http://github.com/dparrish/rollout/archive/master.tar.gz
tar xzf master.tar.gz
mv rollout-master $ROLLOUT_TMP_DIR
cp -i $ROLLOUT_TMP_DIR/rolloutd /usr/local/sbin/rolloutd
cp -i $ROLLOUT_TMP_DIR/rollout.init /etc/init.d/rollout
cp -i $ROLLOUT_TMP_DIR/rollout.default /etc/default/rollout
mkdir -p $BASEDIR
mkdir -p $BASEDIR/fragments
cp -ir $ROLLOUT_TMP_DIR/steps/ $BASEDIR/
cp -i $ROLLOUT_TMP_DIR/RolloutConfigValidator.pm $BASEDIR/
cp -i $ROLLOUT_TMP_DIR/rollout $BASEDIR/
ln -sf /app/rollout/rollout /usr/local/sbin
chmod 750 /usr/local/sbin/rolloutd
chmod 755 /etc/init.d/rollout
chmod 600 /etc/default/rollout
chown -R $USER:$GROUP $BASEDIR
apt-get update
apt-get -y install libapache2-mod-php5 liberror-perl libwww-perl
  ```

1.  Edit the default Apache2 configuration

  ```bash
vim /etc/apache2/sites-enabled/000-default
  ```

  **/etc/apache2/sites-enabled/000-default**

  ```apache
Alias /rollout /app/rollout
<Directory /app/rollout>
  Options Indexes FollowSymlinks
  AllowOverride None
  Order allow,deny
  allow from all
</Directory>
  ```

1.  Restart Apache2

  ```bash
/etc/init.d/apache2 restart  
  ```


# Example Client Installation
The following example is the initial setup on a new installation of a client.

##Client details
* OS - Linux 
* Distribution - Ubuntu Server 12.04.1 LTS
* Architecture - i386
* hostname - client
* IP Address - 10.9.8.254

1.  Create a new file for the client on the rollout server

  We want a directory hiearchy for our clients so we can better manage them.

  ```bash
mkdir -p $BASEDIR/fragments/clients/internal/testing/client
  ```

1.  Edit **rollout.cfg** on the rollout server

  ```bash
vim $BASEDIR/rollout.cfg
  ```

  **$BASEDIR/rollout.cfg**

  ```perl
#!/usr/bin/perl -w
# vim:tw=100 sw=2 expandtab ft=perl foldmethod=marker
class SOE_Ubuntu => { # {{{
  nameservers => ['10.9.8.1],
  domain_name => "chrisdonovan.com.au,
  rollout => {
    logfile => "/var/log/rollout.log",
  },
  service => {
    ssh => 1,
    ntp => 1,
  },
  crontab => {
    rollout_check => [
      '0 0 * * * root rollout -s --no_step_labels -k motd',
    ],
  },
  apt => {
    repos => [
      'deb http://10.9.8.1/ubuntu/non-prod/mirror/archive.ubuntu.com/ubuntu/ precise main',
      'deb http://10.9.8.1/ubuntu/non-prod/mirror/archive.ubuntu.com/ubuntu/ precise-updates main',
      'deb http://10.9.8.1/ubuntu/security/mirror/archive.ubuntu.com/ubuntu/ precise-security main',
      'deb http://10.9.8.1/ubuntu/non-prod/mirror/archive.ubuntu.com/ubuntu/ precise universe',
      'deb http://10.9.8.1/ubuntu/non-prod/mirror/archive.ubuntu.com/ubuntu/ precise-updates universe',
      'deb http://10.9.8.1/ubuntu/security/mirror/archive.ubuntu.com/ubuntu/ precise-security universe',
      'deb http://10.9.8.1/ubuntu/non-prod/mirror/archive.ubuntu.com/ubuntu/ precise multiverse',
      'deb http://10.9.8.1/ubuntu/non-prod/mirror/archive.ubuntu.com/ubuntu/ precise-updates multiverse',
      'deb http://10.9.8.1/ubuntu/security/mirror/archive.ubuntu.com/ubuntu/ precise-security multiverse',
      'deb http://10.9.8.1/ubuntu/non-prod/mirror/archive.ubuntu.com/ubuntu/ precise restricted',
      'deb http://10.9.8.1/ubuntu/non-prod/mirror/archive.ubuntu.com/ubuntu/ precise-updates restricted',
      'deb http://10.9.8.1/ubuntu/non-prod/mirror/archive.ubuntu.com/ubuntu/ precise-security restricted',
    ],
    always_check => 0,
    auto_upgrade => 1,
  },
  packages => [
    'rcs',
    'gpm',
    'vlan',
    'ntp',
    'unzip',
    'vim-nox',
    'postfix',
    'sysstat',
    'snmpd',
    'mailutils',
    'openssh-server',
  ],
  packages_remove => [
    'resolvconf',
    'apparmor',
    'autofs5',
    'mpt-status',
  ],
  sysctl => {
    'kernel.sysrq' => 1,
    'net.ipv4.conf.all.secure_redirects' => 1,
    'kernel.randomize_va_space' => 1,
    'net.ipv6.conf.all.disable_ipv6' => 1,
    'net.ipv4.ip_forward' => 0,
    'net.ipv4.conf.default.rp_filter' => 2,
    'net.ipv4.conf.default.accept_source_route' => 0,
    'kernel.core_uses_pid' => 1,
    'net.ipv4.tcp_syncookies' => 1,
    'kernel.msgmnb' => 65536,
    'kernel.msgmax' => 65536,
  },
  file_append => [
    {
      file => "/etc/aliases",
      add => 'root: alienresidents\@gmail.com',
      match => qr/^root/,
      cmd => "/usr/bin/newaliases",
    },
    {
      file => "/etc/apt/apt.conf",
      add => 'Dpkg::Options { "--force-confdef"; "--force-confold"; }',
      match => qr/^Dpkg::Options /,
      create => 1,
    },
    {
      file => "/etc/apt/apt.conf",
      add => "APT::Architectures { \"i386\"; };",
      match => qr/^APT::Architectures /,
      create => 1,
    },
  ],
  file_modify => [
    "/etc/grub.d/00_header" => [
      's/^set timeout=-.*/set timeout=30/',
    ],
    "/etc/apt/sources.list" => [
      's/^[^#]/#$&/',
    ],
  ],
  file_install => {
    "/etc/snmp/snmpd.conf" => {
      source => "rollout:/files/snmpd.conf",
      mode => 0600,
      owner => 'root',
      group => 'root',
      command => "/etc/init.d/snmpd restart",
    },
    "/etc/mailname" => {
      text => "$hostname.chrisdonovan.com.au\n",
      command => "/etc/init.d/postfix restart",
    },
    "/etc/postfix/main.cf" => {
      source => "rollout:/files/main.cf",
      mode => 0644,
      owner => 'root',
      group => 'root',
      command => "/etc/init.d/postfix restart",
    },
    "/etc/security/limits.conf" => {
      source => "rollout:/files/limits.conf",
      mode => 0640,
      owner => 'root',
      group => 'root',
    },
    "/etc/sudoers" => {
      source => "rollout:/files/sudoers",
      mode => 0440,
      owner => 'root',
      group => 'root',
    },
  },
  dir_install => {
    '/etc/apache2' => {
      source => 'rollout:/files/apache2',
      dir_mode => 0755,
      mode => 0644,
      owner => 'root',
      group => 'root',
    },
  },
  group => {
    admin => {
      gid => 500,
    },
  },
  user => {
    alienres => {
      name => "AlienResidents",
      uid => 1000,
      gid => 1000,
      home => '/home/alienres',
      shell => '/bin/bash',
      groups => ['sudo', 'admin'],
      ssh_keys => [
                    'alienres\@server',
                  ],
    },
  },
}; # }}}
class Apache2_Server => { # {{{
  service => {
    apache2 => 1,
  },
  packages => [qw( apache2 )],
  file_append => [
    {
      file => "/etc/default/apache2",
      add => 'HTCACHECLEAN_OPTIONS="-t -n"',
      match => qr/^HTCACHECLEAN_OPTIONS.*$/,
      create => 1,
      cmd => "/etc/init.d/apache2 restart",
    },
  ],
}; # }}}
class Rollout_Server => { # {{{
  inherits(
    Apache2_Server,
  ),
  group => {
    rollout => {
      gid => 500,
    },
  },
  user => {
    rollout => {
      name => "Rollout User",
      uid => 500,
      gid => 500,
      home => '/app/rollout',
      shell => '/bin/false',
      groups => ['rollout'],
    },
  },
}; # }}}
  ```

1.  Edit the client specific file

  ```bash
vim $BASEDIR/fragments/clients/internal/testing/client
  ```

**$BASEDIR/fragments/clients/internal/testing/client**

  ```perl
#!/usr/bin/perl -w
# vim:tw=100 sw=2 expandtab ft=perl foldmethod=marker

device client => { # {{{
  inherits(
    SOE_Ubuntu,
  ),
  interfaces => {
    eth0 => {
      primary => 1,
      ip => '10.9.8.254',
      netmask => '255.255.255.0',
      network => '10.9.8.0',
      broadcast => '10.9.8.255',
      gateway => '10.9.8.1',
    },
  },
}; # }}}
  ```

1.  Run the following commands as root (or prepend sudo)

  ```bash
apt-get update
apt-get -y install libwww-perl libio-socket-ssl-perl liberror-perl wget &&
URL=http://10.9.8.1/rollout &&
wget -O- $URL/rollout | perl - -u $URL/rollout -o setup
  ```
