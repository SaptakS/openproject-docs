# Packaged Installation Guide

The packaged installation of OpenProject is the easiest way to install and maintain OpenProject, provided a supported distribution exists and you can allocate an isolated server for OpenProject. The package will:

- guide you  through all required steps

- install all required libraries and dependencies

- install a local PostgreSQL database or allow you to connect to an existing PostgreSQL database

- allow you to install and configure an outer Apache web server 

- setup SSL/TLS encryption for the Apache server

- configure repositories (Git/SVN)

- configure email settings

  



## Supported distributions



The packaged installation is provided for the following distributions:



| Distribution (64 bits only)     | Identifier   | init system |
| ------------------------------- | ------------ | ----------- |
| CentOS/RHEL 7.x                 | centos-7     | systemd     |
| Debian 9 Stretch                | debian-9     | systemd     |
| Debian 10 Stretch               | debian-10    | systemd     |
| Suse Linux Enterprise Server 12 | sles-12      | sysvinit    |
| Ubuntu 16.04 Xenial Xerus       | ubuntu-16.04 | upstart     |
| Ubuntu 18.04 Bionic Beaver      | ubuntu-18.04 | systemd     |



# Installation steps



## Step 1: Install the OpenProject package



As the first step, you will need to add the OpenProject package source to the package manager of your distribution. Please follow the steps with your root user (or with `sudo` if your distribution supports it) according to your distribution:


<div class="installation-distribution">

### Ubuntu 16.04.

**1. Import the packager.io repository signing key**

Import the PGP key used to sign our packages. Since we're using the *packager.io* platform to distribute our packages, both package source and signing key are tied to their service.

```bash
wget -qO- https://dl.packager.io/srv/opf/openproject/key | sudo apt-key add -
```

**2. Add the OpenProject package source**

```
sudo wget -O /etc/apt/sources.list.d/openproject.list \
  https://dl.packager.io/srv/opf/openproject/stable/10/installer/ubuntu/16.04.repo
```

**3. Install the OpenProject Community Edition package**

Using the following commands, apt will check the new package source and install the package and all required dependencies.

```bash
apt-get update
apt-get install openproject
```

</div>
<div class="installation-distribution">

### Ubuntu 18.04

**1. Import the packager.io repository signing key**

Import the PGP key used to sign our packages. Since we're using the *packager.io* platform to distribute our packages, both package source and signing key are tied to their service.

```bash
wget -qO- https://dl.packager.io/srv/opf/openproject/key | sudo apt-key add -
```

**2. Ensure that universe package source is added**

You may run into issues trying to install the `dialog` package in Ubuntu 18.04. To resolve this, please ensure you have the universe APT source

```bash
sudo add-apt-repository universe
```

**3. Add the OpenProject package source**

```
sudo wget -O /etc/apt/sources.list.d/openproject.list \
  https://dl.packager.io/srv/opf/openproject/stable/10/installer/ubuntu/18.04.repo
```

**4. Install the OpenProject Community Edition package**

Using the following commands, apt will check the new package source and install the package and all required dependencies.

```bash
apt-get update
apt-get install openproject
```

</div>
<div class="installation-distribution">

### Debian 9

**1. Import the packager.io repository signing key**

Import the PGP key used to sign our packages. Since we're using the *packager.io* platform to distribute our packages, both package source and signing key are tied to their service.

```bash
wget -qO- https://dl.packager.io/srv/opf/openproject/key | sudo apt-key add -
```

**2. Add the OpenProject package source**

```
wget -O /etc/apt/sources.list.d/openproject.list \
  https://dl.packager.io/srv/opf/openproject/stable/10/installer/debian/9.repo
```

**3. Install the OpenProject Community Edition package**

Using the following commands, apt will check the new package source and install the package and all required dependencies.

```bash
apt-get update
apt-get install openproject
```

</div>
<div class="installation-distribution">

### Debian 10

**1. Import the packager.io repository signing key**

Import the PGP key used to sign our packages. Since we're using the *packager.io* platform to distribute our packages, both package source and signing key are tied to their service.

```bash
wget -qO- https://dl.packager.io/srv/opf/openproject/key | sudo apt-key add -
```

**2. Add the OpenProject package source**

```
wget -O /etc/apt/sources.list.d/openproject.list \
  https://dl.packager.io/srv/opf/openproject/stable/10/installer/debian/10.repo
```

**3. Install the OpenProject Community Edition package**

Using the following commands, apt will check the new package source and install the package and all required dependencies.

```bash
apt-get update
apt-get install openproject
```

</div>
<div class="installation-distribution">

### Centos 7

**1. Add the OpenProject package source**

```
sudo wget -O /etc/yum.repos.d/openproject.repo \
  https://dl.packager.io/srv/opf/openproject/stable/10/installer/el/7.repo
```

**2. Install the OpenProject Community Edition package**

Using the following command, yum will install the package and all required dependencies.

```bash
sudo yum install openproject
```

</div>
<div class="installation-distribution">

### SLES 12

**1. Add the OpenProject package source**

```
wget -O /etc/zypp/repos.d/openproject.repo \
  https://dl.packager.io/srv/opf/openproject/stable/10/installer/sles/12.repo
```

The package source is now registered as `openproject`.

**2. Install the OpenProject Community Edition package**

Using the following command, zypper will install the package and all required dependencies.

```bash
zypper install openproject
```

</div>
