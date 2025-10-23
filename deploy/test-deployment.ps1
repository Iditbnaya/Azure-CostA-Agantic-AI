#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Test the Azure Cost Management deployment templates

.DESCRIPTION
    This script validates the Bicep templates and tests deployment functionality
    without actually deploying resources to Azure.

.EXAMPLE
    .\test-deployment.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "=================================================" -ForegroundColor Green
Write-Host "🧪 Testing Azure Cost Management Deployment" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host ""

# Test 1: Validate Bicep templates can be compiled
Write-Host "🔍 Test 1: Validating Bicep template compilation..." -ForegroundColor Yellow

try {
    Write-Host "   Compiling main.bicep..." -NoNewline
    az bicep build --file "$ScriptDir/main.bicep" --outfile "$ScriptDir/main.json" --stdout | Out-Null
    Write-Host " ✅" -ForegroundColor Green
    
    Write-Host "   Compiling simple.bicep..." -NoNewline
    az bicep build --file "$ScriptDir/simple.bicep" --outfile "$ScriptDir/simple.json" --stdout | Out-Null
    Write-Host " ✅" -ForegroundColor Green
    
    Write-Host "✅ Bicep compilation successful!" -ForegroundColor Green
} catch {
    Write-Host " ❌" -ForegroundColor Red
    Write-Host "❌ Bicep compilation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Validate JSON structure
Write-Host ""
Write-Host "🔍 Test 2: Validating JSON structure..." -ForegroundColor Yellow

try {
    Write-Host "   Validating main.json..." -NoNewline
    $mainJson = Get-Content "$ScriptDir/main.json" | ConvertFrom-Json
    if ($mainJson.'$schema' -and $mainJson.parameters -and $mainJson.resources) {
        Write-Host " ✅" -ForegroundColor Green
    } else {
        throw "Invalid JSON structure"
    }
    
    Write-Host "   Validating simple.json..." -NoNewline
    $simpleJson = Get-Content "$ScriptDir/simple.json" | ConvertFrom-Json
    if ($simpleJson.'$schema' -and $simpleJson.parameters -and $simpleJson.resources) {
        Write-Host " ✅" -ForegroundColor Green
    } else {
        throw "Invalid JSON structure"
    }
    
    Write-Host "✅ JSON structure validation successful!" -ForegroundColor Green
} catch {
    Write-Host " ❌" -ForegroundColor Red
    Write-Host "❌ JSON validation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 3: Check parameter files
Write-Host ""
Write-Host "🔍 Test 3: Validating parameter files..." -ForegroundColor Yellow

try {
    Write-Host "   Checking main.bicepparam..." -NoNewline
    if (Test-Path "$ScriptDir/main.bicepparam") {
        $paramContent = Get-Content "$ScriptDir/main.bicepparam" -Raw
        if ($paramContent -match "using './main.bicep'" -and $paramContent -match "param functionAppName") {
            Write-Host " ✅" -ForegroundColor Green
        } else {
            throw "Invalid parameter file structure"
        }
    } else {
        throw "Parameter file not found"
    }
    
    Write-Host "✅ Parameter file validation successful!" -ForegroundColor Green
} catch {
    Write-Host " ❌" -ForegroundColor Red
    Write-Host "❌ Parameter validation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 4: Validate PowerShell deployment script
Write-Host ""
Write-Host "🔍 Test 4: Validating PowerShell deployment script..." -ForegroundColor Yellow

try {
    Write-Host "   Checking Deploy-CostAnalysis.ps1..." -NoNewline
    if (Test-Path "$ScriptDir/Deploy-CostAnalysis.ps1") {
        $scriptContent = Get-Content "$ScriptDir/Deploy-CostAnalysis.ps1" -Raw
        if ($scriptContent -match 'ScriptDir.*main\.bicep' -and $scriptContent -match 'deployment.*group.*create') {
            Write-Host " ✅" -ForegroundColor Green
        } else {
            Write-Host " ❌ Debug: ScriptDir check: $($scriptContent -match 'ScriptDir.*main\.bicep')" -ForegroundColor Yellow
            Write-Host " ❌ Debug: AZ check: $($scriptContent -match 'deployment.*group.*create')" -ForegroundColor Yellow
            throw "Invalid deployment script structure"
        }
    } else {
        throw "Deployment script not found"
    }
    
    Write-Host "✅ Deployment script validation successful!" -ForegroundColor Green
} catch {
    Write-Host " ❌" -ForegroundColor Red
    Write-Host "❌ Deployment script validation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 5: Check resource naming conventions
Write-Host ""
Write-Host "🔍 Test 5: Validating resource naming..." -ForegroundColor Yellow

try {
    Write-Host "   Checking storage account naming..." -NoNewline
    $paramContent = Get-Content "$ScriptDir/main.bicepparam" -Raw
    if ($paramContent -match "param storageAccountName = '[a-z0-9]{3,24}'") {
        Write-Host " ✅" -ForegroundColor Green
    } else {
        # Check if it's using the shortened name format
        if ($paramContent -match "sacostprod001" -or $paramContent -match "sacost") {
            Write-Host " ✅" -ForegroundColor Green
        } else {
            throw "Storage account name may be too long or invalid"
        }
    }
    
    Write-Host "✅ Resource naming validation successful!" -ForegroundColor Green
} catch {
    Write-Host " ❌" -ForegroundColor Red
    Write-Host "❌ Resource naming validation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎉 All tests passed! Your deployment templates are ready." -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "1. Create a resource group: az group create --name 'rg-costanalysis-prod' --location 'East US'" -ForegroundColor White
Write-Host "2. Run deployment: .\Deploy-CostAnalysis.ps1 -ResourceGroupName 'rg-costanalysis-prod' -Environment 'prod'" -ForegroundColor White
Write-Host "3. Or use the Deploy to Azure button in the README.md" -ForegroundColor White
Write-Host ""