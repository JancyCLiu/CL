#!/bin/bash
# the BMC auto testing
# write date : 2022/12/27
# written by : Cindy Liu
# for the auto testing way and run the result
echo Full Auto Testing Log Files
echo -e "\e[5m\e[45mDo Not shut Down Your Computer\e[0m"
sleep 5s
echo Five seconds count down……
sleep 5s
echo the testing date :
date
date >>infolog01_Test-Date.txt
sleep 10s

# Mac Address
echo "Testing FW BMC MAC address"
ipmitool lan print | grep "MAC Address"
ipmitool lan print >>02-Mac-Addr.txt
sleep 5s
# BMC FRU Check
echo "Testing FW BMC FRU"
sleep 5s
ipmitool fru | grep " Board Product "
ipmitool fru | grep " Board Serial "
ipmitool fru | grep " Board Part Number "
ipmitool fru | grep " Products Serial "
ipmitool fru>>03-BMC-FRU.txt
# Firmware Name Check
echo "Testing FW name"
ipmitool raw 0x3a 0x33 | xxd -r -p ;echo
(ipmitool raw 0x3a 0x33 | xxd -r -p ;echo) >>04-FW-Name.txt
Sleep 5s
# Revision Check
echo "Testing FW revision"
ipmitool mc info | grep -i 'Firmware Revision'
ipmitool mc info | grep -i ' Manufacturer ID'
ipmitool mc info >>05-FW-Revision.txt
sleep 5s
# BMC self test
echo " Your BMC self test return info as below : "
ipmitool raw 0x6 0x4>>06-BMC-Self-Test.txt
sleep 5s
# All Sensor Name Check
echo " Sensor Names Checking "
sleep 10s
ipmitool sdr elist
ipmitool sdr elist >>07-Sensor-Name.txt
sleep 5s
# BIOS RTC Check
timedatectl status >>08-BIOS-RTC-Time.txt
# All Information
lshw >>infolog02_All-Info.txt
sleep 5s
#DONE#



