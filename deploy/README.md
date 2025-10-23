# Azure Cost Management Functions - Infrastructure Deployment# Azure Cost Management Functions - Infrastructure Deployment# Azure Cost Management Functions - Infrastructure Deployment



This folder contains ARM JSON templates to deploy the complete Azure infrastructure needed for the Azure Cost Management solution.



## 🏗️ **What Gets Deployed**This folder contains ARM JSON templates to deploy the complete Azure infrastructure needed for the Azure Cost Management solution.This folder contains Infrastructure as Code (IaC) templates and scripts to deploy the complete Azure infrastructure needed for the Azure Cost Management solution.



| Resource | Purpose | Configuration |

|----------|---------|---------------|

| **Function App** | Hosts the Python cost analysis functions | Python 3.11, Linux, Consumption Plan |## 🏗️ **What Gets Deployed**## 

| **Storage Account** | Function App storage and content | Standard LRS, HTTPS only, TLS 1.2 |

| **App Service Plan** | Hosting plan for Function App | Consumption (Y1) or Premium (EP1-EP3) |

| **Application Insights** | Monitoring and telemetry | Connected to Log Analytics |

| **Log Analytics Workspace** | Centralized logging | 30-day retention || Resource | Purpose | Configuration ||

| **RBAC Assignments** | Managed Identity permissions | Cost Management Reader, Reader, Advisor Reader |

|----------|---------|---------------||

## 📁 **Files in This Folder**

| **Function App** | Hosts the Python cost analysis functions | Python 3.11, Linux, Consumption Plan ||

- `simple.json` - ARM template for Azure infrastructure

- `simple.parameters.json` - Parameter values for the template| **Storage Account** | Function App storage and content | Standard LRS, HTTPS only, TLS 1.2 ||

- `README.md` - This deployment guide

| **App Service Plan** | Hosting plan for Function App | Consumption (Y1) or Premium (EP1-EP3) ||

## 🚀 **Deployment Options**

| **Application Insights** | Monitoring and telemetry | Connected to Log Analytics ||

### **Option 1: Deploy to Azure Button (Fastest)**

| **Log Analytics Workspace** | Centralized logging | 30-day retention || **Log Analytics Workspace** | Centralized logging | 30-day retention |

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FIditbnaya%2FAzure-CostA-Agantic-AI%2Fmain%2Fdeploy%2Fsimple.json" target="_blank">

<img src="https://aka.ms/deploytoazurebutton" alt="Deploy to Azure"/>| **RBAC Assignments** | Managed Identity permissions | Cost Management Reader, Reader, Advisor Reader ||

</a>



<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FIditbnaya%2FAzure-CostA-Agantic-AI%2Fmain%2Fdeploy%2Fsimple.json" target="_blank">

<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true" alt="Visualize"/>## 📁 **Files in This Folder**## 🚀 **Quick Deployment**

</a>



Click the **Deploy to Azure** button above to deploy directly from GitHub to your Azure subscription using the Azure Portal. The **Visualize** button shows the infrastructure diagram.

- `simple.json` - ARM template for Azure infrastructure### **Option 1: Deploy to Azure Button (Fastest)**

**Parameters you'll be prompted for:**

- `simple.parameters.json` - Parameter values for the template

- Subscription and Resource Group

- Region/Location (recommend: East US, West US 2, or Sweden Central)- `README.md` - This deployment guide[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FIditbnaya%2FAzure-CostA-Agantic-AI%2Fmain%2Fdeploy%2Fsimple.json)

- Environment Name (default: "prod")



### **Prerequisites**

## 🚀 **Deployment Options**[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FIditbnaya%2FAzure-CostA-Agantic-AI%2Fmain%2Fdeploy%2Fsimple.json)

- Azure CLI installed and logged in (`az login`)

- Azure Functions Core Tools (`npm install -g azure-functions-core-tools@4`)



### **Option 2: Azure CLI Deployment**### **Option 1: Deploy to Azure Button (Fastest)**Click the **Deploy to Azure** button above to deploy directly from GitHub to your Azure subscription using the Azure Portal. The **Visualize** button shows the infrastructure diagram.



```bash

# Create resource group

az group create --name rg-costanalysis-prod --location "East US"[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FIditbnaya%2FAzure-CostA-Agantic-AI%2Fmain%2Fdeploy%2Fsimple.json)**Parameters you'll be prompted for:**



# Deploy using JSON template with parameters

az deployment group create \

    --resource-group rg-costanalysis-prod \[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FIditbnaya%2FAzure-CostA-Agantic-AI%2Fmain%2Fdeploy%2Fsimple.json)- Subscription and Resource Group

    --template-file deploy/simple.json \

    --parameters deploy/simple.parameters.json- Region/Location (recommend: East US, West US 2, or Sweden Central)



# Deploy function codeClick the **Deploy to Azure** button above to deploy directly from GitHub to your Azure subscription using the Azure Portal.- Environment Name (default: "prod")

func azure functionapp publish [YOUR-FUNCTION-APP-NAME]

```



