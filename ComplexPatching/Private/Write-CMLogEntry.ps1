function Write-CMLogEntry {
    param (
        [parameter(Mandatory = $true, HelpMessage = 'Value added to the log file.')]
        [ValidateNotNullOrEmpty()]
        [string]$Value,
        [parameter(Mandatory = $false, HelpMessage = 'Severity for the log entry. 1 for Informational, 2 for Warning and 3 for Error.')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('1', '2', '3')]
        [string]$Severity = 1,
        [parameter(Mandatory = $false, HelpMessage = "Stage that the log entry is occuring in, log refers to as 'component'.")]
        [ValidateNotNullOrEmpty()]
        [string]$Component,
        [parameter(Mandatory = $true, HelpMessage = 'Name of the log file that the entry will written to.')]
        [ValidateNotNullOrEmpty()]
        [string]$FileName,
        [parameter(Mandatory = $true, HelpMessage = 'Path to the folder where the log will be stored.')]
        [ValidateNotNullOrEmpty()]
        [string]$Folder,
        [parameter(Mandatory = $false, HelpMessage = 'Set timezone Bias to ensure timestamps are accurate')]
        [ValidateNotNullOrEmpty()]
        [int32]$Bias
    )
    # Determine log file location
    $LogFilePath = Join-Path -Path $Folder -ChildPath $FileName
    AppendLog $Value
	
    # Construct time stamp for log entry
    # Construct time stamp for log entry
    if (-not(Test-Path -Path 'variable:global:Bias')) {
        [string]$global:Bias = [System.TimeZoneInfo]::Local.BaseUtcOffset.TotalMinutes
        if ($Bias -match "^-") {
            $Bias = $Bias.Replace('-', '+')
        }
        else {
            $Bias = '-' + $Bias
        }
    }

    # Construct date for log entry
    $Date = (Get-Date -Format 'MM-dd-yyyy')
	
    # Construct context for log entry
    $Context = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
	
    # Construct final log entry
    $LogText = [string]::Format('<![LOG[{0}]LOG]!><time="{1}" date="{2}" component="{3}" context="{4}" type="{5}" thread="{6}" file="">', $Value, $Time, $Date, $Component, $Context, $Severity, $PID)
	
    # Add value to log file
    try {
        $StreamWriter = [System.IO.StreamWriter]::new($LogFilePath, 'Append')
        $StreamWriter.WriteLine($LogText)
        $StreamWriter.Close()
    }
    catch [System.Exception] {
        Write-Warning -Message "Unable to append log entry to $FileName file. Error message: $($_.Exception.Message)"
    }
}