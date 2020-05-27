#region function Start-RollingPacketTrace 
function Start-RollingPacketTrace { 
<#     
    .SYNOPSIS 
        This function starts a rolling packet trace using netsh. It will begin capturing all 
        packets coming into and leaving the local computer and will continue to do so until 
        it is stopped by killing it in Task Manager.   Generated files will have a number appended 
        in the format of C:\temp\[computerName]-nnnn.etl.  Example C:\temp\myhostorazurevm-0001.etl, C:\temp\myhostorazurevm-0002.etl, etc
    .EXAMPLE 
        PS> Rolling-PacketTrace -TraceFilePath C:\Tracefile.etl -Hours 4
 
            This example will begin a rolling packet capture on the local computer that keeps the last 4 hours of captures data and place all activity 
            in the ETL file C:\Tracefile.etl. 
     
    .PARAMETER TraceFilePath 
        The file path where the trace file will be placed and recorded to. This file must be an ETL file. 
         
    .PARAMETER Hours
        The number of hours to keep
 
    .PARAMETER IpAddress
        [ON hOLD]  This feature is not yet ready for use
        (optional) The ipV4 address to filter.  If there is a need to limit this capture to a specific soure/destination IP
     
    .INPUTS 
        None. You cannot pipe objects to Rolling-PacketTrace. 
 
    .OUTPUTS 
        None. Rolling-PacketTrace returns no output upon success. 
#> 
    [CmdletBinding()] 
    [OutputType()] 
    param 
    (  
        [Parameter(mandatory=$true)] 
        [int]$Hours,
 
        [Parameter()] 
        [string]$Ipv4 
 
    ) 
    begin { 
        Set-StrictMode -Version Latest 
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop 
    } 
    process { 
 
 
        #create the C:\temp directory if it does not exist
        if(!(Test-Path C:\temp -PathType Any)){
            write-host "Directory does not exist, creating C:\temp"
            New-Item -Path 'C:\temp' -ItemType Directory
        }
        
        #start an infinite loop -- knowing this has to be killed through task manager
        while ($true) {
        $timeNow = Get-Date
        $parentDir = "c:\temp"
        $fileName = $env:COMPUTERNAME
        $files = Get-ChildItem -Path "c:\temp"
        $highestFileNumber = 0
        #Loop through all files in the target directory and remove any that are older than the duration as set by the 'hours' parameter
        foreach ($file in $files){
            $file.Name
            if ($file.Name -match $fileName){
                $file.CreationTime
                $referenceTime = $timeNow.AddHours($hours * -1)
                $referenceTime
                if($file.CreationTime -lt $referenceTime){
                    write-host "delete file " = $file.FullName
                    Remove-Item -Path $file.FullName
                    continue
                }
                $fileNumberwithExtension = $file.Name.split("-")[1]
                $filenumber = [int]$fileNumberwithExtension.split(".")[0]
                if ($filenumber -gt $highestFileNumber){
                    if ($filenumber -le 9999){
                        $highestFileNumber = $filenumber
                    } else {
                        $highestFileNumber = 1
                    }
                }
            }
        }
 
            $currentFileNumber = $highestFileNumber + 1
            $TraceFilePath = "c:\temp\" + $env:COMPUTERNAME + "-" + $currentFileNumber + ".etl"   
 
            $OutFile = "c:\temp\RollingCapturePSlog.txt"
            #start the packet capture, using a new window to do so
            $Process = Start-Process "$($env:windir)\System32\netsh.exe" -ArgumentList "trace start persistent=yes capture=yes maxSize=1024 tracefile=$TraceFilePath" -RedirectStandardOutput $OutFile -Wait
            
            #we want the captures in 15 minute segments
            $fifteenminutetimer = $timeNow.AddMinutes(15)
            $currentTime = Get-Date
            #sleep for a minute at a time and then check the current time to see if the timer has elapsed
            while ($currentTime -le $fifteenminutetimer){
                Start-Sleep -Seconds 60
                $currentTime = Get-Date
            }
            #when the timer has elapsed, stop the packet capture and resume the infinite loop
            $Process = Start-Process "$($env:windir)\System32\netsh.exe" -ArgumentList "trace stop" -RedirectStandardOutput $OutFile 
        }
    } 
} 
#endregion function Start-RollingPacketTrace 
