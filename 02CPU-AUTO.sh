#!/bin/bash
# the CPU auto testing
# write date : 2023/03/27
# written by : Cindy Liu
# for the auto testing way and run the result
echo This is the Full Auto Testing Tool
echo Please do not shut down your computer!
sleep 5s
echo Five seconds count down……
sleep 5s
echo the testing date :
cal
sleep 2s
#the BIOS Release Date:
dmidecode -s bios-release-date
dmidecode -s bios-release-date>>01-BIOS-Date.txt
#the BMC Release info:
ipmitool raw 0x3a 0x33 | xxd -r -p ;echo
(ipmitool raw 0x3a 0x33 | xxd -r -p ;echo) >>02-BMC-FW.txt
#the Memory running max size
dmidecode -t memory | grep "Size"
dmidecode -t memory | grep "Size">>03-Memory-Size.txt
#the Memory running max speed
dmidecode -t memory | grep "Speed"
dmidecode -t memory | grep "Speed">>04-Memory-Speed.txt
#the CPU Cores info
lscpu | grep "socket"
lscpu | grep "socket">>05-CPU-Cores.txt
#the CPU Threads info
lscpu | grep "Thread"
lscpu | grep "Thread">>06-CPU-Thread.txt
#the CPU Max Boost Clock info
lscpu | grep "max"
lscpu | grep "max">>07-CPU-Max.txt
#the CPU temperature
ipmitool sdr | grep -i CPU
ipmitool sdr | grep -i CPU>>08-CPU-Temperature.txt
sleep 10s

# All Information
lshw>>The-Whole-Info.txt
sleep 5s

# sort the log files into a zip file
echo sorting the log files into a zip file......
sleep 8s
zip -m The-Test-Log *.txt

# The Finish Line~ #
echo -e "\e[31;43mThis is the finish line!\e[0m"
sleep 2s
cowsay -f bunny "Your testing files are sorting into the zip already!" | lolcat -a -d 5
#DONE#


