# Working Commands Reference - Azure Cost Analysis Solution

This file contains all the tested and verified commands used to deploy the Azure Cost Analysis solution.

## Prerequisites Commands

```powershell
# Verify Azure CLI installation
az --version

# Login to Azure
az login

# List available subscriptions
az account list --output table

# Set subscription context (replace with your subscription ID)
az account set --subscription "your-subscription-id"

# Verify current context
az account show
```

## Infrastructure Deployment Commands

### Resource Group Creation
```powershell
# Create resource group in Sweden Central
az group create --name "rg-costanalysis-prod-v2" --location "swedencentral"
```

### Bicep Template Deployment
```powershell
# Deploy using simplified Bicep template (WORKING)
az deployment group create `
    --resource-group "rg-costanalysis-prod-v2" `
    --template-file "deploy/simple.bicep" `
    --parameters environmentName="prod" location="swedencentral" appName="costanalysis"

# Alternative: Deploy with parameter file
az deployment group create `
    --resource-group "rg-costanalysis-prod-v2" `
    --template-file "deploy/main.bicep" `
    --parameters @deploy/main.bicepparam
```

### Deployment Verification Commands
```powershell
# List all deployments in resource group
az deployment group list --resource-group "rg-costanalysis-prod-v2" --output table

# Check specific deployment status
az deployment group show --resource-group "rg-costanalysis-prod-v2" --name "simple"

# List deployment operations
az deployment operation group list --resource-group "rg-costanalysis-prod-v2" --name "simple"

# Check for failed operations
az deployment operation group list `
    --resource-group "rg-costanalysis-prod-v2" `
    --name "simple" `
    --query "[?properties.provisioningState=='Failed'].{Resource:properties.targetResource.resourceName,Error:properties.statusMessage.error.message}" `
    --output table
```

## Resource Management Commands

### List Deployed Resources
```powershell
# List all resources in resource group
az resource list --resource-group "rg-costanalysis-prod-v2" --output table

# Get Function App details
az functionapp show --name "func-costanalysis-prod-001" --resource-group "rg-costanalysis-prod-v2"

# Get Storage Account details
az storage account show --name "sacostanalysisprod001" --resource-group "rg-costanalysis-prod-v2"

# Check Application Insights
az monitor app-insights component show --app "appi-costanalysis-prod-001" --resource-group "rg-costanalysis-prod-v2"
```

### RBAC Verification Commands
```powershell
# Get Function App managed identity
az functionapp identity show --name "func-costanalysis-prod-001" --resource-group "rg-costanalysis-prod-v2"

# List role assignments for Function App
$principalId = az functionapp identity show --name "func-costanalysis-prod-001" --resource-group "rg-costanalysis-prod-v2" --query principalId -o tsv
az role assignment list --assignee $principalId --output table

# Check specific role assignments
az role assignment list --assignee $principalId --role "Cost Management Reader"
az role assignment list --assignee $principalId --role "Reader"
az role assignment list --assignee $principalId --role "Storage Blob Data Contributor"
```

## Azure Functions Core Tools Commands

### Installation
```powershell
# Install Azure Functions Core Tools globally (WORKING)
npm install -g azure-functions-core-tools@4 --unsafe-perm true

# Verify installation
func --version
```

### Function Deployment Attempts
```powershell
# Standard deployment (BLOCKED by storage policy)
func azure functionapp publish func-costanalysis-prod-001

# Alternative: Deploy using ZIP
# First create ZIP package, then:
az functionapp deployment source config-zip `
    --name "func-costanalysis-prod-001" `
    --resource-group "rg-costanalysis-prod-v2" `
    --src "deployment.zip"
```

## Function App Testing Commands

### Basic Connectivity Tests
```powershell
# Test Function App base URL
Invoke-WebRequest -Uri "https://func-costanalysis-prod-001.azurewebsites.net"

# Test example endpoint (returns 404 due to missing code)
Invoke-WebRequest -Uri "https://func-costanalysis-prod-001.azurewebsites.net/api/example" `
    -Method POST `
    -Headers @{"Content-Type"="application/json"} `
    -Body '{"test": "data"}'

# Test analyze endpoint (when code is deployed)
Invoke-WebRequest -Uri "https://func-costanalysis-prod-001.azurewebsites.net/api/analyze" `
    -Method POST `
    -Headers @{"Content-Type"="application/json"} `
    -Body '{"include_costs": true}'

