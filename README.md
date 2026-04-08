# Basic Jenkins Server Setup

This repository contains Terraform configuration files for provisioning a basic Jenkins server.

## Prerequisites

To use this repository, you **must** have Terraform installed on your local machine. 

* [Download and Install Terraform](https://developer.hashicorp.com/terraform/downloads)

## Getting Started

Follow these steps to set up and deploy the infrastructure:

### 1. Clone the Repository

First, clone this repository to your local machine using Git, and navigate into the project directory:

    git clone https://github.com/theswordpt-git/Basic-Jenkins-Setup
 

### 2. Update the Private Key

For Terraform to successfully authenticate and provision your resources, the private key path in the configuration must match the actual location of your private key on your local machine.

1. Open the Terraform configuration files (e.g., `basic-server.tf`).
2. Locate the section where the private key file path is defined.
3. **Change the private key file path** in the Terraform file to match the exact location and name of your local private key (e.g., `YourPrivateKey.pem`), OR rename/move your local key to match what is currently written in the Terraform file.
4. (Optional) Change the plugins.xml location from this repo to your own in user-data.sh

*⚠️ **Security Warning**: Never place your actual private key file directly inside this repository or commit it to version control.*

### 3. Initialize and Run Terraform

Once you have updated the private key configuration, you can deploy the infrastructure:

    # Initialize the Terraform working directory
    terraform init

    # View the execution plan to see what will be created
    terraform plan

    # Apply the changes and provision the infrastructure
    terraform apply
