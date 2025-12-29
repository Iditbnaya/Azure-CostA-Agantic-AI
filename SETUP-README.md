# 🚀 Quick Setup Guide

This folder contains everything you need to deploy the Azure Cost Management & Orphaned Resources Analyzer solution.

## 📁 Setup Documentation

| File | Purpose |
|------|---------|
| **[SETUP-FUNCTIONS.md](SETUP-FUNCTIONS.md)** | **Azure Functions deployment guide** (infrastructure + backend) |
| **[SETUP-FOUNDRY.md](SETUP-FOUNDRY.md)** | **Azure AI Foundry agent deployment guide** |
| `setup.ps1` | Automated PowerShell deployment script for Functions |
| `SETUP-README.md` | This overview guide |
| `README.md` | Project overview and documentation |

## 🎯 Deployment Path

The solution has two main components that should be deployed in order:

### 1️⃣ Azure Functions Backend
Deploy the backend infrastructure and API endpoints first.

👉 **[Follow SETUP-FUNCTIONS.md](SETUP-FUNCTIONS.md)** for complete instructions

### 2️⃣ Azure AI Foundry Agents
Configure intelligent agents after the backend is deployed.

👉 **[Follow SETUP-FOUNDRY.md](SETUP-FOUNDRY.md)** for complete instructions

## ⚡ Quick Start

### Prerequisites

- [ ] Azure CLI installed and logged in
- [ ] PowerShell 5.1 or PowerShell Core  
- [ ] Python 3.11 installed
- [ ] Azure Functions Core Tools v4
- [ ] Access to Azure AI Foundry (for agent deployment)

### Deployment Steps

#### Step 1: Deploy Azure Functions Backend ⚡

```powershell
# Navigate to repository
cd Azure-CostA-Agantic-AI

# Run automated Functions deployment
.\setup.ps1 -ResourceGroupName "rg-cost-analyzer-prod" -Location "eastus2"
```

**What gets deployed:**
- ✅ Azure Resource Group
- ✅ Storage Account
- ✅ Function App with Python 3.11
- ✅ Application Insights
- ✅ Managed Identity with RBAC permissions
- ✅ Function code deployment

For detailed instructions, see **[SETUP-FUNCTIONS.md](SETUP-FUNCTIONS.md)**

#### Step 2: Configure AI Foundry Agents 🤖

After the Functions deployment completes:

1. Collect Function App URL and Master Key
2. Update agent configuration files with your deployment details
3. Deploy agents in Azure AI Foundry

For detailed instructions, see **[SETUP-FOUNDRY.md](SETUP-FOUNDRY.md)**

## 📊 What You Get

### Azure Functions Backend
- **Four API endpoints** for cost analysis and orphaned resource detection
- **Managed Identity** with least-privilege permissions
- **Application Insights** monitoring and logging
- **Secure authentication** with function keys

### AI Foundry Agents
- **Orphaned Resources Analyzer** - Intelligent resource waste detection
- **Cost Analysis Agent** - Smart cost insights and recommendations
- **Multi-agent workflows** - Coordinated analysis capabilities
- **Natural language interface** - Easy-to-use conversational agents

## 🆘 Need Help?

### Functions Deployment Issues
- Check PowerShell execution policy
- Verify Azure CLI login and permissions
- Review [SETUP-FUNCTIONS.md](SETUP-FUNCTIONS.md) troubleshooting section

### AI Foundry Configuration Issues  
- Verify Function App is running
- Confirm function keys are correct
- Review [SETUP-FOUNDRY.md](SETUP-FOUNDRY.md) troubleshooting section

### Additional Resources
- **[README.md](README.md)** - Project overview
- **[functiondeploymentcommands.md](functiondeploymentcommands.md)** - Command reference
- **[WORKING_COMMANDS.md](WORKING_COMMANDS.md)** - Verified commands

## 🎯 Next Steps After Deployment

- [ ] Test all function endpoints
- [ ] Verify agents in AI Foundry Playground
- [ ] Set up monitoring alerts in Azure Monitor
- [ ] Configure scheduled agent runs
- [ ] Train your team on using the solution
- [ ] Review security best practices

---

## 🚀 Ready to Deploy?

1. **Start here**: [SETUP-FUNCTIONS.md](SETUP-FUNCTIONS.md) - Deploy backend infrastructure
2. **Then continue**: [SETUP-FOUNDRY.md](SETUP-FOUNDRY.md) - Configure AI agents

Both guides provide automated and manual deployment options! ✨