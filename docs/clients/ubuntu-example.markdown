#This is an example on how to install the rollout client on Ubuntu.
In order to install rollout on the client, you'll need to have a client configured
on the server.

#Required Information
ROLLOUT_SERVER : The hostname or IP address of the server running rollout.

URL : The URL where rollout is being served from $ROLLOUT_SERVER

# Client Installation

1. Install required perl modules

  ```bash
apt-get -y install libwww-perl libio-socket-ssl-perl liberror-perl wget
  ```

1. Install rollout on a client

  ```bash
URL=http://$ROLLOUT_SERVER:$ROLLOUT_PORT
wget -O- $URL/rollout | perl - -u $URL -o setup
  ```

# Example Client Installation
The following example is the initial setup on a new installation of an Ubuntu client.

##Client details
* OS - Linux 
* Distribution - Ubuntu Server 12.04 LTS
* Architecture - i386
* Hostname - client
* IP Address - 10.9.8.254

1.  Create a new file for the client on the rollout server

  We want a directory hiearchy for our clients so we can better manage them.

  ```bash
mkdir -p $BASEDIR/fragments/clients/internal/testing
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
  domain_name => "example.com,
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
      'deb http://10.9.8.1/ubuntu/ precise main',
      'deb http://10.9.8.1/ubuntu/ precise-updates main',
      'deb http://10.9.8.1/ubuntu/ precise-security main',
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
      add => 'root: joe\@example.com',
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
      text => "$hostname.example.com\n",
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
    joe => {
      name => "Joe",
      uid => 1000,
      gid => 1000,
      home => '/home/joe',
      shell => '/bin/bash',
      groups => ['sudo', 'admin'],
      ssh_keys => [
                    'joe\@desktop',
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
