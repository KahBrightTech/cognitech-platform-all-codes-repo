function run-app {
    <#
    .SYNOPSIS
        Runs a Kubernetes service using minikube service command and opens it in a browser.
    
    .DESCRIPTION
        This function prompts for a service name and runs the equivalent of 
        'minikube service servicename --url' but keeps it running in the background.
    
    .PARAMETER ServiceName
        The name of the Kubernetes service to run. If not provided, the function will prompt for it.
    
    .EXAMPLE
        run-app
        # Prompts for service name
    
    .EXAMPLE
        run-app hello-minikube1
        # Equivalent to: minikube service hello-minikube1 --url
    #>
    
    param(
        [Parameter(Mandatory=$false)]
        [string]$ServiceName
    )
    
    # Always prompt for service name if not provided
    if ([string]::IsNullOrWhiteSpace($ServiceName)) {
        Write-Host "=== Minikube Service Runner ===" -ForegroundColor Cyan
        $ServiceName = Read-Host "Enter the Kubernetes service name"
        
        # Validate that a name was provided
        if ([string]::IsNullOrWhiteSpace($ServiceName)) {
            Write-Error "Service name cannot be empty."
            return
        }
    }
    
    Write-Host "`nStarting minikube service: $ServiceName" -ForegroundColor Green
    
    try {
        # Check if minikube is running
        Write-Host "Checking minikube status..." -ForegroundColor Yellow
        $minikubeStatus = minikube status 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Minikube is not running. Starting minikube..." -ForegroundColor Yellow
            minikube start
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Failed to start minikube. Please check your minikube installation."
                return
            }
        }
        
        # Check if service exists
        Write-Host "Verifying service exists..." -ForegroundColor Yellow
        $serviceCheck = kubectl get service $ServiceName 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Service '$ServiceName' not found. Available services:"
            kubectl get services
            return
        }
        
        Write-Host "✅ Service found! Running minikube service command..." -ForegroundColor Green
        
        # Start the minikube service in the background - this will open browser automatically
        Write-Host "🚀 Starting: minikube service $ServiceName" -ForegroundColor Cyan
        $job = Start-Job -Name "MinikubeService-$ServiceName" -ScriptBlock {
            param($serviceName)
            # This is exactly like running: minikube service hello-minikube1 --url
            # It will automatically open the browser
            minikube service $serviceName
        } -ArgumentList $ServiceName
        
        Write-Host "✅ Service started in background (Job ID: $($job.Id))" -ForegroundColor Green
        $global:LastMinikubeJobId = $job.Id
        
        # Wait a moment for the service to start
        Start-Sleep -Seconds 3
        
        # Show status information
        Write-Host "`n=== Service Status ===" -ForegroundColor Yellow
        Write-Host "✓ Service Name: $ServiceName" -ForegroundColor Cyan
        Write-Host "✓ Command: minikube service $ServiceName" -ForegroundColor Cyan
        Write-Host "✓ Job ID: $($job.Id)" -ForegroundColor Cyan
        Write-Host "✓ Browser should open automatically" -ForegroundColor Cyan
        
        Write-Host "`n💡 To stop the service later, run: stop-minikube-app" -ForegroundColor Yellow
        Write-Host "💡 To check service status, run: Get-Job -Name 'MinikubeService-$ServiceName'" -ForegroundColor Yellow
        
    }
    catch {
        Write-Error "An error occurred: $($_.Exception.Message)"
        Write-Host "Please ensure minikube and kubectl are properly installed and configured." -ForegroundColor Red
    }
}

# Helper function to stop minikube service jobs
function stop-minikube-app {
    <#
    .SYNOPSIS
        Stops minikube service jobs started by run-app.
    
    .DESCRIPTION
        This function stops and removes background jobs created by the run-app function.
    
    .PARAMETER ServiceName
        Optional: Specify a specific service to stop. If not provided, stops all minikube service jobs.
    #>
    
    param(
        [Parameter(Mandatory=$false)]
        [string]$ServiceName
    )
    
    Write-Host "🛑 Stopping minikube service jobs..." -ForegroundColor Yellow
    
    $jobsStopped = $false
    
    # Stop specific service job if ServiceName provided
    if ($ServiceName) {
        $jobName = "MinikubeService-$ServiceName"
        $specificJob = Get-Job -Name $jobName -ErrorAction SilentlyContinue
        if ($specificJob) {
            Stop-Job -Name $jobName
            Remove-Job -Name $jobName
            Write-Host "✅ Stopped service job: $jobName" -ForegroundColor Green
            $jobsStopped = $true
        } else {
            Write-Host "⚠️ No job found for service: $ServiceName" -ForegroundColor Yellow
        }
    }
    
    # Stop job by ID if stored in global variable
    if ($global:LastMinikubeJobId) {
        try {
            $job = Get-Job -Id $global:LastMinikubeJobId -ErrorAction SilentlyContinue
            if ($job) {
                Stop-Job -Id $global:LastMinikubeJobId
                Remove-Job -Id $global:LastMinikubeJobId
                Write-Host "✅ Stopped job ID: $global:LastMinikubeJobId" -ForegroundColor Green
                $global:LastMinikubeJobId = $null
                $jobsStopped = $true
            }
        }
        catch {
            Write-Host "⚠️ Could not stop job ID $global:LastMinikubeJobId : $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
    # Stop all minikube service jobs if no specific service provided
    if (-not $ServiceName) {
        $minikubeJobs = Get-Job | Where-Object { $_.Name -like "MinikubeService-*" }
        if ($minikubeJobs) {
            $minikubeJobs | ForEach-Object {
                Stop-Job -Id $_.Id
                Remove-Job -Id $_.Id
                Write-Host "✅ Stopped job: $($_.Name)" -ForegroundColor Green
                $jobsStopped = $true
            }
        }
    }
    
    if (-not $jobsStopped) {
        Write-Host "ℹ️ No minikube service jobs found to stop." -ForegroundColor Blue
        Write-Host "💡 Use 'Get-Job' to see all active background jobs." -ForegroundColor Cyan
    } else {
        Write-Host "🧹 Service jobs cleanup complete!" -ForegroundColor Green
        Write-Host "📝 Note: Your Kubernetes services are still running in the cluster." -ForegroundColor Cyan
        Write-Host "💡 To stop the actual Kubernetes services, use: kubectl delete service <service-name>" -ForegroundColor Yellow
    }
}