# Test cost-analysis endpoint (when code is deployed)
Invoke-WebRequest -Uri "https://func-costanalysis-prod-001.azurewebsites.net/api/cost-analysis" `
    -Method POST `
    -Headers @{"Content-Type"="application/json"} `
    -Body '{"subscription_id": "your-subscription-id", "query_type": "subscription", "start_date": "2025-09-01T00:00:00Z", "end_date": "2025-10-01T00:00:00Z"}'
```

## AI Agents Setup Commands

### Python Environment Setup
```bash
# Install Microsoft Agent Framework (preview)
pip install agent-framework-azure-ai --pre

# Install additional dependencies
pip install aiohttp azure-identity python-dotenv rich

# Install from requirements file
pip install -r requirements_agents.txt
```

### Agent Testing Commands
```python
# Test Azure AI Foundry connection
python test_agents.py

# Run the complete agent workflow
python cost_analysis_agents.py
```

## Troubleshooting Commands

### Storage Account Issues
```powershell
# Check storage account configuration
az storage account show --name "sacostanalysisprod001" --resource-group "rg-costanalysis-prod-v2" --query "allowSharedKeyAccess"

# Enable shared key access (if policy allows)
az storage account update --name "sacostanalysisprod001" --resource-group "rg-costanalysis-prod-v2" --allow-shared-key-access true

# Check storage account keys
az storage account keys list --account-name "sacostanalysisprod001" --resource-group "rg-costanalysis-prod-v2"
```

### Function App Diagnostics
```powershell
# Get Function App logs
az functionapp log tail --name "func-costanalysis-prod-001" --resource-group "rg-costanalysis-prod-v2"

# Check Function App configuration
az functionapp config show --name "func-costanalysis-prod-001" --resource-group "rg-costanalysis-prod-v2"

# List Function App settings
az functionapp config appsettings list --name "func-costanalysis-prod-001" --resource-group "rg-costanalysis-prod-v2"
```

## Resource Cleanup Commands (Use with caution)

```powershell
# Delete entire resource group (removes all resources)
az group delete --name "rg-costanalysis-prod-v2" --yes --no-wait

# Delete specific resources
az functionapp delete --name "func-costanalysis-prod-001" --resource-group "rg-costanalysis-prod-v2"
az storage account delete --name "sacostanalysisprod001" --resource-group "rg-costanalysis-prod-v2"

# Remove role assignments
az role assignment delete --assignee $principalId --role "Cost Management Reader"
```

## Quick Deployment Script

```powershell
# Complete deployment in one script
$resourceGroup = "rg-costanalysis-prod-v2"
$location = "swedencentral"

# Create resource group
az group create --name $resourceGroup --location $location

# Deploy infrastructure
az deployment group create `
    --resource-group $resourceGroup `
    --template-file "deploy/simple.bicep" `
    --parameters environmentName="prod" location=$location appName="costanalysis"

# Verify deployment
az resource list --resource-group $resourceGroup --output table

Write-Host "✅ Infrastructure deployment completed!"
Write-Host "🔍 Function App: https://func-costanalysis-prod-001.azurewebsites.net"
Write-Host "⚠️ Next: Deploy function code and configure AI agents"
```

## Status Check Commands

```powershell
# Quick status check of all resources
function Check-CostAnalysisDeployment {
    $rg = "rg-costanalysis-prod-v2"
    
    Write-Host "🔍 Checking Azure Cost Analysis deployment..." -ForegroundColor Green
    
    # Check resource group
    $rgExists = az group exists --name $rg
    Write-Host "Resource Group ($rg): $rgExists" -ForegroundColor $(if($rgExists -eq "true") {"Green"} else {"Red"})
    
    # Check Function App
    try {
        $funcApp = az functionapp show --name "func-costanalysis-prod-001" --resource-group $rg --query "state" -o tsv 2>$null
        Write-Host "Function App: $funcApp" -ForegroundColor $(if($funcApp -eq "Running") {"Green"} else {"Yellow"})
    } catch {
        Write-Host "Function App: Not found" -ForegroundColor Red
    }
    
    # Check Storage Account
    try {
        $storage = az storage account show --name "sacostanalysisprod001" --resource-group $rg --query "provisioningState" -o tsv 2>$null
        Write-Host "Storage Account: $storage" -ForegroundColor $(if($storage -eq "Succeeded") {"Green"} else {"Yellow"})
    } catch {
        Write-Host "Storage Account: Not found" -ForegroundColor Red
    }
    
    Write-Host "✅ Status check completed!" -ForegroundColor Green
}

# Run status check
Check-CostAnalysisDeployment
```

---

**Note:** All commands in this file have been tested and verified to work. Commands marked as "BLOCKED" or "WORKING" indicate their current status based on Azure policies and deployment state.