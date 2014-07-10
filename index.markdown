<h1>Starphleet</h1><div class="jumbotron"> Containers + Buildpacks + Repositories = Autodeploy Services</div>

Starphleet is a toolkit for turning a virtual or physical machine infrastructure into a continuous deployment stack.

This is a fork of wballard/starphleet, and uses many of the original ideas, but a different approach to the implementation.

Requirements / OS Support
=========================

Currently Starphleet is only supported on Ubuntu Saucy 13.10.

Overview
========

This version of starphleet is still under heavy development, and many critical pieces are missing. It is not meant for a production install anywhere.

Installation is really only recommended to see the limited working features in action.

Installation
------------

### Saucy

```bash
# On most systems, the following will suffice to install Starphleet
bash <(curl https://raw.githubusercontent.com/undefined-io/starphleet/reset/bootstrap)
```

### Vagrant

The Vagrantfile that comes with the current version or starphleet should allow installation on parallels, vmware and virtualbox.

**NOTE OSX/MAC USERS:** *If you have just installed Vagrant, and still have the "Vagrant" pkg mounted, your install of Starphleet will fail. You'll have to unmount the pkg first before you try to start up the image*

```bash
# Run the following export(s), then choose the file that fit your vm software
export STARPHLEET_VAGRANT_MEMSIZE=4096

# Parallels
./parallels

# VMware
./vmware

# Virtualbox
./virtualbox
```

Terminology
===========

Starphleet uses a spaceship theme to describe the working environments. Here is a list of the different terms.

- **Headquarters** - In charge of issuing orders to the fleet
- **Fleet** - A collection of ships
- **Ship** - An individual (virtual) machine
- **Orders** - Instructions on deploying a service
- **Service** - The application / service
- **Container** - An LXC created by the loadmaster
- **Workstation** - A container created by the loadmaster where engineering runs a service
- **Engineering** - Responsible for running a service, and making sure it functions properly
- **Loadmaster** - In charge of the cargo loading/unloading operations. Also keeps track of the ship's stores.
- **Communications** - Facilitates dialog with the fleet
- **Medical** - Making sure that everyone on the ship is healthy
- **Captain** - Handles communications with headquarters and other departments on the ship
- **Admiral** - Has special access to be able to enter any ship in the fleet

Getting Started
===============

Setup Headquarters Repo
-----------------------

Headquarters are just GIT repositories that contain a starphleet specific directory structure and tell each Captain in the fleet what to do.

### Example

```
|-- authorized_keys
|   `-- john.doe@starphleet.com.pub
|-- \_default_
|   `-- orders
|-- nodejs-service
|   `--  orders
`-- python-service
    `--orders
```

- **/_default/orders** - an order file for a service that will run at the starphleet root (more on that later below)
- **/authorized_keys** - contains public keys for people that will have admiral access
- **/nodejs-service/orders** - orders for a service called 'nodejs-service'
- **/python-service/orders** - orders for a service called 'python-service'

Assign Ship to HQ
-----------------

```bash
# This will setup a clone of the HQ in "/data/starphleet/headquarters" (default path)
starphleet-headquarters <REPO_URL> --sync
```

If you want the Captain to obtain new orders from the HQ automatically, you can do that by:

```bash
start starphleet-captain-obtain-orders
```

This will make the captain check with the configured HQ every minute, to see if any updates or new orders are available.

Where Starphleet Lives
======================

These are the default locations. **NOTE** Many of these locations are still changing during the refactor.

/data/starphleet
----------------

The Starphleet data directory. The GIT repo lives here, and other files related to keeping track of Starphleet related stuff.

```
|-- git
|-- includes
|-- bootstrap.log
|-- lxc
`-- records
    `-- system.files
```

- **/git/** - The Starphleet GIT repo
- **/includes/** - Environment files that will be used as starphleet runs (after install, this is empty)
- **/bootstrap.log** - Inital setup log from when the system was bootstrapped
- **/lxc/** - The root of the container file system
- **/records/system.files** - A list of files that were installed in system folders (/etc/ /usr/bin/ ...)

/var/starphleet
---------------

```
|-- containers
|-- nginx
|   |-- direct
|   |-- mount
|   `-- upstream
|-- private_keys
|-- public_keys
`-- scripts
    `-- lib
```

- **/containers/** - The actual images of the running LXC are stored here
- **/nginx/direct/** - Configs to access service on individual port
- **/nginx/mount/** - Configs to access service under starphleet root
- **/nginx/upstream/** - Loadmaster config to have one access point for all workstations
- **/private_keys/** - Private keys used to access remote GIT repos
- **/public_keys/** - Public keys for admiral access
- **/scripts/** - The main starphleet scripts
- **/scripts/lib/** - Support files for the main starphleet scripts

/etc/starphleet
---------------

```
`-- main.conf
```

- **/main.conf** - Master settings for Starphleet intall

Orders
======

The `orders` file is used to configure environment variables specific to the app and Starphleet.

Developer Notes
===============

If you are using the provided `Vagrantfile`, your box will have the working copy of starphleet located at `/vagrant` on your VM. This comes in handy, for testing changes prior to them being installed.

Step By Step (Just Notes)
-------------------------

Much of this will be improved during the dev cycle, but trying to allow devs to understand what I'm doing atm while developing.

### Bootstrap

```bash
# This sets up the basics
/vagrant/bootstrap "" "" "file:///vagrant" ""
```

### Running everything

```bash
# Setup HQ, monitor for auto deploy
cd /var/starphleet/scripts/
./starphleet-headquarters https://github.com/datfinesoul/starphleet-hq#master
start starphleet-captain-obtain-orders

# To see logs
tail -F /var/log/upstart/starphleet*
```
