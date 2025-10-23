# Azure Cost Management Functions - Infrastructure Deployment# Azure Cost Management Functions - Infrastructure Deployment



This folder contains ARM JSON templates to deploy the complete Azure infrastructure needed for the Azure Cost Management solution.This folder contains Infrastructure as Code (IaC) templates and scripts to deploy the complete Azure infrastructure needed for the Azure Cost Management solution.



## 🏗️ **What Gets Deployed**## 🏗️ **What Gets Deployed**



| Resource | Purpose | Configuration || Resource | Purpose | Configuration |

|----------|---------|---------------||----------|---------|---------------|

| **Function App** | Hosts the Python cost analysis functions | Python 3.11, Linux, Consumption Plan || **Function App** | Hosts the Python cost analysis functions | Python 3.11, Linux, Consumption Plan |

| **Storage Account** | Function App storage and content | Standard LRS, HTTPS only, TLS 1.2 || **Storage Account** | Function App storage and content | Standard LRS, HTTPS only, TLS 1.2 |

| **App Service Plan** | Hosting plan for Function App | Consumption (Y1) or Premium (EP1-EP3) || **App Service Plan** | Hosting plan for Function App | Consumption (Y1) or Premium (EP1-EP3) |

| **Application Insights** | Monitoring and telemetry | Connected to Log Analytics || **Application Insights** | Monitoring and telemetry | Connected to Log Analytics |

| **Log Analytics Workspace** | Centralized logging | 30-day retention || **Log Analytics Workspace** | Centralized logging | 30-day retention |

| **RBAC Assignments** | Managed Identity permissions | Cost Management Reader, Reader, Advisor Reader || **RBAC Assignments** | Managed Identity permissions | Cost Management Reader, Reader, Advisor Reader |



## 📁 **Files in This Folder**## 🚀 **Quick Deployment**



- `simple.json` - ARM template for Azure infrastructure### **Option 1: Deploy to Azure Button (Fastest)**

- `simple.parameters.json` - Parameter values for the template

- `README.md` - This deployment guide[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FIditbnaya%2FAzure-CostA-Agantic-AI%2Fmain%2Fdeploy%2Fsimple.json)



## 🚀 **Deployment Options**[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FIditbnaya%2FAzure-CostA-Agantic-AI%2Fmain%2Fdeploy%2Fsimple.json)



### **Option 1: Deploy to Azure Button (Fastest)**Click the **Deploy to Azure** button above to deploy directly from GitHub to your Azure subscription using the Azure Portal. The **Visualize** button shows the infrastructure diagram.



[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FIditbnaya%2FAzure-CostA-Agantic-AI%2Fmain%2Fdeploy%2Fsimple.json)**Parameters you'll be prompted for:**



[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FIditbnaya%2FAzure-CostA-Agantic-AI%2Fmain%2Fdeploy%2Fsimple.json)- Subscription and Resource Group

- Region/Location (recommend: East US, West US 2, or Sweden Central)

Click the **Deploy to Azure** button above to deploy directly from GitHub to your Azure subscription using the Azure Portal.- Environment Name (default: "prod")



### **Prerequisites**### **Prerequisites**



- Azure CLI installed and logged in (`az login`)- Azure CLI installed and logged in (`az login`)

- Azure Functions Core Tools (`npm install -g azure-functions-core-tools@4`)- Azure Functions Core Tools (`npm install -g azure-functions-core-tools@4`)

- PowerShell 5.1+ or PowerShell Core 7+

### **Option 2: Azure CLI Deployment**

### **Option 2: Quick PowerShell Script (Recommended)**

```bash

# Create resource group```powershell

az group create --name rg-costanalysis-prod --location "East US"# Navigate to your project directory

cd "c:\Apps\AgenticAI\deploy"

# Deploy using JSON template with parameters

az deployment group create \# Run quick deployment script (creates resource group and deploys everything)

    --resource-group rg-costanalysis-prod \.\quick-deploy.ps1 -SubscriptionId "your-subscription-id"

    --template-file deploy/simple.json \

    --parameters deploy/simple.parameters.json# Or specify custom location and environment

.\quick-deploy.ps1 `

# Deploy function code    -SubscriptionId "your-subscription-id" `

func azure functionapp publish [YOUR-FUNCTION-APP-NAME]    -Location "West US 2" `

```    -Environment "dev"

```

### **Option 3: PowerShell Deployment**

### **Option 3: Full PowerShell Script (Advanced)**

```powershell```powershell

# Create resource group# Create resource group first

az group create --name "rg-costanalysis-prod" --location "East US"az group create --name "rg-costanalysis-prod" --location "East US"



# Deploy infrastructure# Run deployment script

az deployment group create `.\Deploy-CostAnalysis.ps1 `

    --resource-group "rg-costanalysis-prod" `    -ResourceGroupName "rg-costanalysis-prod" `

    --template-file "deploy/simple.json" `    -Environment "prod"

    --parameters "deploy/simple.parameters.json"```



# Deploy function code### **Option 4: Manual Azure CLI**

func azure functionapp publish [YOUR-FUNCTION-APP-NAME]```bash

