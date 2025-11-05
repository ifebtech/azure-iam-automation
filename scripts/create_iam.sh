#!/bin/bash
export MSYS_NO_PATHCONV=1  # Prevent Git Bash path conversion
set -e
set -u

# Script Name: create_iam.sh
# Purpose: To verify existing Azure IAM setup for IAM automation project
# Note: AD groups and users are created manually via Azure Portal
# This script only verifies they exist and checks role assignments

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

# Set subscription
echo "Setting subscription to $SUBSCRIPTION_ID..."
az account set --subscription "$SUBSCRIPTION_ID"

# Verify subscription is set correctly
CURRENT_SUB=$(az account show --query id -o tsv)
echo "Current subscription: $CURRENT_SUB"

# Step 1: Verify Azure AD Groups exist
echo ""
echo "Step 1: Verifying Azure AD groups..."
if az ad group show --group WebAdmins &> /dev/null; then
    echo "✅ WebAdmins group exists"
else
    echo "⚠️ WebAdmins group not found"
fi

if az ad group show --group DBAdmins &> /dev/null; then
    echo "✅ DBAdmins group exists"
else
    echo "⚠️ DBAdmins group not found"
fi

# Step 2: Verify test users exist
echo ""
echo "Step 2: Verifying test users..."
if az ad user show --id webuser1@ifeanyiogbonnaya33gmail.onmicrosoft.com &> /dev/null; then
    echo "✅ webuser1 exists"
else
    echo "⚠️ webuser1 not found"
fi

if az ad user show --id dbuser1@ifeanyiogbonnaya33gmail.onmicrosoft.com &> /dev/null; then
    echo "✅ dbuser1 exists"
else
    echo "⚠️ dbuser1 not found"
fi

# Step 3: Retrieve IDs for verification
echo ""
echo "Step 3: Retrieving IDs for verification..."
WEBADMINS_GROUP_ID=$(az ad group show --group WebAdmins --query id -o tsv 2>/dev/null || echo "")
DBADMINS_GROUP_ID=$(az ad group show --group DBAdmins --query id -o tsv 2>/dev/null || echo "")
WEB_USER_ID=$(az ad user show --id webuser1@ifeanyiogbonnaya33gmail.onmicrosoft.com --query id -o tsv 2>/dev/null || echo "")
DB_USER_ID=$(az ad user show --id dbuser1@ifeanyiogbonnaya33gmail.onmicrosoft.com --query id -o tsv 2>/dev/null || echo "")

if [ -n "$WEBADMINS_GROUP_ID" ] && [ -n "$DBADMINS_GROUP_ID" ]; then
    echo "✅ Group IDs retrieved: WebAdmins=$WEBADMINS_GROUP_ID, DBAdmins=$DBADMINS_GROUP_ID"
else
    echo "⚠️ Could not retrieve all group IDs"
fi

if [ -n "$WEB_USER_ID" ] && [ -n "$DB_USER_ID" ]; then
    echo "✅ User IDs retrieved: WebUser=$WEB_USER_ID, DBUser=$DB_USER_ID"
else
    echo "⚠️ Could not retrieve all user IDs"
fi

# Step 4: Verify group memberships
echo ""
echo "Step 4: Verifying group memberships..."
if [ -n "$WEB_USER_ID" ]; then
    if az ad group member list --group WebAdmins --query "[?id=='$WEB_USER_ID']" | grep -q "$WEB_USER_ID"; then
        echo "✅ webuser1 is a member of WebAdmins"
    else
        echo "⚠️ webuser1 is NOT a member of WebAdmins"
    fi
fi

if [ -n "$DB_USER_ID" ]; then
    if az ad group member list --group DBAdmins --query "[?id=='$DB_USER_ID']" | grep -q "$DB_USER_ID"; then
        echo "✅ dbuser1 is a member of DBAdmins"
    else
        echo "⚠️ dbuser1 is NOT a member of DBAdmins"
    fi
fi

# Step 5: Verify role assignments
echo ""
echo "Step 5: Verifying role assignments..."
if [ -n "$DBADMINS_GROUP_ID" ]; then
    if az role assignment list --assignee "$DBADMINS_GROUP_ID" --scope "$DB_SUBNET_ID" | grep -q "Reader"; then
        echo "✅ DBAdmins group has Reader role on DB subnet"
    else
        echo "⚠️ Reader role assignment for DBAdmins not found on DB subnet"
    fi
fi

# Step 6: List all configurations
echo ""
echo "Step 6: IAM Configuration Summary"
echo "=================================="
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "Subscription: $SUBSCRIPTION_ID"
echo ""
echo "Azure AD Groups:"
az ad group list --output table 2>/dev/null | grep -E "WebAdmins|DBAdmins" || echo "No groups found"

echo ""
echo "Test Users:"
az ad user list --output table 2>/dev/null | grep -E "webuser1|dbuser1" || echo "No test users found"

echo ""
echo "Role Assignments:"
az role assignment list --all --output table 2>/dev/null | grep -E "DBAdmins|Reader" || echo "No role assignments found"

echo ""
echo "✅ IAM verification complete!"