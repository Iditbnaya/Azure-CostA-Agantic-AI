# Azure Cost Management Functions - Infrastructure Deployment

This folder contains ARM JSON templates to deploy the complete Azure infrastructure needed for the Azure Cost Management solution.

## 🏗️ **What Gets Deployed**

| Resource | Purpose | Configuration |
|----------|---------|---------------|
| **Function App** | Hosts the Python cost analysis functions | Python 3.11, Linux, Consumption Plan |
| **Storage Account** | Function App storage and content | Standard LRS, HTTPS only, TLS 1.2 |
| **App Service Plan** | Hosting plan for Function App | Consumption (Y1) or Premium (EP1-EP3) |
| **Application Insights** | Monitoring and telemetry | Connected to Log Analytics |
| **Log Analytics Workspace** | Centralized logging | 30-day retention |
| **RBAC Assignments** | Managed Identity permissions | Cost Management Reader, Reader, Advisor Reader |

## 🚀 **Deployment Options**

### Option 1: Basic Infrastructure Only

Deploy just the Function App infrastructure for cost analysis functions.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FIditbnaya%2FAzure-CostA-Agantic-AI%2Fmain%2Fdeploy%2Fsimple.json" target="_blank">
<img src="https://aka.ms/deploytoazurebutton" alt="Deploy to Azure"/>
</a>

**Includes:** Function App + Storage + App Service Plan + Application Insights + Log Analytics

### Option 2: Complete AI Agent Infrastructure

Deploy Function App infrastructure plus Azure AI Foundry for agent development.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FIditbnaya%2FAzure-CostA-Agantic-AI%2Fmain%2Fdeploy%2Fsimple-with-foundry.json" target="_blank">
<img src="https://aka.ms/deploytoazurebutton" alt="Deploy to Azure"/>
</a>

**Includes:** All Basic Infrastructure + AI Foundry Hub + AI Project + Key Vault + Cognitive Services

---

## 📋 **Prerequisites**

- Azure subscription with appropriate permissions
- Resource group (will be created if it doesn't exist)
- Owner or Contributor access to the subscription for RBAC assignments

## ⚙️ **Template Parameters**

### Basic Deployment (simple.json)

| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `functionAppName` | `func-costanalysis-{env}-001` | Name of the Function App |
| `hostingPlanName` | `plan-costanalysis-{env}` | Name of the App Service Plan |
| `storageAccountName` | `sacost{env}{unique}` | Storage account (auto-generated) |
| `environment` | `prod` | Environment suffix (dev, test, prod) |
| `location` | `East US` | Azure region for deployment |
| `hostingPlanSku` | `Y1` | App Service Plan SKU |

### AI Foundry Deployment (simple-with-foundry.json)

Includes all basic parameters plus:

| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `aiHubName` | `aihub-costanalysis-{env}` | Azure AI Foundry Hub name |
| `aiProjectName` | `aiproj-costanalysis-{env}` | Azure AI Foundry Project name |
| `keyVaultName` | `kv-costanalysis-{unique}` | Key Vault for secrets |
| `cognitiveServicesName` | `cs-costanalysis-{env}` | Cognitive Services account |

## 🛠️ **Manual Deployment via Azure CLI**

### Basic Infrastructure

```bash
# Login to Azure
az login

# Create resource group
az group create --name "rg-costanalysis-prod" --location "East US"

# Deploy template
az deployment group create \
  --resource-group "rg-costanalysis-prod" \
  --template-file "simple.json" \
  --parameters "simple.parameters.json"
```

### AI Foundry Infrastructure

```bash
# Deploy enhanced template
az deployment group create \
  --resource-group "rg-costanalysis-prod" \
  --template-file "simple-with-foundry.json" \
  --parameters "simple-with-foundry.parameters.json"
```

## 🔧 **Customization**

1. **Copy parameter files:**
   ```bash
   cp simple.parameters.json my-custom.parameters.json
   ```

2. **Edit parameters:**
   - Modify resource names
   - Change SKUs and configurations
   - Adjust environment settings

3. **Deploy with custom parameters:**
   ```bash
   az deployment group create \
     --resource-group "your-rg" \
     --template-file "simple.json" \
     --parameters "@my-custom.parameters.json"
   ```

## 📁 **Files in This Folder**

- `simple.json` - Basic ARM template for Function App infrastructure
- `simple.parameters.json` - Parameters for basic deployment
- `simple-with-foundry.json` - Enhanced template with AI Foundry
- `simple-with-foundry.parameters.json` - Parameters for AI Foundry deployment
- `README.md` - This documentation

## 🎯 **Next Steps After Deployment**

1. **Basic Infrastructure:**
   - Deploy Function App code from `/function_app.py`
   - Configure environment variables in Function App settings
   - Test cost analysis endpoints

2. **AI Foundry Infrastructure:**
   - Access AI Foundry Studio via Azure portal
   - Deploy AI models to the AI Project
   - Configure agent connections between Function App and AI services
   - Set up secure communication via Key Vault
   - Get Function App Managed Identity ID (if needed):
     ```bash
     az functionapp identity show --name [FUNCTION-APP-NAME] --resource-group [RESOURCE-GROUP] --query principalId -o tsv
     ```

## 🔍 **Troubleshooting**

- **Storage account name too long:** Reduce `environment` parameter length
- **RBAC assignment failures:** Ensure deploying user has Owner/User Access Administrator role
- **AI Foundry region unavailable:** Check AI services availability in your region
- **Template validation errors:** Verify parameter file JSON syntax
- **Circular dependency errors:** Fixed in current template version - update to latest template