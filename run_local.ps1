param(
    [string]$PythonExe = "python",
    [string]$Server = "localhost\\SQLEXPRESS01",
    [string]$Database = "monitoreo",
    [switch]$AutoInstall
)

Write-Host "Preparing to run MonitoreoInfantil locally" -ForegroundColor Cyan
Write-Host "Using Python executable: $PythonExe" -ForegroundColor Cyan

# Set environment variables for the current PowerShell session
$env:MSSQL_SERVER = $Server
$env:MSSQL_DATABASE = $Database
# Do not set MSSQL_USER/MSSQL_PASSWORD so the app uses Trusted Connection

Write-Host "MSSQL_SERVER set to: $env:MSSQL_SERVER" -ForegroundColor Gray
Write-Host "MSSQL_DATABASE set to: $env:MSSQL_DATABASE" -ForegroundColor Gray

# Check if pyodbc is importable
try {
    $checkPyodbc = & $PythonExe -c "import pyodbc; print('OK')" 2>&1
} catch {
    $checkPyodbc = $_.Exception.Message
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "\nFailed to run Python. Please ensure the provided Python executable is correct." -ForegroundColor Red
    exit 1
}

if ($checkPyodbc -and $checkPyodbc.ToString().Trim() -eq 'OK') {
    Write-Host "pyodbc is not available or failed to import. Output:" -ForegroundColor Yellow
    Write-Host $checkPyodbc

    if ($AutoInstall) {
        Write-Host "\nAutoInstall requested: creating virtualenv in .venv and installing requirements..." -ForegroundColor Cyan
        $venvDir = Join-Path (Get-Location) ".venv"
        $venvPython = Join-Path $venvDir "Scripts\python.exe"

        try {
            if (-not (Test-Path $venvPython)) {
                Write-Host "Creating virtualenv at $venvDir using $PythonExe" -ForegroundColor Gray
                & $PythonExe -m venv $venvDir
            } else {
                Write-Host "Virtualenv already exists at $venvDir" -ForegroundColor Gray
            }

            if (-not (Test-Path $venvPython)) {
                throw "Virtualenv creation failed or $venvPython not found."
            }

            Write-Host "Upgrading pip and installing requirements..." -ForegroundColor Gray
            & $venvPython -m pip install --upgrade pip setuptools wheel 2>&1 | Write-Host
            & $venvPython -m pip install -r .\requirements.txt 2>&1 | Write-Host

            # Switch to venv python and re-check
            $PythonExe = $venvPython
            Write-Host "Re-checking pyodbc import with venv python: $PythonExe" -ForegroundColor Gray
            try { $checkPyodbc = & $PythonExe -c "import pyodbc; print('OK')" 2>&1 } catch { $checkPyodbc = $_.Exception.Message }

            if ($checkPyodbc -and $checkPyodbc.ToString().Trim() -eq 'OK') {
                Write-Host "pyodbc is now available in the virtualenv. Starting the Flask app..." -ForegroundColor Green
                & $PythonExe .\app.py
                exit 0
            } else {
                Write-Host "After installation pyodbc still failed to import. Output:" -ForegroundColor Red
                Write-Host $checkPyodbc
                exit 3
            }
        } catch {
            Write-Host "AutoInstall failed: $_" -ForegroundColor Red
            exit 4
        }
    }

    Write-Host "\nTwo quick options: " -ForegroundColor Cyan
    Write-Host "1) Install pyodbc (recommended with Python 3.11):" -ForegroundColor Gray
    Write-Host "   - Install Python 3.11 and create a venv, then: `python -m pip install -r requirements.txt`" -ForegroundColor Gray
    Write-Host "2) Run the web service inside Docker (we included a Dockerfile), connecting to your local SQL Server:" -ForegroundColor Gray
    Write-Host "   docker run --rm -p 5000:5000 -e MSSQL_CONN='DRIVER={ODBC Driver 18 for SQL Server};SERVER=host.docker.internal,1433;DATABASE=monitoreo;UID=YOUR_SQL_USER;PWD=YOUR_PWD;TrustServerCertificate=yes' monitoreo-web" -ForegroundColor Gray
    Write-Host "\nTo auto-create a venv and install deps, run this script with -AutoInstall" -ForegroundColor Cyan
    exit 2
    Write-Host "2) Run the web service inside Docker (we included a Dockerfile), connecting to your local SQL Server:" -ForegroundColor Gray
    Write-Host "   docker run --rm -p 5000:5000 -e MSSQL_CONN='DRIVER={ODBC Driver 18 for SQL Server};SERVER=host.docker.internal,1433;DATABASE=monitoreo;UID=YOUR_SQL_USER;PWD=YOUR_PWD;TrustServerCertificate=yes' monitoreo-web" -ForegroundColor Gray
    exit 2
}
