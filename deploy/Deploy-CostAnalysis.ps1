#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Deploy Azure Cost Management Functions solution to Azure

.DESCRIPTION
    This script deploys the complete Azure Cost Management Functions solution including:
    - Azure Function App with consumption plan
    - Storage Account for function data
    - Application Insights for monitoring
    - Managed identity with required RBAC permissions
    - Function code deployment

.PARAMETER ResourceGroupName
    Name of the Azure Resource Group to deploy to

.PARAMETER Environment
    Environment name (dev/test/prod) used for resource naming

.PARAMETER WhatIf
    Run in what-if mode to preview changes without deploying

.EXAMPLE
    .\Deploy-CostAnalysis.ps1 -ResourceGroupName "rg-costanalysis-prod" -Environment "prod"

.EXAMPLE
    .\Deploy-CostAnalysis.ps1 -ResourceGroupName "rg-costanalysis-test" -Environment "test" -WhatIf
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $true)]
    [ValidateSet("dev", "test", "prod")]
    [string]$Environment,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DeploymentName = "CostAnalysis-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

Write-Host ""
Write-Host "=================================================" -ForegroundColor Green
Write-Host "🚀 Azure Cost Management Functions Deployment" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host ""

# Validate prerequisites
Write-Host "🔍 Validating prerequisites..." -ForegroundColor Yellow

# Check Azure CLI
try {
    $azVersion = az --version | Select-String "azure-cli" | ForEach-Object { $_.ToString().Split()[1] }
    Write-Host "✅ Azure CLI version: $azVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI is not installed or not accessible" -ForegroundColor Red
    exit 1
}

# Check Functions Core Tools
try {
    $funcVersion = func --version
    Write-Host "✅ Azure Functions Core Tools version: $funcVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure Functions Core Tools not found. Install from: https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local" -ForegroundColor Red
    exit 1
}

# Deploy Bicep template
Write-Host "🏗️  Deploying Azure resources..." -ForegroundColor Yellow
$deployCommand = @(
    "az", "deployment", "group", "create"
    "--resource-group", $ResourceGroupName
    "--template-file", "deploy/main.bicep"
    "--parameters", "deploy/main.bicepparam"
    "--name", $DeploymentName
    "--verbose"
)

if ($WhatIf) {
    $deployCommand += "--what-if"
    Write-Host "🔍 Running What-If deployment..." -ForegroundColor Cyan
} else {
    Write-Host "⚡ Running actual deployment..." -ForegroundColor Yellow
}

