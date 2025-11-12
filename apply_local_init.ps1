param(
    [string]$Server = 'localhost\\SQLEXPRESS01',
    [string]$SaUser = 'sa',
    [string]$SaPassword = ''
)

$scriptPath = Join-Path (Get-Location) 'sql\local_init.sql'
if (-not (Test-Path $scriptPath)) {
    Write-Host "local_init.sql not found at $scriptPath" -ForegroundColor Red
    exit 1
}

# If no SA password provided, prompt
if (-not $SaPassword) {
    $SaPassword = Read-Host -AsSecureString "Enter SA password (leave empty to try Integrated Security)"
    if ($SaPassword.Length -eq 0) { $SaPassword = $null } else { $SaPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SaPassword)) }
}

Write-Host "Applying local_init.sql to server: $Server" -ForegroundColor Cyan

# Prefer sqlcmd if available
$sqlcmd = Get-Command sqlcmd -ErrorAction SilentlyContinue
if ($sqlcmd) {
    if ($SaPassword) {
        & sqlcmd -S $Server -U $SaUser -P $SaPassword -i $scriptPath
    } else {
        & sqlcmd -S $Server -E -i $scriptPath
    }
    if ($LASTEXITCODE -eq 0) { Write-Host "Initialization script executed successfully." -ForegroundColor Green } else { Write-Host "sqlcmd returned exit code $LASTEXITCODE" -ForegroundColor Red }
    exit $LASTEXITCODE
}

# If sqlcmd not found, try Invoke-Sqlcmd from SqlServer module
try {
    if (-not (Get-Module -ListAvailable -Name SqlServer)) {
        Write-Host "PowerShell module 'SqlServer' not installed. You can run the SQL script manually in SSMS." -ForegroundColor Yellow
        Write-Host "Open the file: $scriptPath and run its contents in SQL Server Management Studio (SSMS) connected to $Server." -ForegroundColor Gray
        exit 2
    }
    Import-Module SqlServer -ErrorAction Stop
    $sql = Get-Content $scriptPath -Raw
    if ($SaPassword) {
        Invoke-Sqlcmd -ServerInstance $Server -Username $SaUser -Password $SaPassword -Query $sql
    } else {
        Invoke-Sqlcmd -ServerInstance $Server -Query $sql
    }
    Write-Host "Initialization script executed successfully via Invoke-Sqlcmd." -ForegroundColor Green
    exit 0
} catch {
    Write-Host "Failed to run initialization script automatically: $_" -ForegroundColor Red
    Write-Host "Please open $scriptPath in SSMS and run it while connected to $Server." -ForegroundColor Gray
    exit 3
}
