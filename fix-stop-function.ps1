# Fixed stop-minikube-app function without -Force parameter
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