$iso_url=https://mirror.navercorp.com/rocky/9.3/isos/x86_64/Rocky-9.3-x86_64-minimal.iso
$VM_directory=\VMs
$VM_Data=\VMData
$CPU_CNT=2

write-host "Build to virtual machines for Ansible LAB"

New-Item -ItemType Directory c:\VMs
New-Item -ItemType Directory c:\VMData

curl https://mirror.navercorp.com/rocky/9.3/isos/x86_64/Rocky-9.3-x86_64-minimal.iso -O c:$VM_Data\Rocky-9.3-x86_64-minimal.iso

Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
New-VMSwitch -name InternalSwitch -SwitchType Internal

for ($i=0; $i -lt 4 ; $i++){
	New-VM -Name node$i -MemoryStartupBytes 2GB -BootDevice VHD -NewVHDPath .\VMs\node$i.vhdx -Path .\VMData -NewVHDSizeBytes 12GB -Generation 2 -Switch "Default Switch"
	Add-VMDvdDrive -VMName node$i -Path c:\VMData\Rocky-9.3-x86_64-dvd.iso
	SET-VMProcessor node$i -count $CPU_CNT
	ADD-VMNetworkAdapter –VMName node$i –SwitchName InternalSwitch
}



# SIG # Begin signature block
# MIIIiQYJKoZIhvcNAQcCoIIIejCCCHYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUS0q7A4s8YQZsfUmd3ogEps5m
# LtagggUkMIIFIDCCAwigAwIBAgIQRCHMhyc5S7ND7W1xv7yuKDANBgkqhkiG9w0B
# AQsFADAaMRgwFgYDVQQDDA90YW5nQGR1c3Rib3gua3IwHhcNMjQwMzIyMDMyODAx
# WhcNMzQwMzIyMDMzODAwWjAaMRgwFgYDVQQDDA90YW5nQGR1c3Rib3gua3IwggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDZV0jz/Yd99M93XcQECQzRlG7C
# zDc8rwTOeVveSIIGEb5f11bU4MGjTT1Pjwd10yuOcsCzSZvfgoLJS+8B/0CWnMQ+
# yQPwkB88xDUe5tKP0Y6RXZk6opYlYbVeXLM2P+flf0YC0nK93IwfQ8CqhFFHeuNZ
# RM6uCZ7qEtQn1Ctf7+NIWvZCkAlEJS8OBD99ih51OpBwCEMJKi451j28iLW2amgC
# /KeNWPburRP0ZfNkYrrLGav1PlXekV+qJxzVvy65hL+35mIPdozPA2asMP9Vo/Qz
# 2lK3EsRDEaHlIz6Qad5JDfxfDax9EWv6Kys1IB/BrUEGT1EvZKMXu+WDP89g+/7i
# vOV4fZCk8/D/5wnUmSVvDpAWrDAi++wEOuUPN0C49BwHZ4u+O9rnyT72ydqpDWzi
# OWYXGkWz+EXVoo3gHyX7Vj10ObdWhwxcsCMK/kwP1Y2SiMsFxEHmA94L3+ulaHSW
# vcXi/qyYUrSlpUncxoN8RSbP6mr9FSgGqJm633BXCBzs2NwFFDl4ztvLZI0Flshc
# 2x7r/nl+s1EvZs/+dUK3EXclrHttbIPdR4MGmpf9tkixB07jDxmqG3GvcjwN+EDd
# H7SgrVZALvDxu+UJtBNow9Xo0rB5dYA3MivM7IlLDvACVMSuN+S9ZocP9PwRcUZe
# i/U+IJ33QZEZYfbShQIDAQABo2IwYDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAww
# CgYIKwYBBQUHAwMwGgYDVR0RBBMwEYIPdGFuZ0BkdXN0Ym94LmtyMB0GA1UdDgQW
# BBR9YMibVvZTPo/t7tupTXz53d+zlTANBgkqhkiG9w0BAQsFAAOCAgEARk+o4MvC
# pcGqwU8b7YSyOcbQ5x8rBNIZIOEAUmb0cu2tnK7U0EC84T+tXOGzR9WzpBHnEpJK
# k8cmcIKq2t2MLdU7Y//0bssxq5oB1mdI+4FK5JYw8dm1B6P6TWrFQqMj87NeXs3s
# 8jJspd1gGASRurU1eZcjMUXJFUq9vP3NB1KHm4qjheCCDe8uFjrMdUJ8Qq4tJ1ba
# 4ZGsek4PGYD0qYI1lv1PNAfsQIyMQhmTQraYLiHCyA38924WFQC/T4+kdHaC7BUu
# 5ncoxOCRapaI+1rvpLCnFE+517uBOlb3DMspzTBf0WslKtI/0Pfu68BsLOvycH96
# e+XQT+ESx/dFokUU1hxH5yim/SrVewnADy5tJLvJ53AwT1cIzBDKRunlh4CByPpR
# 8U23PkECs0JCJDSd7h05ARL88bHYjkF1imb7TvfqZj390tLKLlAE+0ynoQ8xls1m
# UgYAVrp+Pjjmdda1DBfoidXlTTqzBEFVmjkzGGN6cvR5Ci1v9AdSEw40YRLxkKUM
# mNb+NtkKQOeovZkmswrtDdB94uCwX7xl3inn64jdp4ViG3QG1+4bVICO2CcTAZxb
# MKykP+82+lY/Sqp2R7ar5icSd1WFkXOtCoiTGMbluabG//oq2WdmK45oHjg+PtVx
# NpU7KEVtGYzR2GxjAhhaGWDCFbl5StyhTb8xggLPMIICywIBATAuMBoxGDAWBgNV
# BAMMD3RhbmdAZHVzdGJveC5rcgIQRCHMhyc5S7ND7W1xv7yuKDAJBgUrDgMCGgUA
# oHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYB
# BAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0B
# CQQxFgQUdkIHiSL3BsZguI1j+Dln8Eo5ISUwDQYJKoZIhvcNAQEBBQAEggIAVt6G
# nls7ndAo6GCla6aPmxrQr/dKNzIOzrIHqXSiQ2mYhEhYwQUHlatu0qgGGuICdTvJ
# 45E741nIasNqqu+BtxkSPk3OmqmiZbFnAEqd2bL5PwGGC/DjEHQVdUpuxwojPGz/
# SfznKDd2UaZc1M/2L0Kb8EN8pkrjuWewq8kVvuXR6+rFlyl4AOKEIVThYPVsvP8E
# xg3i8tnsBQ3ZdhoUUHD8FibOLqopP7pfcr9UghS7AA1ibL8VuC0Qox7sA3Ecw+Jy
# Ch+V4sKVh4P+NEFxua0KBLMfqCd5RbUoWd9yZ5doKUd6avpF1e24POvNRx3+ULt5
# H4i1Sj6OilerUNNe+7GgOGwVe8MmN2zU80X/83/8PXX6LwCoHle6uae1p+tCqb2K
# mzdr/YJrwyVpGT35aKx0wykwYwg5V+D9cw4frfkFOC+HKCh0jMqMIgne8uRIokT5
# eCt70W0+Q7e1d6sLFZTn/b7Uqo6ZfE9qKkJXhghkbyHuGv92oRWltrJp4CVakyDz
# REn4cw8SKaSLlQuCh7yyJvz3ylr3xjQcXQHFyVJVtGXlLS/yUeU0CsuOnCtwqPOW
# aSvhvvPCOJ0QdniweCWYlXqnv61fbdF+vVMdA1KfKNAqlTnkxBfegPQ7dJ4gAZr/
# n/729LfZsOcLDJw49e4CdhpbRZjVHKibr3zi6Lw=
# SIG # End signature block
