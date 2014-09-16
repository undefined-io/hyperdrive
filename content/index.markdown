---
author:
- name: datfinesoul
  affiliation: undefined.io
markedDocs:
  toc: !!bool 'true'
...

Hyperdrive is a toolkit for turning a virtual or physical machine infrastructure into a continuous deployment stack.

This is a fork of wballard/hyperdrive, and uses many of the original ideas, but a different approach to the implementation.

# Requirements / OS Support

Currently Hyperdrive is only supported on Ubuntu 14.04.

# Overview


This version of hyperdrive is still under heavy development, and many critical pieces are missing. It is not meant for a production install anywhere.

Installation is really only recommended to see the limited working features in action.

## Installation

### Saucy

```bash
# On most systems, the following will suffice to install Hyperdrive
bash <(curl https://raw.githubusercontent.com/undefined-io/hyperdrive/reset/bootstrap)
```

### Vagrant

The Vagrantfile that comes with the current version or hyperdrive should allow installation on parallels, vmware and virtualbox.

**NOTE OSX/MAC USERS:** *If you have just installed Vagrant, and still have the "Vagrant" pkg mounted, your install of Hyperdrive will fail. You'll have to unmount the pkg first before you try to start up the image*

```bash
# Run the following export(s), then choose the file that fit your vm software
export HYPERDRIVE_VAGRANT_MEMSIZE=4096

# Parallels
./parallels

# VMware
./vmware

# Virtualbox
./virtualbox
```

# Terminology

Hyperdrive uses a spaceship theme to describe the working environments. Here is a list of the different terms.

- **Fleet** - A collection of squadarons
- **Squadron** - A collection of ships. (*VM, Server, etc...*)
- **Headquarters** - A place for squadrons to obtain orders
- **Ship** - Ships are responsible for completing assignments. (*LXC*)
- **Assignment** - Task assigned to a ship based on orders from the HQ. (*Application, Service, etc...*)
- **Orders** - Contain all the information for a ship to complete an assignment.
- **Admiral** - In charge of the fleet, and has full access to every squadron
- **Hull** - Framework for a ship

# Getting Started

## Setup Headquarters Repo

Headquarters are just GIT repositories that contain a hyperdrive specific directory structure and tell each Captain in the fleet what to do.

### Example

```
|-- authorized_keys
|   `-- john.doe@hyperdrive.com.pub
|-- nodejs-ship
|   `-- orders
`-- python-ship
    `-- orders
```

- **/authorized_keys** - contains public keys for admiral access
- **/nodejs-ship/orders** - orders with an assignment called 'nodejs-ship'
- **/python-ship/orders** - orders with an assignment called 'python-ship'

## Assign Squadron to HQ

```bash
# This will setup a clone of the HQ in "/data/hyperdrive/headquarters" (default path)
hyperdrive-headquarters <REPO_URL> --sync
```

If you want the Captain to obtain new orders from the HQ automatically, you can do that by:

```bash
start hyperdrive-captain-obtain-orders
```

This will make the captain check with the configured HQ every minute, to see if any updates or new orders are available.

# Where Hyperdrive Lives

These are the default locations. **NOTE** Many of these locations are still changing during the refactor.

## /data/hyperdrive

The Hyperdrive data directory. The GIT repo lives here, and other files related to keeping track of Hyperdrive related stuff.

```
|-- git
|-- includes
|-- bootstrap.log
|-- lxc
`-- records
    `-- system.files
```

- **/git/** - The Hyperdrive GIT repo
- **/includes/** - Environment files that will be used as hyperdrive runs (after install, this is empty)
- **/bootstrap.log** - Inital setup log from when the system was bootstrapped
- **/lxc/** - The root of the container file system
- **/records/system.files** - A list of files that were installed in system folders (/etc/ /usr/bin/ ...)

## /var/hyperdrive

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
- **/nginx/direct/** - Configs to access ship on individual port
- **/nginx/mount/** - Configs to access ship under hyperdrive root
- **/nginx/upstream/** - Loadmaster config to have one access point for all workstations
- **/private_keys/** - Private keys used to access remote GIT repos
- **/public_keys/** - Public keys for admiral access
- **/scripts/** - The main hyperdrive scripts
- **/scripts/lib/** - Support files for the main hyperdrive scripts

## /etc/hyperdrive

```
`-- main.conf
```

- **/main.conf** - Master settings for Hyperdrive intall

# Orders

The `orders` file is used to configure environment variables specific to the app and Hyperdrive.

# Developer Notes

If you are using the provided `Vagrantfile`, your box will have the working copy of hyperdrive located at `/vagrant` on your VM. This comes in handy, for testing changes prior to them being installed.

## Step By Step (Just Notes)

Much of this will be improved during the dev cycle, but trying to allow devs to understand what I'm doing atm while developing.

### Bootstrap

```bash
# This sets up the basics
/vagrant/bootstrap "" "" "file:///vagrant" ""
```

### Running everything

```bash
# Setup HQ, monitor for auto deploy
cd /var/hyperdrive/scripts/
./hyperdrive-headquarters https://github.com/datfinesoul/hyperdrive-hq#master
start hyperdrive-captain-obtain-orders

# To see logs
tail -F /var/log/upstart/hyperdrive*
```

## Hacking on Hyperdrive with Vagrant

### Symlink Approach

The easiest way to hack on Hyperdrive is usually to use Vagrant and then symlink the folders of files you are working on.

```bash
vagrant ssh
sudo su -
cd /var/hyperdrive
mv scripts scripts.bak
ln -s /vagrant/app/scripts/
```

Then just work on the scripts in your local directories using your favorite editors, and test out the results immediately.

**NOTE:** Running `install` will wipe out all the symlinks.

### Github Approach

If you prefer to check in all changes, use the push/install approach.

```bash
# On the Hyperdrive system or VM:
cd /var/hyperdrive/scripts
./install
```

This pulls the latest changes and upgrades hyperdrive. The repo that you pull from will come from the `/etc/hyperdrive/main.conf` file (HYPERDRIVE_REMOTE)
