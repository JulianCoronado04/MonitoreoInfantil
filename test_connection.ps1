param(
    [string]$Server = 'localhost\SQLEXPRESS01',
    [string]$Database = 'master'
)

Write-Host "Testing connection to SQL Server instance: $Server (DB: $Database)" -ForegroundColor Cyan

try {
    Add-Type -AssemblyName System.Data
    $connString = "Server=$Server;Database=$Database;Integrated Security=True;TrustServerCertificate=True;"
    $conn = New-Object System.Data.SqlClient.SqlConnection $connString
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = 'SELECT 1'
    $result = $cmd.ExecuteScalar()
    Write-Host "Connection OK. SELECT 1 -> $result" -ForegroundColor Green
    $conn.Close()
    exit 0
} catch {
    Write-Host "Connection failed:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    if ($_.Exception.InnerException) { Write-Host $_.Exception.InnerException.Message }
    exit 2
}
