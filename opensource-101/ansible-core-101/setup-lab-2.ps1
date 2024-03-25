$VM_directory="\VMs"
$CPU_CNT="2"

write-host "Build to virtual machines for Ansible LAB."

New-Item -ItemType Directory c:\$VM_directory 2>&1>$null
New-Item -ItemType Directory c:\$VM_directory 2>&1>$null

Invoke-WebRequest https://mirror.navercorp.com/rocky/9.3/isos/x86_64/Rocky-9.3-x86_64-minimal.iso
 -OutFile c:$VM_directory\Rocky-9.3-x86_64-dvd.iso

Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
New-VMSwitch -name InternalSwitch -SwitchType Internal 2>&1>$null

for ($i=1; $i -lt 5 ; $i++){
  New-VM -Name node$i -MemoryStartupBytes 2GB -BootDevice VHD -NewVHDPath c:$VM_directory\node$i.vhdx -Path c:$VM_directory -NewVHDSizeBytes 12GB -Generation 2 -Switch "Default Switch" 2>&1>$null 
  Add-VMDvdDrive -VMName node$i -Path c:$VM_directory\Rocky-9.3-x86_64-dvd.iso
  SET-VMProcessor node$i -count 2
  $DVDDrive = Get-VMDvdDrive -VMName node$i
  ADD-VMNetworkAdapter -VMName node$i -SwitchName "InternalSwitch"
  Set-VMFirmware node$i -EnableSecureBoot Off
  Set-VMFirmware -VMName node$1 -FirstBootDevice $DVDDrive
  Start-VM node$i
}