### **Option 3: PowerShell Deployment**### **Prerequisites**### **Prerequisites**



```powershell

# Create resource group

az group create --name "rg-costanalysis-prod" --location "East US"- Azure CLI installed and logged in (`az login`)- Azure CLI installed and logged in (`az login`)



# Deploy infrastructure- Azure Functions Core Tools (`npm install -g azure-functions-core-tools@4`)- Azure Functions Core Tools (`npm install -g azure-functions-core-tools@4`)

az deployment group create `

    --resource-group "rg-costanalysis-prod" `- PowerShell 5.1+ or PowerShell Core 7+

    --template-file "deploy/simple.json" `

    --parameters "deploy/simple.parameters.json"### **Option 2: Azure CLI Deployment**



# Deploy function code### **Option 2: Quick PowerShell Script (Recommended)**

func azure functionapp publish [YOUR-FUNCTION-APP-NAME]

``````bash



## ⚙️ **Customization**# Create resource group```powershell



Edit `deploy/simple.parameters.json` to customize your deployment:az group create --name rg-costanalysis-prod --location "East US"# Navigate to your project directory



```jsoncd "c:\Apps\AgenticAI\deploy"

{

  "functionAppName": {# Deploy using JSON template with parameters

    "value": "func-costanalysis-prod-001"

  },az deployment group create \# Run quick deployment script (creates resource group and deploys everything)

  "environment": {

    "value": "prod"    --resource-group rg-costanalysis-prod \.\quick-deploy.ps1 -SubscriptionId "your-subscription-id"

  },

  "location": {    --template-file deploy/simple.json \

    "value": "East US"

  },    --parameters deploy/simple.parameters.json# Or specify custom location and environment

  "skuName": {

    "value": "Y1".\quick-deploy.ps1 `

  }

}# Deploy function code    -SubscriptionId "your-subscription-id" `

```

func azure functionapp publish [YOUR-FUNCTION-APP-NAME]    -Location "West US 2" `

**Hosting Plans:**

```    -Environment "dev"

- **Y1 (Consumption)**: Pay-per-execution, auto-scaling, cost-effective for low-medium usage

- **EP1-EP3 (Premium)**: Pre-warmed instances, better performance, VNet integration```



## 🔐 **Security & Permissions**### **Option 3: PowerShell Deployment**



The deployment automatically configures:### **Option 3: Full PowerShell Script (Advanced)**



| Role | Scope | Purpose |```powershell```powershell

|------|-------|---------|

| **Cost Management Reader** | Subscription | Access cost data and billing information |# Create resource group# Create resource group first

| **Reader** | Subscription | Read resource metadata and properties |

| **Advisor Reader** | Subscription | Access optimization recommendations |az group create --name "rg-costanalysis-prod" --location "East US"az group create --name "rg-costanalysis-prod" --location "East US"



### **Multi-Subscription Setup**



For tenant-wide analysis, assign roles at **Management Group** level:# Deploy infrastructure# Run deployment script



```bashaz deployment group create `.\Deploy-CostAnalysis.ps1 `

# Get Management Group ID

TENANT_ID=$(az account show --query tenantId -o tsv)    --resource-group "rg-costanalysis-prod" `    -ResourceGroupName "rg-costanalysis-prod" `

MG_ID=$(az account management-group list --query "[?name=='$TENANT_ID'].name" -o tsv)

    --template-file "deploy/simple.json" `    -Environment "prod"

# Assign roles at Management Group level

az role assignment create \    --parameters "deploy/simple.parameters.json"```

    --assignee [FUNCTION-APP-PRINCIPAL-ID] \

    --role "Cost Management Reader" \

    --scope "/providers/Microsoft.Management/managementGroups/$MG_ID"

```# Deploy function code### **Option 4: Manual Azure CLI**



## 🧪 **Testing Your Deployment**func azure functionapp publish [YOUR-FUNCTION-APP-NAME]```bash



### **1. Test Anonymous Endpoints**```# Create resource group



```bashaz group create --name rg-costanalysis-prod --location "East US"

# Test example endpoint (no authentication required)

curl https://[YOUR-FUNCTION-APP].azurewebsites.net/api/example## ⚙️ **Customization**



# Test cost example endpoint# Deploy infrastructure using simple template

curl https://[YOUR-FUNCTION-APP].azurewebsites.net/api/cost-example

```Edit `deploy/simple.parameters.json` to customize your deployment:az deployment group create \



### **2. Test Authenticated Endpoints**    --resource-group rg-costanalysis-prod \



```bash```json    --template-file deploy/simple.bicep \

# Get function key from Azure portal or deployment output