```# Create resource group

az group create --name rg-costanalysis-prod --location "East US"

## ⚙️ **Customization**

# Deploy infrastructure using simple template

Edit `deploy/simple.parameters.json` to customize your deployment:az deployment group create \

    --resource-group rg-costanalysis-prod \

```json    --template-file deploy/simple.bicep \

{    --parameters environment=prod location="East US"

  "functionAppName": {

    "value": "func-costanalysis-prod-001"# Or deploy using full template with parameters file

  },az deployment group create \

  "environment": {    --resource-group rg-costanalysis-prod \

    "value": "prod"    --template-file deploy/main.bicep \

  },    --parameters deploy/main.bicepparam

  "location": {

    "value": "East US"# Deploy function code

  },func azure functionapp publish [YOUR-FUNCTION-APP-NAME]

  "skuName": {```

    "value": "Y1"

  }## ⚙️ **Configuration Options**

}

```### **Hosting Plans**

- **Y1 (Consumption)**: Pay-per-execution, auto-scaling, cost-effective for low-medium usage

**Hosting Plans:**- **EP1-EP3 (Premium)**: Pre-warmed instances, better performance, VNet integration

- **Y1 (Consumption)**: Pay-per-execution, auto-scaling, cost-effective for low-medium usage

- **EP1-EP3 (Premium)**: Pre-warmed instances, better performance, VNet integration### **Customization**

Edit `deploy/main.bicepparam` to customize:

## 🔐 **Security & Permissions**```bicep

param functionAppName = 'func-costanalysis-prod-001'

The deployment automatically configures:param skuName = 'EP1'  // Change to Premium plan

param location = 'West US 2'

| Role | Scope | Purpose |param tags = {

|------|-------|---------|  Environment: 'Production'

| **Cost Management Reader** | Subscription | Access cost data and billing information |  CostCenter: 'IT-Operations'

| **Reader** | Subscription | Read resource metadata and properties |}

| **Advisor Reader** | Subscription | Access optimization recommendations |```



### **Multi-Subscription Setup**## 🔐 **Security & Permissions**



For tenant-wide analysis, assign roles at **Management Group** level:The deployment automatically configures:



```bash| Role | Scope | Purpose |

# Get Management Group ID|------|-------|---------|

TENANT_ID=$(az account show --query tenantId -o tsv)| **Cost Management Reader** | Subscription | Access cost data and billing information |

MG_ID=$(az account management-group list --query "[?name=='$TENANT_ID'].name" -o tsv)| **Reader** | Subscription | Read resource metadata and properties |

| **Advisor Reader** | Subscription | Access optimization recommendations |

# Assign roles at Management Group level

az role assignment create \### **Multi-Subscription Setup**

    --assignee [FUNCTION-APP-PRINCIPAL-ID] \For tenant-wide analysis, assign roles at **Management Group** level:

    --role "Cost Management Reader" \```bash

    --scope "/providers/Microsoft.Management/managementGroups/$MG_ID"# Get Management Group ID

```TENANT_ID=$(az account show --query tenantId -o tsv)

MG_ID=$(az account management-group list --query "[?name=='$TENANT_ID'].name" -o tsv)

## 🧪 **Testing Your Deployment**

# Assign roles at Management Group level

### **1. Test Anonymous Endpoints**az role assignment create \

    --assignee [FUNCTION-APP-PRINCIPAL-ID] \

```bash    --role "Cost Management Reader" \

# Test example endpoint (no authentication required)    --scope "/providers/Microsoft.Management/managementGroups/$MG_ID"

curl https://[YOUR-FUNCTION-APP].azurewebsites.net/api/example```



# Test cost example endpoint## 🧪 **Testing Your Deployment**

curl https://[YOUR-FUNCTION-APP].azurewebsites.net/api/cost-example

```### **1. Test Anonymous Endpoints**

```bash

### **2. Test Authenticated Endpoints**# Test example endpoint (no authentication required)

curl https://[YOUR-FUNCTION-APP].azurewebsites.net/api/example

```bash

# Get function key from Azure portal or deployment output# Test cost example endpoint

curl https://[YOUR-FUNCTION-APP].azurewebsites.net/api/cost-example

# Test orphaned resources analysis```

curl -X POST https://[YOUR-FUNCTION-APP].azurewebsites.net/api/analyze?code=[FUNCTION-KEY] \

     -H "Content-Type: application/json" \### **2. Test Authenticated Endpoints**

     -d '{"subscription_id": "your-subscription-id", "resource_types": ["Public IP", "Managed Disk"]}'```bash

# Get function key from Azure portal or deployment output

# Test cost analysis

curl -X POST https://[YOUR-FUNCTION-APP].azurewebsites.net/api/cost-analysis?code=[FUNCTION-KEY] \# Test orphaned resources analysis

     -H "Content-Type: application/json" \curl -X POST https://[YOUR-FUNCTION-APP].azurewebsites.net/api/analyze?code=[FUNCTION-KEY] \

     -d '{"subscription_id": "your-subscription-id", "query_type": "subscription"}'     -H "Content-Type: application/json" \

```     -d '{"subscription_id": "your-subscription-id", "resource_types": ["Public IP", "Managed Disk"]}'



## 🤖 **Configure Azure AI Foundry Agents**# Test cost analysis

curl -X POST https://[YOUR-FUNCTION-APP].azurewebsites.net/api/cost-analysis?code=[FUNCTION-KEY] \

After deployment:     -H "Content-Type: application/json" \

     -d '{"subscription_id": "your-subscription-id", "query_type": "subscription"}'

1. **Update Agent Configurations:**```

   - Replace `YOUR-FUNCTION-APP-NAME` with actual Function App name

   - Replace `YOUR-FUNCTION-KEY` with actual function keys## 🤖 **Configure Azure AI Foundry Agents**



2. **Update Endpoints:**After deployment:



   ```1. **Update Agent Configurations**: 

   Analyze: https://[YOUR-FUNCTION-APP].azurewebsites.net/api/analyze   - Replace `YOUR-FUNCTION-APP-NAME` with actual Function App name

   Cost Analysis: https://[YOUR-FUNCTION-APP].azurewebsites.net/api/cost-analysis   - Replace `YOUR-FUNCTION-KEY` with actual function keys

   ```

2. **Update Endpoints**:

## 🔍 **Monitoring & Troubleshooting**   ```

   Analyze: https://[YOUR-FUNCTION-APP].azurewebsites.net/api/analyze

### **Application Insights**   Cost Analysis: https://[YOUR-FUNCTION-APP].azurewebsites.net/api/cost-analysis

   ```

Monitor your functions at:

- Azure Portal → Application Insights → [app-insights-name]## 🔍 **Monitoring & Troubleshooting**

- Live Metrics, Performance, Failures, Logs

### **Application Insights**

### **Function Logs**Monitor your functions at:

- Azure Portal → Application Insights → [app-insights-name]

```bash- Live Metrics, Performance, Failures, Logs

# Stream function logs

func azure functionapp logstream [FUNCTION-APP-NAME]### **Function Logs**

```bash

# Or view in Azure portal# Stream function logs

# Azure Portal → Function App → Functions → Monitorfunc azure functionapp logstream [FUNCTION-APP-NAME]

```

# Or view in Azure portal

### **Common Issues**# Azure Portal → Function App → Functions → Monitor

```

| Issue | Solution |

|-------|----------|### **Common Issues**

| Permission errors | Verify RBAC assignments are complete || Issue | Solution |

| Rate limiting (429 errors) | Function automatically handles with retries ||-------|----------|

| Cold start delays | Consider upgrading to Premium plan (EP1-EP3) || Permission errors | Verify RBAC assignments are complete |

| Memory issues | Increase memory allocation in Function App settings || Rate limiting (429 errors) | Function automatically handles with retries |

| Cold start delays | Consider upgrading to Premium plan (EP1-EP3) |

## 📊 **Cost Optimization**| Memory issues | Increase memory allocation in Function App settings |



- **Consumption Plan**: Best for sporadic usage, pay-per-execution## 📊 **Cost Optimization**

- **Premium Plan**: Better for frequent usage, pre-warmed instances

- **Application Insights**: Monitor to optimize performance and costs- **Consumption Plan**: Best for sporadic usage, pay-per-execution

- **Storage**: Standard LRS is sufficient for most scenarios- **Premium Plan**: Better for frequent usage, pre-warmed instances

- **Application Insights**: Monitor to optimize performance and costs

## 🔄 **Updates & Maintenance**- **Storage**: Standard LRS is sufficient for most scenarios



### **Update Function Code**## 🔄 **Updates & Maintenance**



```bash### **Update Function Code**

func azure functionapp publish [FUNCTION-APP-NAME]```bash

```func azure functionapp publish [FUNCTION-APP-NAME]

```

### **Update Infrastructure**

### **Update Infrastructure**

```bash```bash

az deployment group create \az deployment group create \

    --resource-group [RESOURCE-GROUP] \    --resource-group [RESOURCE-GROUP] \

    --template-file deploy/simple.json \    --template-file deploy/main.bicep \

    --parameters deploy/simple.parameters.json    --parameters deploy/main.bicepparam

``````



## 📋 **Cleanup**## 📋 **Cleanup**



To remove all resources:To remove all resources:

```bash

```bashaz group delete --name [RESOURCE-GROUP-NAME] --yes --no-wait

az group delete --name [RESOURCE-GROUP-NAME] --yes --no-wait```

```

---

---

🎉 **Your Azure Cost Management solution is now ready to help optimize cloud costs across your organization!**
🎉 **Your Azure Cost Management solution is now ready to help optimize cloud costs across your organization!**