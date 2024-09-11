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

# Function to display messages and exit
function Show-Message {
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

# Function to check for and print the API key and map ID
function Check-And-Print-EnvFile {
    if (-Not (Test-Path -Path ".env")) {
        Show-Error "Error: .env file not found. Please create a .env file in the current directory."
    }

    $envFileContent = Get-Content ".env"
    $mapTilerApiKey = $null
    $mapTilerApiMapId = $null
    foreach ($line in $envFileContent) {
        if ($line -match '^\s*#') {
            continue  # Skip commented lines
        }
        if ($line -match '^\s*VITE_MAPTILER_API_KEY\s*=\s*(.+)\s*$') {
            $mapTilerApiKey = $matches[1].Trim('"')
        }
        if ($line -match '^\s*VITE_MAPTILER_API_MAP_ID\s*=\s*(.+)\s*$') {
            $mapTilerApiMapId = $matches[1].Trim('"')
        }
    }

    if ($null -eq $mapTilerApiKey) {
        Show-Error "Error: VITE_MAPTILER_API_KEY not found in .env file. Please check your API key."
    }
    if ($null -eq $mapTilerApiMapId) {
        Show-Error "Error: VITE_MAPTILER_API_MAP_ID not found in .env file. Please check your map ID."
    }

    return @{ "apiKey" = $mapTilerApiKey; "mapId" = $mapTilerApiMapId }
}

# Function to verify the MapTiler API key
function Verify-MapTilerApiKey {
    param (
        [string]$apiKey,
        [string]$mapId
    )
    $url = "https://api.maptiler.com/maps/$mapId/style.json?key=$apiKey"
    Write-Host "Verifying API key with URL: $url" -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri $url -Method Get -ErrorAction Stop
        Write-Host "HTTP Status Code: $($response.StatusCode)" -ForegroundColor Yellow
        if ($response.StatusCode -eq 200) {
            Write-Host "API key and map ID are valid." -ForegroundColor Green
        } else {
            Show-Error "Error: Invalid VITE_MAPTILER_API_KEY or VITE_MAPTILER_API_MAP_ID. Please check your API key and map ID."
        }
    } catch {
        Show-Error "Error: Invalid VITE_MAPTILER_API_KEY or VITE_MAPTILER_API_MAP_ID. Please check your API key and map ID."
    }
}

try {
    # Check and print the .env file values
    $envVariables = Check-And-Print-EnvFile
    $mapTilerApiKey = $envVariables.apiKey
    $mapTilerApiMapId = $envVariables.mapId

    # Verify the MapTiler API key
    Verify-MapTilerApiKey -apiKey $mapTilerApiKey -mapId $mapTilerApiMapId

    # Check if Docker Desktop is running
    $dockerProcess = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue
    if (-Not $dockerProcess) {
        Show-Error "Error: Docker Desktop is not running. Please start Docker Desktop and try again."
    }

    # Check if docker-compose or docker compose command is available
    $dockerComposeCommand = "docker-compose"
    if (-Not (Get-Command $dockerComposeCommand -ErrorAction SilentlyContinue)) {
        $dockerComposeCommand = "docker compose"
        if (-Not (Get-Command $dockerComposeCommand -ErrorAction SilentlyContinue)) {
            Show-Error "Error: Neither 'docker-compose' nor 'docker compose' command found. Please ensure Docker Compose is installed and available in PATH."
        }
    }

    # Attempt to stop any running Docker Compose services
    Write-Host "Stopping any existing TOSCA services..."
    Invoke-Expression "$dockerComposeCommand -f docker-compose-production.yml down --remove-orphans"
    
    # Copy .env file to the Docker build context
    Write-Host "Copying .env file to the Docker build context..."
    Copy-Item -Path "./.env" -Destination "./dockerfile" -Force	
    # Run Docker Compose to build and start the system
    Write-Host "Starting TOSCA system..."
    Invoke-Expression "$dockerComposeCommand -f docker-compose-production.yml build --no-cache"
    Invoke-Expression "$dockerComposeCommand -f docker-compose-production.yml up -d"

    Write-Host "TOSCA system started successfully." -ForegroundColor Green

    # Display Docker logs
    Write-Host "Showing Docker logs..."
    Invoke-Expression "$dockerComposeCommand -f docker-compose-production.yml logs --tail=50"

    Write-Host "Press 'q' to exit..."
    while ($true) {
        $key = [System.Console]::ReadKey($true)
        if ($key.KeyChar -eq 'q') {
            exit 0
        }
    }
} catch {
    Show-Error "An unexpected error occurred: $_"
}
