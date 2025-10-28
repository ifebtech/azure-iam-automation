#!/bin/bash
export MSYS_NO_PATHCONV=1  # Prevent Git Bash path conversion
set -e
set -u

# Script Name: create_iam.sh
# Purpose: To automate Azure IAM setup for IAM automation project

# Variables
RESOURCE_GROUP="iam-automation"
LOCATION="uksouth"
SUBSCRIPTION_ID="175dd7dd-05c8-4a40-96f4-7cf5cc651f6a"
DB_SUBNET_ID="/subscriptions/175dd7dd-05c8-4a40-96f4-7cf5cc651f6a/resourceGroups/iam-automation/providers/Microsoft.Network/virtualNetworks/vnet-iam-automation/subnets/subnet-db"

# Verify Azure CLI login
echo "Verifying Azure CLI authentication..."
if ! az account show &> /dev/null; then
    echo "ERROR: Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

# Set subscription - THIS IS CRITICAL
echo "Setting subscription to $SUBSCRIPTION_ID..."
az account set --subscription "$SUBSCRIPTION_ID"

# Verify subscription is set correctly
CURRENT_SUB=$(az account show --query id -o tsv)
echo "Current subscription: $CURRENT_SUB"

# Step 1: Creating Azure AD Groups
echo "Creating Azure AD groups..."
az ad group create --display-name "WebAdmins" --mail-nickname "WebAdmins" || echo "WebAdmins group may already exist"
az ad group create --display-name "DBAdmins" --mail-nickname "DBAdmins" || echo "DBAdmins group may already exist"

# Step 2: Creating test users
echo "Creating test users..."
az ad user create --display-name "Web User1" --user-principal-name webuser1@ifeanyiogbonnaya33gmail.onmicrosoft.com --password "WebPassword123" --force-change-password-next-sign-in false || echo "webuser1 may already exist"
az ad user create --display-name "DB User1" --user-principal-name dbuser1@ifeanyiogbonnaya33gmail.onmicrosoft.com --password "DBPassword123" --force-change-password-next-sign-in false || echo "dbuser1 may already exist"

# Step 3: Retrieving IDs
echo "Retrieving group and user IDs..."
WEBADMINS_GROUP_ID=$(az ad group show --group WebAdmins --query id -o tsv)
DBADMINS_GROUP_ID=$(az ad group show --group DBAdmins --query id -o tsv)
WEB_USER_ID=$(az ad user show --id webuser1@ifeanyiogbonnaya33gmail.onmicrosoft.com --query id -o tsv)
DB_USER_ID=$(az ad user show --id dbuser1@ifeanyiogbonnaya33gmail.onmicrosoft.com --query id -o tsv)

echo "Group IDs retrieved: WebAdmins=$WEBADMINS_GROUP_ID, DBAdmins=$DBADMINS_GROUP_ID"
echo "User IDs retrieved: WebUser=$WEB_USER_ID, DBUser=$DB_USER_ID"

# Step 4: Adding users to groups
echo "Adding users to groups..."
az ad group member add --group WebAdmins --member-id $WEB_USER_ID || echo "webuser1 may already be in WebAdmins"
az ad group member add --group DBAdmins --member-id $DB_USER_ID || echo "dbuser1 may already be in DBAdmins"

# Step 5: Assigning role to DBAdmins
echo "Assigning Reader role to DBAdmins group on DB Subnet..."
az role assignment create --assignee $DBADMINS_GROUP_ID --role Reader --scope $DB_SUBNET_ID || echo "Role assignment may already exist"

echo "✅ IAM configuration complete!"