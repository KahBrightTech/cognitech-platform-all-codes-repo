# Grafana PowerShell Functions
# Complete set of functions for managing Grafana in Kubernetes

function Start-Grafana {
    Write-Host "🚀 Installing and starting Grafana..." -ForegroundColor Green
    
    # Check if Helm is installed
    try {
        $helmVersion = helm version --short 2>$null
        if ($helmVersion) {
            Write-Host "✅ Helm is installed: $helmVersion" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "❌ Error: Helm is not installed or not found in PATH" -ForegroundColor Red
        Write-Host "📖 Please install Helm first: https://helm.sh/docs/intro/install/" -ForegroundColor Red
        return
    }

    # Check if Grafana is already installed
    $grafanaCheck = helm list | Select-String "grafana"
    if ($grafanaCheck) {
        Write-Host "✅ Grafana is already installed" -ForegroundColor Yellow
        Write-Host "📋 $grafanaCheck" -ForegroundColor Yellow
        
        # Check if Grafana pods are running
        $grafanaRunning = kubectl get pods | Select-String "grafana.*Running"
        if ($grafanaRunning) {
            Write-Host "🟢 Grafana is running and ready to use" -ForegroundColor Green
        } else {
            Write-Host "🟡 Grafana is installed but pods may not be running yet" -ForegroundColor Yellow
        }
        return
    }

    # Add Grafana Helm repository
    Write-Host "📦 Adding Grafana Helm repository..." -ForegroundColor Yellow
    helm repo add grafana https://grafana.github.io/helm-charts

    # Update Helm repositories
    Write-Host "🔄 Updating Helm repositories..." -ForegroundColor Yellow
    helm repo update

    # Install Grafana
    Write-Host "⚡ Installing Grafana..." -ForegroundColor Yellow
    helm install grafana grafana/grafana

    Write-Host "🎉 Grafana installation completed!" -ForegroundColor Green
    Write-Host "🌐 Use 'Open-Grafana' to access Grafana UI" -ForegroundColor Cyan
    Write-Host "🔑 Use 'Get-GrafanaPassword' to get admin password" -ForegroundColor Cyan
}

function Open-Grafana {
    Write-Host "🚀 Starting Grafana access..." -ForegroundColor Green

    # Check if Grafana is running
    $grafanaRunning = kubectl get pods | Select-String "grafana.*Running"
    if (-not $grafanaRunning) {
        Write-Host "❌ Grafana is not running. Please run Start-Grafana first." -ForegroundColor Red
        return
    }

    # Stop any existing port forwarding jobs for Grafana
    $existingJobs = Get-Job | Where-Object { $_.Name -like "*grafana*" }
    if ($existingJobs) {
        Write-Host "🔄 Stopping existing Grafana port forwarding..." -ForegroundColor Yellow
        $existingJobs | Stop-Job
        $existingJobs | Remove-Job
    }

    # Start port forwarding to Grafana service
    Write-Host "🌐 Starting port forwarding to Grafana (localhost:3000)..." -ForegroundColor Yellow
    $job = Start-Job -Name "GrafanaPortForward" -ScriptBlock {
        kubectl port-forward service/grafana 3000:80
    }

    # Wait a moment for port forwarding to establish
    Start-Sleep -Seconds 3

    # Open Grafana in browser
    Write-Host "🌟 Opening Grafana in browser..." -ForegroundColor Green
    Start-Process "http://localhost:3000"

    Write-Host "✅ Grafana is now accessible at http://localhost:3000" -ForegroundColor Cyan
    Write-Host "👤 Username: admin" -ForegroundColor Cyan
    Write-Host "🔑 Use 'Get-GrafanaPassword' to retrieve the admin password" -ForegroundColor Cyan
    Write-Host "⚙️  Port forwarding job 'GrafanaPortForward' is running in background" -ForegroundColor Yellow
    Write-Host "🛑 Use 'Stop-Grafana' to stop port forwarding" -ForegroundColor Yellow
}

function Stop-Grafana {
    Write-Host "🛑 Stopping Grafana port forwarding..." -ForegroundColor Yellow
    
    # Find and stop Grafana port forwarding jobs
    $grafanaJobs = Get-Job | Where-Object { $_.Name -like "*grafana*" }
    
    if ($grafanaJobs) {
        $grafanaJobs | Stop-Job
        $grafanaJobs | Remove-Job
        Write-Host "✅ Grafana port forwarding stopped" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  No Grafana port forwarding jobs found" -ForegroundColor Yellow
    }
}

function Get-GrafanaPassword {
    Write-Host "🔑 Getting Grafana admin password..." -ForegroundColor Yellow
    try {
        $encodedPassword = kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}"
        if ($encodedPassword) {
            $password = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedPassword))
            Write-Host "✅ Grafana admin password: $password" -ForegroundColor Green
            Write-Host "👤 Username: admin" -ForegroundColor Cyan
            return $password
        } else {
            Write-Host "❌ Could not retrieve password" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "❌ Error retrieving password: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "✅ Grafana functions loaded successfully!" -ForegroundColor Green
Write-Host "📋 Available functions: Start-Grafana, Open-Grafana, Stop-Grafana, Get-GrafanaPassword" -ForegroundColor Cyan