{    --parameters environment=prod location="East US"

# Test orphaned resources analysis

curl -X POST https://[YOUR-FUNCTION-APP].azurewebsites.net/api/analyze?code=[FUNCTION-KEY] \  "functionAppName": {

     -H "Content-Type: application/json" \

     -d '{"subscription_id": "your-subscription-id", "resource_types": ["Public IP", "Managed Disk"]}'    "value": "func-costanalysis-prod-001"# Or deploy using full template with parameters file



# Test cost analysis  },az deployment group create \

curl -X POST https://[YOUR-FUNCTION-APP].azurewebsites.net/api/cost-analysis?code=[FUNCTION-KEY] \

     -H "Content-Type: application/json" \  "environment": {    --resource-group rg-costanalysis-prod \

     -d '{"subscription_id": "your-subscription-id", "query_type": "subscription"}'

```    "value": "prod"    --template-file deploy/main.bicep \



## 🤖 **Configure Azure AI Foundry Agents**  },    --parameters deploy/main.bicepparam



After deployment:  "location": {



1. **Update Agent Configurations:**    "value": "East US"# Deploy function code

   - Replace `YOUR-FUNCTION-APP-NAME` with actual Function App name

   - Replace `YOUR-FUNCTION-KEY` with actual function keys  },func azure functionapp publish [YOUR-FUNCTION-APP-NAME]



2. **Update Endpoints:**  "skuName": {```



   ```    "value": "Y1"

   Analyze: https://[YOUR-FUNCTION-APP].azurewebsites.net/api/analyze

   Cost Analysis: https://[YOUR-FUNCTION-APP].azurewebsites.net/api/cost-analysis  }## ⚙️ **Configuration Options**

   ```

}

## 🔍 **Monitoring & Troubleshooting**

```### **Hosting Plans**

### **Application Insights**

- **Y1 (Consumption)**: Pay-per-execution, auto-scaling, cost-effective for low-medium usage

Monitor your functions at:

- Azure Portal → Application Insights → [app-insights-name]**Hosting Plans:**- **EP1-EP3 (Premium)**: Pre-warmed instances, better performance, VNet integration

- Live Metrics, Performance, Failures, Logs

- **Y1 (Consumption)**: Pay-per-execution, auto-scaling, cost-effective for low-medium usage

### **Function Logs**

- **EP1-EP3 (Premium)**: Pre-warmed instances, better performance, VNet integration### **Customization**

```bash

# Stream function logsEdit `deploy/main.bicepparam` to customize:

func azure functionapp logstream [FUNCTION-APP-NAME]

## 🔐 **Security & Permissions**```bicep

# Or view in Azure portal

# Azure Portal → Function App → Functions → Monitorparam functionAppName = 'func-costanalysis-prod-001'

```

The deployment automatically configures:param skuName = 'EP1'  // Change to Premium plan

### **Common Issues**

param location = 'West US 2'

| Issue | Solution |

|-------|----------|| Role | Scope | Purpose |param tags = {

| Permission errors | Verify RBAC assignments are complete |

| Rate limiting (429 errors) | Function automatically handles with retries ||------|-------|---------|  Environment: 'Production'

| Cold start delays | Consider upgrading to Premium plan (EP1-EP3) |

| Memory issues | Increase memory allocation in Function App settings || **Cost Management Reader** | Subscription | Access cost data and billing information |  CostCenter: 'IT-Operations'



## 📊 **Cost Optimization**| **Reader** | Subscription | Read resource metadata and properties |}



- **Consumption Plan**: Best for sporadic usage, pay-per-execution| **Advisor Reader** | Subscription | Access optimization recommendations |```

- **Premium Plan**: Better for frequent usage, pre-warmed instances

- **Application Insights**: Monitor to optimize performance and costs

- **Storage**: Standard LRS is sufficient for most scenarios

### **Multi-Subscription Setup**## 🔐 **Security & Permissions**

## 🔄 **Updates & Maintenance**



### **Update Function Code**

For tenant-wide analysis, assign roles at **Management Group** level:The deployment automatically configures:

```bash

func azure functionapp publish [FUNCTION-APP-NAME]

```

```bash| Role | Scope | Purpose |

### **Update Infrastructure**

# Get Management Group ID|------|-------|---------|

```bash

az deployment group create \TENANT_ID=$(az account show --query tenantId -o tsv)| **Cost Management Reader** | Subscription | Access cost data and billing information |

    --resource-group [RESOURCE-GROUP] \

    --template-file deploy/simple.json \MG_ID=$(az account management-group list --query "[?name=='$TENANT_ID'].name" -o tsv)| **Reader** | Subscription | Read resource metadata and properties |

    --parameters deploy/simple.parameters.json

```| **Advisor Reader** | Subscription | Access optimization recommendations |



## 📋 **Cleanup**# Assign roles at Management Group level



To remove all resources:az role assignment create \### **Multi-Subscription Setup**



```bash    --assignee [FUNCTION-APP-PRINCIPAL-ID] \For tenant-wide analysis, assign roles at **Management Group** level:

az group delete --name [RESOURCE-GROUP-NAME] --yes --no-wait

```    --role "Cost Management Reader" \```bash



---    --scope "/providers/Microsoft.Management/managementGroups/$MG_ID"# Get Management Group ID



🎉 **Your Azure Cost Management solution is now ready to help optimize cloud costs across your organization!**```TENANT_ID=$(az account show --query tenantId -o tsv)

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