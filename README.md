# Azure IAM Roles and Secure Access Automation
📋 Project Overview

This project demonstrates the automation of Identity and Access Management (IAM) in Microsoft Azure using Azure CLI and Bash scripting. It showcases how to programmatically create secure, role-based access controls for cloud infrastructure, following DevSecOps best practices.

🎯 Objectives

- Automate the creation of Azure infrastructure (Resource Group, Virtual Network, Subnets)

- Implement Azure Active Directory (AAD) groups for access management

- Assign role-based access control (RBAC) using the principle of least privilege

- Create test users and validate permission assignments

- Automate cleanup and resource removal

- Implement CI/CD pipeline for continuous deployment

```
🏗️ Architecture
Azure Subscription
└── Resource Group (iam-automation)
    └── Virtual Network (vnet-iam-automation) [10.0.0.0/16]
        ├── Web Subnet (subnet-web) [10.0.1.0/24]
        └── DB Subnet (subnet-db) [10.0.2.0/24]

Azure Active Directory
├── WebAdmins Group
│   └── webuser1
└── DBAdmins Group (Reader role on DB Subnet)
    └── dbuser1
```

```
📁 Project Structure
azure-iam-automation/
├── README.md                    # Project overview and guide
├── scripts/
│   ├── create_infra.sh          # Creates Azure infrastructure
│   ├── create_iam.sh            # Sets up IAM (groups, users, roles)
│   └── cleanup.sh               # Removes all created resources
├── docs/
│   ├── documentation.md         # Detailed step-by-step documentation with screenshots
│   └── screenshots/             # Visual proof of deployment and cleanup
└── .github/
    └── workflows/
        └── pipeline.yaml        # CI/CD automation with GitHub Actions
```


🛠️ Prerequisites
Required Tools

Azure CLI (version 2.40.0 or later)

`az --version`


- Bash Shell (Git Bash on Windows, or native terminal on Linux/Mac)

- Azure Subscription with appropriate permissions

- Code Editor (VS Code recommended)

Required Permissions

Your Azure account must have:

- Contributor or Owner role on the subscription

- Permissions to create Azure AD users and groups

- Permissions to assign RBAC roles

Verify Azure Login
`az login`
`az account show`

🚀 Quick Start Guide
Step 1: After Making Directory.

`cd azure-iam-automation`

Step 2: Make Scripts Executable

- `chmod +x scripts/create_infra.sh`
- `chmod +x scripts/create_iam.sh`
- `chmod +x scripts/cleanup.sh`

Step 3: Set Your Subscription (Important!)

Edit the following files and replace the subscription ID with yours:

`scripts/create_iam.sh` 

`scripts/cleanup.sh `

Find your subscription ID:

`az account show --query id -o tsv`

Step 4: Deploy Infrastructure

`./scripts/create_infra.sh`


Creates:

Resource Group iam-automation in UK South region

- Virtual Network vnet-iam-automation

- Web Subnet subnet-web

- DB Subnet subnet-db

Step 5: Deploy IAM Configuration

`./scripts/create_iam.sh`


Creates and Configures:

- Azure AD groups: WebAdmins and DBAdmins

- Test users: webuser1 and dbuser1

- Role assignments (Reader on DB Subnet for DBAdmins)

Step 6: Validate Deployment

Examples:

`az group show --name iam-automation --output table`
`az network vnet show --resource-group iam-automation --name vnet-iam-automation --output table`
`az ad group list --output table | grep -E "WebAdmins|DBAdmins"`
`az role assignment list --all --output table | grep DBAdmins`

🧹 Cleanup Process

⚠️ WARNING: This will delete all resources created by this project.

Run:

`./scripts/cleanup.sh`


This script:

- Removes role assignments

- Removes users from groups

- Deletes Azure AD users and groups

- Deletes the Resource Group (including VNet and Subnets)

Cleanup validation screenshots and confirmation outputs are included in:
📁 docs/documentation.md → Section 7.4 Cleanup Verification

🔄 **CI/CD Pipeline (GitHub Actions)**

This project includes a GitHub Actions workflow (.github/workflows/pipeline.yaml) that demonstrates continuous integration and deployment (CI/CD).

What It Does

- Validates Azure authentication

- Runs infrastructure deployment scripts

- Runs IAM configuration

- Performs post-deployment checks

- Setup Instructions

**Add Azure credentials as GitHub Secrets:**

Go to: Settings → Secrets and variables → Actions

Add:

- AZURE_CLIENT_ID

- AZURE_CLIENT_SECRET

- AZURE_TENANT_ID

- AZURE_SUBSCRIPTION_ID

Create a Service Principal:

`az ad sp create-for-rbac --name "github-actions-iam" --role contributor --scopes /subscriptions/<YOUR_SUBSCRIPTION_ID> --sdk-auth`


Push Code to Trigger Pipeline

`git add .`
`git commit -m "Initial deployment"`
`git push origin main`


The pipeline runs automatically on every push to the main branch.
Future enhancements may include automatic cleanup after successful test runs.

📸 Screenshots

Deployment and cleanup screenshots are available in:
📁 docs/screenshots/

For detailed walkthroughs with images and command outputs, see **docs/documentation.md.**


📚 What I Learned
Technical Skills

- Azure CLI automation

- IAM and RBAC implementation

- Infrastructure as Code (IaC)

- GitHub Actions CI/CD pipelines

- Bash scripting and automation

- Cloud Security Best Practices

- Principle of Least Privilege

- Group-based access management

- Automated environment cleanup

- DevOps Practices

- Automation and repeatability

- Environment lifecycle management

- Proper documentation and version control

📞 **Project Information**

- Project: IAM Roles and Secure Access Automation (Group 4)

- Technologies: Azure CLI, Bash, Azure AD, RBAC, GitHub Actions

- Region: UK South

- Created by: ifeanyi Ogbonnaya

- Date: October 2025

📄 License

This project is for educational purposes as part of a cloud computing course.

**🔗 Additional Resources**

- Azure CLI Documentation

- Azure RBAC Documentation

- GitHub Actions Documentation

- Bash Scripting Guide

For full technical walkthrough, cleanup validation, and all screenshots — see **docs/documentation.md.**