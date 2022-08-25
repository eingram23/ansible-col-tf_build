If ((Get-NetConnectionProfile -InterfaceAlias Ethernet0).NetworkCategory -eq "Public") {
    Set-NetConnectionProfile -InterfaceAlias Ethernet0 -NetworkCategory "Private"
}
Get-Disk | Where-Object partitionstyle -eq 'raw' |Initialize-Disk -PartitionStyle MBR -PassThru |New-Partition -AssignDriveLetter -UseMaximumSize |Format-Volume -FileSystem NTFS -NewFileSystemLabel 'Programs' -Confirm:$false
Install-WindowsFeature RSAT-AD-Tools
Rename-NetAdapter -Name Ethernet0 -NewName LAN
$i = 'HKLM:\SYSTEM\CurrentControlSet\Services\netbt\Parameters\interfaces'  
Get-ChildItem $i | ForEach-Object {  
    Set-ItemProperty -Path "$i\$($_.pschildname)" -name NetBiosOptions -value 2
}
