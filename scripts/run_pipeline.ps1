# Run the whole warehouse pipeline end to end.
# Usage:
#   $env:MSSQL_SA_PASSWORD = "your password"
#   powershell -ExecutionPolicy Bypass -File .\scripts\run_pipeline.ps1

$ErrorActionPreference = "Stop"

$Container = "sqlserver"
$Sqlcmd    = "/opt/mssql-tools18/bin/sqlcmd"
$Password  = $env:MSSQL_SA_PASSWORD
if (-not $Password) { throw "Set the MSSQL_SA_PASSWORD environment variable first" }

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$SqlDir      = Join-Path $ProjectRoot "sql"
$RunId       = [guid]::NewGuid().ToString()

$BootstrapSteps = @("00_setup.sql", "00b_etl_log.sql")
$Steps = @(
    "01_create_staging.sql",
    "02_load_staging.sql",
    "03_create_dw_tables.sql",
    "04_dim_organization.sql",
    "05_dim_patient.sql",
    "06_dim_provider.sql",
    "07_fact_encounter.sql",
    "08_inpatient_episodes.sql",
    "09_kpi_readmission.sql",
    "10_sim_ed_pia.sql",
    "11_kpi_views.sql"
)

# Copy the sql folder into the container (sqlcmd runs inside it)
docker exec $Container rm -rf /tmp/sql
docker cp $SqlDir "${Container}:/tmp/sql"

function Invoke-SqlFile($file) {
    # -C trust cert, -b non-zero exit code on SQL error, -f 65001 read file as UTF-8
    docker exec $Container $Sqlcmd -S localhost -U sa -P $Password -C -b -f 65001 -i "/tmp/sql/$file"
    if ($LASTEXITCODE -ne 0) { throw "Script failed: $file" }
}

function Write-Log($step, $status, $msg = "") {
    $msg = $msg.Replace("'", "''")
    $q = "EXEC etl.usp_log_step '$RunId', '$step', '$status', '$msg'"
    docker exec $Container $Sqlcmd -S localhost -U sa -P $Password -C -d HospitalDW -Q $q | Out-Null
}

Write-Host "== Run $RunId started ==" -ForegroundColor Cyan

foreach ($f in $BootstrapSteps) {
    Write-Host "[bootstrap] $f"
    Invoke-SqlFile $f
}

foreach ($f in $Steps) {
    Write-Host "[run] $f"
    Write-Log $f "STARTED"
    try {
        Invoke-SqlFile $f
        Write-Log $f "SUCCESS"
    }
    catch {
        Write-Log $f "FAILED" $_.Exception.Message
        Write-Host "Failed at $f, pipeline stopped" -ForegroundColor Red
        exit 1
    }
}

Write-Host "== Run $RunId finished successfully ==" -ForegroundColor Green