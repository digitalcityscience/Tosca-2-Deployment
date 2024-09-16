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

    # Check if docker-compose or docker compose command is available
    $dockerComposeCommand = "docker-compose"
    if (-Not (Get-Command $dockerComposeCommand -ErrorAction SilentlyContinue)) {
        $dockerComposeCommand = "docker compose"
        if (-Not (Get-Command $dockerComposeCommand -ErrorAction SilentlyContinue)) {
            Show-Error "Error: Neither 'docker-compose' nor 'docker compose' command found. Please ensure Docker Compose is installed and available in PATH."
        }
    }

    # Run Docker Compose to build and start the system
    Write-Host "Starting TOSCA system..."
    $dockerComposeUp = Invoke-Expression "$dockerComposeCommand -f docker-compose-production.yml up -d"

    if ($dockerComposeUp) {
        Write-Host "TOSCA system started successfully." -ForegroundColor Green
    } else {
        Show-Error "Error: Failed to start TOSCA system. Please check the logs."
    }

    # Display Docker logs
    Write-Host "Showing Docker logs..."
    Invoke-Expression "$dockerComposeCommand -f docker-compose-production.yml logs --tail=50"

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
