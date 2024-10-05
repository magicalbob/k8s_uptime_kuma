# Uptime Kuma in Kubernetes

## Introduction
This project automates the deployment of Uptime Kuma in a Kubernetes environment. You can easily set it up by running the `install-uptime-kuma.sh` script. If no Kubernetes cluster is found, the script will set up a Kind cluster for you. 

## Usage
1. Run the `install-uptime-kuma.sh` script to deploy Uptime Kuma.
2. All resources will be placed in the `uptime-kuma` namespace.
3. You can control port forwarding using the `port3001.service` file located in the `systemd` directory.

## Getting Started
To get started with the project, follow these steps:
- Clone this repository.
- Review the contents of the repository and make any necessary configurations.
- Run the `install-uptime-kuma.sh` script to set up Uptime Kuma in Kubernetes.

## Support
If you encounter any issues or have questions about this project, feel free to [open an issue](link-to-issue-tracker) in the repository.

## Contributing
Contributions are welcome! If you would like to contribute to the project, please follow our [contribution guidelines](link-to-contribution-docs).

## License
This project is licensed under the [MIT License](link-to-license-file).
