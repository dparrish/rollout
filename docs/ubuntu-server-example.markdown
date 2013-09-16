#This is an example on how to install the rollout server on Ubuntu.

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

##Install and Configure the Server
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
