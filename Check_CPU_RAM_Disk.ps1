$list = Get-Content -Path "C:\MEETRIX_DAILY_CHECK\servers_for_daily_check.txt"

$Results = foreach($IP in $list){
   $disks = Get-WmiObject -Class win32_logicaldisk -Filter 'DriveType=3' -ComputerName $IP
   $AVGProc = Get-WmiObject -Class win32_processor -ComputerName $IP  | Measure-Object -property LoadPercentage -Average 
   $OS = Get-WmiObject -Class win32_operatingsystem -ComputerName $IP | Select-Object @{Name = "MemoryUsage"; Expression = {“{0:N2}” -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize) }}

   foreach($disk in $Disks){ 
        [PSCustomObject]@{
            'Host' = $IP
            'DeviceID' = $disk.DeviceID
            'Free Disk Space (GB)' = $disk.FreeSpace/1GB
            'Total Disk Size (GB)' = $disk.Size/1GB
            CPULoad = "$($AVGProc.Average)%"
            MemLoad = "$($OS.MemoryUsage)%"
        }
    }
}

$Results | Out-GridView -Title "CPU & RAM & Storage" -Wait
