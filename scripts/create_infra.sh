#!/bin/bash
# create_infra.sh
#Below is the content of my automation script:
# This script automates the creation of my Azure IAM project infrastructure

# Variables
RESOURCE_GROUP="iam-automation"
LOCATION="uksouth"
VNET_NAME="vnet-iam-automation"
VNET_ADDRESS="10.0.0.0/16"
WEB_SUBNET_NAME="subnet-web"
WEB_SUBNET_PREFIX="10.0.1.0/24"
DB_SUBNET_NAME="subnet-db"
DB_SUBNET_PREFIX="10.0.2.0/24"

# Step 1: Created Resource Group
az group create --name $RESOURCE_GROUP --location $LOCATION --output table

# Step 2: Created Virtual Network
az network vnet create --resource-group $RESOURCE_GROUP --name $VNET_NAME --address-prefix $VNET_ADDRESS --location $LOCATION --output table

# Step 3: Created Web Subnet
az network vnet subnet create --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME --name $WEB_SUBNET_NAME --address-prefix $WEB_SUBNET_PREFIX --output table

# Step 4: Created DB Subnet
az network vnet subnet create --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME --name $DB_SUBNET_NAME --address-prefix $DB_SUBNET_PREFIX --output table

echo "My Azure IAM project infrastructure created successfully!"
