# ======================================================
# CONFIGURATION
# ======================================================

$S3_BASE = "s3://my-driving-data-lake/raw/source=edge/device=my_local_gateway_01"

$DATASET_PATH  = "C:\Udacity-CarND-Behavioral-Cloning\data"
$UPLINK_PATH   = "C:\edge_data\uplink"
$DOWNLINK_PATH = "C:\edge_data\downlink"

$LogDir  = "C:\Users\Dell\Documents\logs"
$LogFile = "$LogDir\ingest_$(Get-Date -Format 'yyyyMMdd').log"

# ======================================================
# PRE-CHECKS
# ======================================================

if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}

Write-Output "[$(Get-Date)] Batch ingestion started" |
    Tee-Object -Append $LogFile

# ======================================================
#  IMAGES → images/
# ======================================================

aws s3 sync `
    "$DATASET_PATH\IMG" `
    "$S3_BASE/images/" `
    --include "*.jpg" `
    --only-show-errors `
    >> $LogFile 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Error "Image ingestion FAILED"
    exit 1
}

# ======================================================
#  CSV → csv/
# ======================================================

aws s3 sync `
    "$DATASET_PATH" `
    "$S3_BASE/csv/" `
    --exclude "*" `
    --include "*.csv" `
    --only-show-errors `
    >> $LogFile 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Error "CSV ingestion FAILED"
    exit 1
}

# ======================================================
#  UPLINK JSON → uplink/
# ======================================================

aws s3 sync `
    "$UPLINK_PATH" `
    "$S3_BASE/uplink/" `
    --include "*.json" `
    --only-show-errors `
    >> $LogFile 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Error "Uplink ingestion FAILED"
    exit 1
}

# ======================================================
#  DOWNLINK JSON → downlink/
# ======================================================

aws s3 sync `
    "$DOWNLINK_PATH" `
    "$S3_BASE/downlink/" `
    --include "*.json" `
    --only-show-errors `
    >> $LogFile 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Error "Downlink ingestion FAILED"
    exit 1
}

# ======================================================
# COMPLETION
# ======================================================

Write-Output "[$(Get-Date)] Batch ingestion completed successfully" |
    Tee-Object -Append $LogFile
