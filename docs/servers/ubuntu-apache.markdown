#This is an example on how to install the rollout server on Ubuntu.

# Server Installation
##Required Information

  ```bash
BASEDIR=</base/directoy/for/rolloutd/>
ROLLOUT_SERVER=<resolvable hostname | ip address>
ROLLOUT_PORT=<some port number>
  ```

All commands must be run as root, unless otherwise specified.


1.  Get rollout source using git

  ```bash
  apt-get install -y git
  cd $(dirname $BASEDIR)
  git clone https://github.com/alienresidents/rollout
  ```

1.  Setup Apache

  1.  Edit the Apache2 default configuration file

  **/etc/apache2/sites-available/000-default**

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
* Hostname - **rollout-srv**
* OS - **Linux**
* Distribution - **Ubuntu Server 12.04.3**
* Architecture - **x86_64**
* Web Server - **Apache2**


##Install and Configure the Server
1.  Run the following commands

  ```bash
BASEDIR="/app/rollout"
cd $(dirname $BASEDIR)
apt-get -y install git
git clone https://github.com/alienresidents/rollout.git
  ```

1.  Edit the default Apache2 configuration

  ```bash
vim /etc/apache2/sites-available/000-default
  ```

  **/etc/apache2/sites-available/000-default**

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
/etc/init.d/apache2 reload
  ```

1.  Test the apache changes

  ```bash
wget -O- http://localhost/rollout/README
  ```
You should be presented with the contents of the README file.