try {
    $deploymentResult = & $deployCommand[0] $deployCommand[1..($deployCommand.Length-1)] | ConvertFrom-Json
    
    if (-not $WhatIf) {
        Write-Host "✅ Infrastructure deployment completed successfully!" -ForegroundColor Green
        
        # Extract deployment outputs
        $functionAppName = $deploymentResult.properties.outputs.functionAppName.value
        $functionAppUrl = $deploymentResult.properties.outputs.functionAppUrl.value
        $functionAppPrincipalId = $deploymentResult.properties.outputs.functionAppPrincipalId.value
        
        Write-Host ""
        Write-Host "📊 Deployment Results:" -ForegroundColor Cyan
        Write-Host "=====================" -ForegroundColor Cyan
        Write-Host "Function App Name: $functionAppName" -ForegroundColor White
        Write-Host "Function App URL: $functionAppUrl" -ForegroundColor White
        Write-Host "Principal ID: $functionAppPrincipalId" -ForegroundColor White
        Write-Host ""
        
        # Assign required RBAC roles to the Function App managed identity
        Write-Host "🔐 Assigning RBAC roles to Function App managed identity..." -ForegroundColor Yellow
        
        # Role definitions
        $roles = @{
            "Cost Management Reader" = "72fafb9e-0641-4937-9268-a91bfd8191a3"
            "Reader" = "acdd72a7-3385-48ef-bd42-f606fba81ae7" 
            "Advisor Reader" = "1d7d4b6b-9976-4b49-8b8e-1d8b6e84a2d7"
        }
        
        $subscriptionId = (az account show --query id -o tsv)
        $scope = "/subscriptions/$subscriptionId"
        
        foreach ($roleName in $roles.Keys) {
            $roleDefinitionId = $roles[$roleName]
            
            Write-Host "Assigning '$roleName' role..." -ForegroundColor Gray
            
            try {
                $assignmentResult = az role assignment create --assignee $functionAppPrincipalId --role $roleDefinitionId --scope $scope 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✅ Successfully assigned '$roleName' role" -ForegroundColor Green
                } else {
                    if ($assignmentResult -like "*already exists*") {
                        Write-Host "✅ '$roleName' role already assigned" -ForegroundColor Green
                    } else {
                        Write-Host "⚠️  Failed to assign '$roleName' role: $assignmentResult" -ForegroundColor Yellow
                    }
                }
            }
            catch {
                Write-Host "⚠️  Failed to assign '$roleName' role: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
        Write-Host ""
        
        # Deploy function code
        Write-Host "📦 Deploying function code..." -ForegroundColor Yellow
        Write-Host "Changing to project directory..." -ForegroundColor Yellow
        Push-Location $PSScriptRoot\..
        
        try {
            func azure functionapp publish $functionAppName --python
            Write-Host "✅ Function code deployed successfully!" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  Function code deployment failed. You can deploy manually using:" -ForegroundColor Yellow
            Write-Host "   func azure functionapp publish $functionAppName --python" -ForegroundColor White
        } finally {
            Pop-Location
        }
        
        # Get function keys
        Write-Host "🔑 Retrieving function keys..." -ForegroundColor Yellow
        try {
            $masterKey = az functionapp keys list --name $functionAppName --resource-group $ResourceGroupName --query "masterKey" --output tsv
            
            Write-Host ""
            Write-Host "🔐 Security Information:" -ForegroundColor Cyan
            Write-Host "========================" -ForegroundColor Cyan
            Write-Host "Master Key: $masterKey" -ForegroundColor White
            Write-Host ""
            Write-Host "⚠️  IMPORTANT: Store these keys securely and never commit them to version control!" -ForegroundColor Red
        } catch {
            Write-Host "⚠️  Could not retrieve function keys. Get them from Azure portal:" -ForegroundColor Yellow
            Write-Host "   Azure Portal -> Function App -> Functions -> Function Keys" -ForegroundColor White
        }
        
        # Display next steps
        Write-Host ""
        Write-Host "🎯 Next Steps:" -ForegroundColor Cyan
        Write-Host "===============" -ForegroundColor Cyan
        Write-Host "1. Test your endpoints:" -ForegroundColor White
        Write-Host "   • Example: $functionAppUrl/api/example" -ForegroundColor White
        Write-Host "   • Analyze: $functionAppUrl/api/analyze (requires function key)" -ForegroundColor White
        Write-Host "   • Cost Analysis: $functionAppUrl/api/cost-analysis (requires function key)" -ForegroundColor White
        Write-Host ""
        Write-Host "2. Configure Azure AI Foundry agents:" -ForegroundColor White
        Write-Host "   • Update agent configurations in the Agents/ folder" -ForegroundColor White
        Write-Host "   • Replace YOUR-FUNCTION-APP-NAME with: $functionAppName" -ForegroundColor White
        Write-Host "   • Replace YOUR-FUNCTION-KEY with the keys above" -ForegroundColor White
        Write-Host ""
        Write-Host "3. Test the cost analysis functionality:" -ForegroundColor White
        Write-Host "   • Ensure the Function App has proper permissions on target subscriptions" -ForegroundColor White
        Write-Host "   • For tenant-wide analysis, assign roles at management group level" -ForegroundColor White
        Write-Host ""
        Write-Host "🎉 Deployment completed successfully!" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=================================================" -ForegroundColor Green
Write-Host "✅ Azure Cost Management Functions Deployment Complete" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green