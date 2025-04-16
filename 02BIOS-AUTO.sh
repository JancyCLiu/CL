#!/bin/bash
# the BIOS auto testing
# write date : 2023/03/07
# written by : Cindy Liu
# for the auto testing way and run the result
echo This is the Full Auto Testing Tool
echo Please do not shut down your computer!
sleep 5s
echo Five seconds count down……
sleep 5s
echo the testing date :
date
date >>infolog01_Test-Date.txt
sleep 2s
echo Start Test Now

# BIOS Release Date
echo "Item for BIOS release date :"
dmidecode -s bios-release-date
dmidecode -s bios-release-date>02-BIOS-Release-Date.txt
sleep 5s
# Mac Address
echo "the Mac Address info as below :"
ifconfig | grep "ether"
ifconfig>>03-1-MacAddress.txt
sleep 2s
ipmitool lan print | grep "ether"
ipmitool lan print>>03-2-MacAddress.txt
sleep 5s
# BIOS Version
echo "the BIOS Version info as below :"
dmidecode -s bios-version
dmidecode -t bios>>04-BIOS-Version.txt
sleep 5s
#CPU Model Name
echo "Please check the CPU Model Name :"
lscpu | grep "Model name:"
dmidecode -t processor >>05-CPU.txt
sleep 8s
# Memory Size
echo "Please check the Memory Size :"
lsmem | grep "Total online memory:"
lsmem>>06-Memory.txt
sleep 8s
# NUMA DATA
echo "It's time to check the NUMA DATA info :"
numactl --hard
numactl --hard >>07-NUMA-DATA.txt
sleep 8s
# BMC sensor reading
echo "Check all BMC sensor reading :"
ipmitool sensor
ipmitool sensor>>08-BMC-Sensor.txt
sleep 10s
# Intel(R) HT Technology function check
echo "Item 50 test result in two ways check"
cat /proc/cpuinfo | grep processor | wc -l
cat /proc/cpuinfo | grep processor | wc -l>>09-HT-Technology-check.txt
sleep 3s
echo "Also check with the cpu info"
lscpu | grep "CPU(s)"
sleep 10s
# KCS function check
echo "Make sure that your Keyboard Controller Style is OK"
echo "await for the next test..."
sleep 10s
# RTC(time check)
echo "The RTC check in two ways"
echo `date`
ipmitool sel time get
sleep 3s
hwclock --localtime
ipmitool sel time get>>10-Time1.txt
hwclock --localtime >>11-Time2.txt
sleep 5s
# BMC FRU
ipmitool fru | grep "Board Product"
ipmitool fru>>12-FRU01.txt
dmidecode -t baseboard | grep "Product Name:"
dmidecode -t baseboard>>12-FRU02.txt
sleep 10s
# OEM Version Set/Get
echo "OEM Set and Get (Item:89,90)"
ipmitool raw 0x3c 0x03
sleep 5s
ipmitool raw 0x3c 0x03 | xxd -r -p ;echo
ipmitool raw 0x3c 0x03>>13-OEM-Version.txt
sleep 5s
# OEM CPU Set
echo "OEM CPU Set and Get (Item:91,92)"
ipmitool raw 0x3a 0x2b 0x1
sleep 5s
ipmitool raw 0x3a 0x2b 0x1 | xxd -r -p ;echo
ipmitool raw 0x3a 0x2b 0x1>>14-OEM-CPU.txt
sleep 5s
# All Information
lshw>>infolog02_All-Info.txt
# BIOS Information
dmidecode -t bios>>infolog03_All-BIOS-Info.txt
sleep 5s
#DONE#
