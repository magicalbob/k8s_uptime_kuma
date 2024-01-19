Uptime Kuma in Kubernetes
=========================

Just run `install-uptime-kuma.sh` to set it all up.

It will try to use a Kubernetes cluster if it finds one, or set up a Kind cluster otherwise.

It places everything in the `uptime-kuma` namespace.

There is a `port3001.service` file in the `systemd` directory, to control port forwarding.
