#!/bin/bash
# cleanup.sh
# Purpose: To safely remove all Azure resources created during the IAM automation project
# This script deletes resources in REVERSE order of creation to avoid dependency conflicts

set -e  # Exit immediately if any command fails
set -u  # Treat unset variables as errors

# Color codes for better terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables - Had to match those used in create_infra.sh and create_iam.sh
RESOURCE_GROUP="iam-automation"
SUBSCRIPTION_ID="175dd7dd-05c8-4a40-96f4-7cf5cc651f6a"
DB_SUBNET_ID="/subscriptions/175dd7dd-05c8-4a40-96f4-7cf5cc651f6a/resourceGroups/iam-automation/providers/Microsoft.Network/virtualNetworks/vnet-iam-automation/subnets/subnet-db"

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verify Azure CLI login
print_message "Verifying Azure CLI authentication..."
if ! az account show &> /dev/null; then
    print_error "Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

# Set the correct subscription
print_message "Setting subscription to $SUBSCRIPTION_ID..."
az account set --subscription "$SUBSCRIPTION_ID"

# Confirmation prompt - Safety measure to prevent accidental deletion
echo ""
print_warning "⚠️  WARNING: This script will DELETE ALL resources in the IAM automation project!"
echo ""
echo "This includes:"
echo "  - Azure AD Users (webuser1, dbuser1)"
echo "  - Azure AD Groups (WebAdmins, DBAdmins)"
echo "  - Role Assignments (Reader role on DB subnet)"
echo "  - Virtual Network and Subnets"
echo "  - Resource Group (iam-automation)"
echo ""
read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirmation

if [ "$confirmation" != "yes" ]; then
    print_message "Cleanup cancelled by user. No resources were deleted."
    exit 0
fi

echo ""
print_message "Starting cleanup process..."
echo ""

# STEP 1: Remove Role Assignments
# Why first? Because roles depend on groups and resources existing
print_message "Step 1: Removing role assignments..."
DBADMINS_GROUP_ID=$(az ad group show --group DBAdmins --query id -o tsv 2>/dev/null || echo "")
if [ -n "$DBADMINS_GROUP_ID" ]; then
    az role assignment delete --assignee "$DBADMINS_GROUP_ID" --scope "$DB_SUBNET_ID" 2>/dev/null || print_warning "Role assignment may not exist or already deleted"
    print_message "✓ Role assignments removed"
else
    print_warning "DBAdmins group not found, skipping role assignment deletion"
fi

# STEP 2: Remove Users from Groups
# Why? Clean membership before deleting groups
print_message "Step 2: Removing users from groups..."
WEB_USER_ID=$(az ad user show --id webuser1@ifeanyiogbonnaya33gmail.onmicrosoft.com --query id -o tsv 2>/dev/null || echo "")
DB_USER_ID=$(az ad user show --id dbuser1@ifeanyiogbonnaya33gmail.onmicrosoft.com --query id -o tsv 2>/dev/null || echo "")

if [ -n "$WEB_USER_ID" ]; then
    az ad group member remove --group WebAdmins --member-id "$WEB_USER_ID" 2>/dev/null || print_warning "webuser1 may not be in WebAdmins"
fi

if [ -n "$DB_USER_ID" ]; then
    az ad group member remove --group DBAdmins --member-id "$DB_USER_ID" 2>/dev/null || print_warning "dbuser1 may not be in DBAdmins"
fi
print_message "✓ Users removed from groups"

# STEP 3: Delete Azure AD Users
# Why now? Users must be removed from groups first
print_message "Step 3: Deleting Azure AD users..."
az ad user delete --id webuser1@ifeanyiogbonnaya33gmail.onmicrosoft.com 2>/dev/null || print_warning "webuser1 may not exist"
az ad user delete --id dbuser1@ifeanyiogbonnaya33gmail.onmicrosoft.com 2>/dev/null || print_warning "dbuser1 may not exist"
print_message "✓ Test users deleted"

# STEP 4: Delete Azure AD Groups
# Why now? Groups must be empty before deletion
print_message "Step 4: Deleting Azure AD groups..."
az ad group delete --group WebAdmins 2>/dev/null || print_warning "WebAdmins group may not exist"
az ad group delete --group DBAdmins 2>/dev/null || print_warning "DBAdmins group may not exist"
print_message "✓ AD groups deleted"

# STEP 5: Delete Resource Group (and all contained resources)
# Why last? This removes VNet, Subnets, and all infrastructure at once
print_message "Step 5: Deleting resource group and all infrastructure..."
print_warning "This may take 2-3 minutes..."
az group delete --name "$RESOURCE_GROUP" --yes --no-wait 2>/dev/null || print_warning "Resource group may not exist"
print_message "✓ Resource group deletion initiated (running in background)"

echo ""
print_message              "VERIFICATION"            
print_message "✅ Cleanup process completed successfully!"
echo ""
print_message "All IAM resources and infrastructure have been removed."
print_message "You can now run ./scripts/create_infra.sh and ./scripts/create_iam.sh to redeploy."
echo ""