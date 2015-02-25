# TODO

* Fleet Deployment Register - Something similar to HQ, except to keep track of Squadrons and their configurations.
  * Environment Variables, etc...
  * A place for Squadrons to check in

ssh-keygen -t dsa -C "hyperdrive-vagrant" -f hyperdrive_id_dsa -P ""
ssh-agent bash -c 'ssh-add /vagrant/tmp/hyperdrive_id_dsa; hd headquarters --sync'
