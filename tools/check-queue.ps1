param(
    [Parameter(Position = 0)]
    [ValidateSet("current", "stable")]
    [string] $Arm = "current"
)

$marker = Join-Path $env:USERPROFILE ".rq-windows-compat-state"
$log = Join-Path $PSScriptRoot "schedule-check.log"
$whoami = Join-Path $env:SystemRoot "System32\whoami.exe"
$parent = (Get-CimInstance Win32_Process -Filter "ProcessId=$PID").ParentProcessId
$groups = (& $whoami /groups | Out-String).TrimEnd()
$content = @(
    "STAGE=schedule_child_executed"
    "ARM=$Arm"
    "PID=$PID"
    "PPID=$parent"
    "WHOAMI_GROUPS_BEGIN"
    $groups
    "WHOAMI_GROUPS_END"
) -join "`r`n"
try {
    [IO.File]::WriteAllText($marker, $content + "`r`n")
    [IO.File]::WriteAllText($log, "STAGE=host_marker_written`r`nARM=$Arm`r`nHOST_MARKER=$marker`r`n")
    Write-Output "queue compatibility: ok"
} catch {
    [IO.File]::WriteAllText($log, "STAGE=host_marker_write_failed`r`nARM=$Arm`r`nERROR=$($_.Exception.Message)`r`n")
    Write-Error $_
    exit 23
}
