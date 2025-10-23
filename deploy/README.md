# Azure Cost Management Functions - Infrastructure Deployment

This folder contains Infrastructure as Code (IaC) templates and scripts to deploy the complete Azure infrastructure needed for the Azure Cost Management solution.

## 🏗️ **What Gets Deployed**

| Resource | Purpose | Configuration |
|----------|---------|---------------|
| **Function App** | Hosts the Python cost analysis functions | Python 3.11, Linux, Consumption Plan |
| **Storage Account** | Function App storage and content | Standard LRS, HTTPS only, TLS 1.2 |
| **App Service Plan** | Hosting plan for Function App | Consumption (Y1) or Premium (EP1-EP3) |
| **Application Insights** | Monitoring and telemetry | Connected to Log Analytics |
| **Log Analytics Workspace** | Centralized logging | 30-day retention |
| **RBAC Assignments** | Managed Identity permissions | Cost Management Reader, Reader, Advisor Reader |

## 🚀 **Quick Deployment**

### **Option 1: Deploy to Azure Button (Fastest)**

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FIditbnaya%2FAzure-CostA-Agantic-AI%2Fmaster%2Fdeploy%2Fsimple.bicep)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FIditbnaya%2FAzure-CostA-Agantic-AI%2Fmaster%2Fdeploy%2Fsimple.bicep)

Click the **Deploy to Azure** button above to deploy directly from GitHub to your Azure subscription using the Azure Portal. The **Visualize** button shows the infrastructure diagram.

**Parameters you'll be prompted for:**
- Subscription and Resource Group
- Region/Location (recommend: East US, West US 2, or Sweden Central)
- Environment Name (default: "prod")
- App Name (default: "costanalysis")

### **Prerequisites**
- Azure CLI installed and logged in (`az login`)
- Azure Functions Core Tools (`npm install -g azure-functions-core-tools@4`)
- PowerShell 5.1+ or PowerShell Core 7+

### **Option 2: PowerShell Script (Recommended)**
```powershell
# Navigate to your project directory
cd "c:\Apps\AzureCost\AzureCostagents\CostAgents"

# Run deployment script
.\deploy\Deploy-CostAnalysis.ps1 `
    -SubscriptionId "your-subscription-id" `
    -ResourceGroupName "rg-costanalysis-prod" `
    -Location "East US"
```

### **Option 3: Manual Azure CLI**
```bash
# Create resource group
az group create --name rg-costanalysis-prod --location "East US"

# Deploy infrastructure
az deployment group create \
    --resource-group rg-costanalysis-prod \
    --template-file deploy/main.bicep \
    --parameters deploy/main.bicepparam

# Deploy function code
func azure functionapp publish [YOUR-FUNCTION-APP-NAME]
```

## ⚙️ **Configuration Options**

### **Hosting Plans**
- **Y1 (Consumption)**: Pay-per-execution, auto-scaling, cost-effective for low-medium usage
- **EP1-EP3 (Premium)**: Pre-warmed instances, better performance, VNet integration

### **Customization**
Edit `deploy/main.bicepparam` to customize:
```bicep
param functionAppName = 'func-costanalysis-prod-001'
param skuName = 'EP1'  // Change to Premium plan
param location = 'West US 2'
param tags = {
  Environment: 'Production'
  CostCenter: 'IT-Operations'
}
```

## 🔐 **Security & Permissions**

The deployment automatically configures:

| Role | Scope | Purpose |
|------|-------|---------|
| **Cost Management Reader** | Subscription | Access cost data and billing information |
| **Reader** | Subscription | Read resource metadata and properties |
| **Advisor Reader** | Subscription | Access optimization recommendations |

### **Multi-Subscription Setup**
For tenant-wide analysis, assign roles at **Management Group** level:
```bash
# Get Management Group ID
TENANT_ID=$(az account show --query tenantId -o tsv)
MG_ID=$(az account management-group list --query "[?name=='$TENANT_ID'].name" -o tsv)

# Assign roles at Management Group level
az role assignment create \
    --assignee [FUNCTION-APP-PRINCIPAL-ID] \
    --role "Cost Management Reader" \
    --scope "/providers/Microsoft.Management/managementGroups/$MG_ID"
```

## 🧪 **Testing Your Deployment**

### **1. Test Anonymous Endpoints**
```bash
# Test example endpoint (no authentication required)
curl https://[YOUR-FUNCTION-APP].azurewebsites.net/api/example

# Test cost example endpoint
curl https://[YOUR-FUNCTION-APP].azurewebsites.net/api/cost-example
```

### **2. Test Authenticated Endpoints**
```bash
# Get function key from Azure portal or deployment output

# Test orphaned resources analysis
curl -X POST https://[YOUR-FUNCTION-APP].azurewebsites.net/api/analyze?code=[FUNCTION-KEY] \
     -H "Content-Type: application/json" \
     -d '{"subscription_id": "your-subscription-id", "resource_types": ["Public IP", "Managed Disk"]}'

# Test cost analysis
curl -X POST https://[YOUR-FUNCTION-APP].azurewebsites.net/api/cost-analysis?code=[FUNCTION-KEY] \
     -H "Content-Type: application/json" \
     -d '{"subscription_id": "your-subscription-id", "query_type": "subscription"}'
```

## 🤖 **Configure Azure AI Foundry Agents**

After deployment:

1. **Update Agent Configurations**: 
   - Replace `YOUR-FUNCTION-APP-NAME` with actual Function App name
   - Replace `YOUR-FUNCTION-KEY` with actual function keys

2. **Update Endpoints**:
   ```
   Analyze: https://[YOUR-FUNCTION-APP].azurewebsites.net/api/analyze
   Cost Analysis: https://[YOUR-FUNCTION-APP].azurewebsites.net/api/cost-analysis
   ```

## 🔍 **Monitoring & Troubleshooting**

### **Application Insights**
Monitor your functions at:
- Azure Portal → Application Insights → [app-insights-name]
- Live Metrics, Performance, Failures, Logs

### **Function Logs**
```bash
# Stream function logs
func azure functionapp logstream [FUNCTION-APP-NAME]

# Or view in Azure portal
# Azure Portal → Function App → Functions → Monitor
```

### **Common Issues**
| Issue | Solution |
|-------|----------|
| Permission errors | Verify RBAC assignments are complete |
| Rate limiting (429 errors) | Function automatically handles with retries |
| Cold start delays | Consider upgrading to Premium plan (EP1-EP3) |
| Memory issues | Increase memory allocation in Function App settings |

## 📊 **Cost Optimization**

- **Consumption Plan**: Best for sporadic usage, pay-per-execution
- **Premium Plan**: Better for frequent usage, pre-warmed instances
- **Application Insights**: Monitor to optimize performance and costs
- **Storage**: Standard LRS is sufficient for most scenarios

## 🔄 **Updates & Maintenance**

### **Update Function Code**
```bash
func azure functionapp publish [FUNCTION-APP-NAME]
```

### **Update Infrastructure**
```bash
az deployment group create \
    --resource-group [RESOURCE-GROUP] \
    --template-file deploy/main.bicep \
    --parameters deploy/main.bicepparam
```

## 📋 **Cleanup**

To remove all resources:
```bash
az group delete --name [RESOURCE-GROUP-NAME] --yes --no-wait
```

---

🎉 **Your Azure Cost Management solution is now ready to help optimize cloud costs across your organization!**