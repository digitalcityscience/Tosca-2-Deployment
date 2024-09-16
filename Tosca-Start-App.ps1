# Deployment Script for TOSCA

# Function to display error messages and exit
function Show-Error {
    param (
        [string]$message
    )
    Write-Host "$message" -ForegroundColor Red
    Write-Host "Press 'q' to exit..."
    while ($true) {
        $key = [System.Console]::ReadKey($true)
        if ($key.KeyChar -eq 'q') {
            exit 1
        }
    }
}

# Function to display success messages
function Show-Success {
    param (
        [string]$message
    )
    Write-Host "$message" -ForegroundColor Green
    Write-Host "Press 'q' to exit..."
    while ($true) {
        $key = [System.Console]::ReadKey($true)
        if ($key.KeyChar -eq 'q') {
            exit 0
        }
    }
}

# Function to run Docker Compose and check exit code
function Run-DockerCompose {
    param (
        [string]$arguments
    )

    # Start docker-compose process and capture output
    $process = Start-Process -FilePath "docker-compose" -ArgumentList $arguments -PassThru -NoNewWindow -Wait

    if ($process.ExitCode -eq 0) {
        return $true
    } else {
        return $false
    }
}

try {
    # Check if .env file exists in the current directory
    if (-Not (Test-Path -Path ".env")) {
        Show-Error "Error: .env file not found. Please create a .env file in the current directory."
    }

    # Check if Docker is running
    try {
        # This will throw an error if Docker is not running
        $dockerStatus = Invoke-Expression "docker info"
    } catch {
        Show-Error "Error: Docker is not running or unavailable. Please start Docker and try again."
    }

    # Stop any existing containers
    Write-Host "Closing TOSCA system..."
    $downResult = Run-DockerCompose "-f docker-compose-production.yml down --remove-orphans"
    if (-Not $downResult) {
        Show-Error "Error: Failed to stop the existing TOSCA system."
    }

    # Run Docker Compose to build and start the system
    Write-Host "Starting TOSCA system..."
    $upResult = Run-DockerCompose "-f docker-compose-production.yml up -d"
    if ($upResult) {
        Write-Host "TOSCA system started successfully." -ForegroundColor Green
    } else {
        Show-Error "Error: Failed to start TOSCA system. Please check the logs."
    }

    # Display Docker logs
    Write-Host "Showing Docker logs..."
    Invoke-Expression "docker-compose -f docker-compose-production.yml logs --tail=50"

    # Graceful exit with success message
    Show-Success "TOSCA system deployed successfully. Press 'q' to exit."

} catch {
    # Display detailed error message and stack trace
    Write-Host "An unexpected error occurred: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack Trace: $($_.Exception.StackTrace)" -ForegroundColor Red
    Show-Error "Script encountered an error. Please check the details above."
} finally {
    # Ensure the script doesn't close automatically
    Write-Host "Press 'q' to exit..."
    while ($true) {
        $key = [System.Console]::ReadKey($true)
        if ($key.KeyChar -eq 'q') {
            exit 0
        }
    }
}
