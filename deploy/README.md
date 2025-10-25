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

**Includes:** All Basic Infrastructure + AI Foundry Hub + AI Project + Key Vault

**Note:** Models (GPT-4, GPT-3.5) are available through AI Foundry - no separate Cognitive Services needed!

---

## 📋 **Prerequisites**

### Required Parameters
Before deployment, you must provide names for all resources. The templates do not include default values to ensure you can customize resource names according to your organization's naming conventions.

**Required Resource Names:**

### Basic Template (simple.json):
- **Function App Name**: Must be globally unique (e.g., `func-costanalysis-yourorg-01`)
- **Hosting Plan Name**: Can be regional unique (e.g., `plan-costanalysis-prod`)
- **Storage Account Name**: Auto-generated (e.g., `sacostprodabc123def`)

### AI Foundry Template (simple-with-foundry.json):
- **Function App Name**: Must be globally unique (e.g., `func-costanalysis-yourorg-01`)
- **Hosting Plan Name**: Can be regional unique (e.g., `plan-costanalysis-prod`)  
- **Storage Account Name**: Auto-generated (e.g., `sacostprodabc123def`)
- **AI Hub Name**: Must be globally unique (e.g., `aihub-costanalysis-yourorg`)
- **AI Project Name**: Must be unique within the hub (e.g., `aiproj-costanalysis-yourorg`)
- **Key Vault Name**: Must be globally unique (e.g., `kv-costanalysis-yourorg`)

**Note:** AI models (GPT-4, GPT-3.5) are included in AI Foundry - no separate Cognitive Services required!

### Naming Convention Guidelines
- **Function App**: Use format `func-<solution>-<environment>-<instance>` (e.g., `func-costanalysis-prod-01`)
- **Storage Account**: Use format `sa<solution><environment><instance>` (e.g., `sacostanalysisprod01`)
- **AI Services**: Use format `<prefix>-<solution>-<environment>` (e.g., `aihub-costanalysis-prod`)

### Regional Considerations

**Important:** Some Azure services have limited regional availability. For best compatibility:
- Use **East US**, **West US 2**, or **West Europe** for all services
- Cognitive Services may not be available in all regions (e.g., Israel Central)
- The template includes separate location parameters for services with different availability

### Parameter Files

This repository includes example parameter files:
- `simple.parameters.json` - Example values for basic infrastructure
- `simple-with-foundry.parameters.json` - Example values for AI Foundry infrastructure

**⚠️ Important:** Replace all placeholder values (e.g., "YOUR-FUNCTION-APP-NAME") with your actual resource names before deployment.

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
| `cognitiveServicesName` | `cscostanalysis{env}` | Cognitive Services account (alphanumeric only) |
| `cognitiveServicesLocation` | `eastus` | Location for Cognitive Services (must be supported region) |

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
- **Cognitive Services region error:** Use `cognitiveServicesLocation` parameter to specify a supported region (eastus, westus2, westeurope, etc.)
- **Cognitive Services name error:** Account name must be alphanumeric only (no hyphens) and 2-64 characters
- **Template validation errors:** Verify parameter file JSON syntax
- **Circular dependency errors:** Fixed in current template version - update to latest template