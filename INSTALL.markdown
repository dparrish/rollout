#Rollout Installation and Basic Configuration Instructions

# Server Installation:
   Required Information:
<pre>
      BASEDIR=</base/directoy/for/rolloutd/>
      USER=<username_rolloutd_will_run_as>
      GROUP=<groupname_rolloutd_will_run_as>
      ROLLOUT_SERVER=<resolvable hostname | ip address>
      ROLLOUT_PORT=<some port number>
</pre>

1. You'll need the following perl modules:
<pre>
    Net::Netmask
    IO::Socket::SSL
    Error
    LWP
</pre>

1. Get rollout source, and extract:
<pre>
    ROLLOUT_TMP_DIR='/tmp/rollout'
    cd /tmp
</pre>
    + Using wget:
<pre>
      wget http://github.com/dparrish/rollout/archive/master.tar.gz
      tar xzf master.tar.gz
      mv rollout-master rollout
</pre>
    + Using git:
<pre>
      git clone https://github.com/dparrish/rollout.git
</pre>
    

1. After extraction, run the following commands as root:
<pre>
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
</pre>

1. Edit /etc/default/rollout to configure your server

1. Add required symlinks to /etc/rc?.d/S??rollout to /etc/init.d/rollout:
<pre>
    ln -s /etc/init.d/rollout /etc/rc1.d/K20rollout
    ln -s /etc/init.d/rollout /etc/rc3.d/S70rollout
    ln -s /etc/init.d/rollout /etc/rc2.d/S70rollout
</pre>

1. Copy the default configuration (rollout.cfg) or your own configuration into
   $BASEDIR.

1.  Decide which webserver to use.
  a. Use rolloutd
      + Start rolloutd
<pre>
        /etc/init.d/rollout start
</pre>
  b. Use Apache2
      + Add the following to Apache2 configuration
<pre>
        Alias /rollout /app/rollout
        <Directory /app/rollout>
          Options Indexes FollowSymlinks
          AllowOverride None
          Order allow,deny
          allow from all
        </Directory>
</pre>
      + Restart Apache2
<pre>
        /etc/init.d/apache2 restart
</pre>


# Client Installation:

1. Install required perl modules
1. Install rollout on a client:
<pre>
    URL=http://$ROLLOUT_SERVER:$ROLLOUT_PORT
    wget -O- $URL/rollout | perl - -u $URL -o setup
</pre>



# Example Server Installation and setup:
The following example is the initial setup and configuration on
a new installation of Ubuntu Server 12.10 32bit

I need to have Apache2 installed for other resons on this server, and have
little control over the firewall, so I chose that option instead of the
provided rolloutd.

Install and Configure
<pre>
  ROLLOUT_TMP_DIR="/tmp/rollout"
  BASEDIR="/app/rollout"
  ROLLOUT_SERVER="10.0.2.15"
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
  vim /etc/apache2/sites-enabled/000-default
    Alias /rollout /app/rollout
    <Directory /app/rollout>
      Options Indexes FollowSymlinks
      AllowOverride None
      Order allow,deny
      allow from all
    </Directory>
  /etc/init.d/apache2 restart  
</pre>


# Example Client Installation:
The following example is the initial setup on a new installation of
Ubuntu Server 12.04.1 LTS 32bit

Client details:
+ hostname - client

As root, on the client, run the following commands, in order.
<pre>
apt-get update
apt-get -y install libwww-perl libio-socket-ssl-perl liberror-perl &&
URL=http://10.227.192.34/rollout &&
wget -O- $URL/rollout | perl - -u $URL/rollout -o setup
</pre>
