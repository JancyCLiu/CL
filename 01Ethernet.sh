#!/bin/bash
# Ethernet AVL Test
# write date : 2023/03/25
# written by : Cindy Liu
# for more easily way to test and run the result.
# this will also auto running out the log file.
echo -e "\e[15;45mThis tool will also saving the test log in the same time :\e[0m"
sleep 5s
echo Below is your testing date :
date

#Configuration First#
echo Before you start the testing, this will shows the configuration info at first :
echo -e "\e[31;47mThe System :\e[0m"
dmidecode -s baseboard-product-name
sleep 2s
echo -e "\e[31;47mThe MB :\e[0m"
ipmitool fru | grep " Board Product "
ipmitool fru | grep " Board Part Number "
ipmitool fru | grep " Board Serial "
sleep 2s
echo -e "\e[31;47mThe BIOS :\e[0m"
dmidecode -s bios-version
sleep 2s
echo -e "\e[31;47mThe BMC :\e[0m"
ipmitool raw 0x3a 0x33 | xxd -r -p ;echo
sleep 2s
echo -e "\e[31;47mThe CPU :\e[0m"
lscpu | grep "Model name"
sleep 2s
echo -e "\e[31;47mThe Memory :\e[0m"
dmidecode -t memory | grep "Manufacturer"
dmidecode -t memory | grep "Part Number"
dmidecode -t memory | grep "Size"
sleep 2s
echo -e "\e[31;47mThe HDD info :\e[0m"
lsblk -o MODEL
lsblk -o SIZE | grep -i G
sleep 2s
echo -e "\e[31;47mThe OS info :\e[0m"
uname -a
sleep 2s
echo -e "\e[31;47mThe Card Name info :\e[0m"
lspci -s ${eth1} -vvv | grep -i Subsystem
sleep 2s
echo -e "\e[31;47mThe Card MAC info :\e[0m"
lspci | grep "Device Serial Number"
sleep 5s
echo "------------------------------------"
sleep 5s

echo Start Test Now.

#Check on the BIOS Release Date:
read -p "Are you ready to check the BIOS Release Date? [Y/N]" yn
case $yn in
    [Yy]* ) echo "the BIOS Release Date is: $(dmidecode -s bios-release-date)"; break;;
    [Nn]* ) echo "Oh, now exit this test"; exit;;
    * ) echo "Please answer Y or N.";;
  esac
echo Awating for the Log File running....
sleep 2s
#BIOS FW Check and Log file save :
dmidecode -s bios-version>>01-BIOS-Version.txt
sleep 2s
#BIOS Release Date log file save :
dmidecode -s bios-release-date>>02-BIOS-Date.txt
sleep 5s
#Check on the BMC Release info:
echo Please use the BMC Firmware to check the Release Date
read -p "Are you ready to check the BMC Firmware Name? [Y/N]" yn
case $yn in
    [Yy]* ) echo "the BMC Firmware Name is: $(ipmitool raw 0x3a 0x33 | xxd -r -p ;echo)"; break;;
    [Nn]* ) echo "Oh, now exit this test"; exit;;
    * ) echo "Please answer Y or N.";;
  esac
echo Awating for the Log File running....
sleep 2s
#BMC Release info lof file save :
(ipmitool raw 0x3a 0x33 | xxd -r -p ;echo)>>03-BMC-FW.txt
sleep 5s

#Check the Ethernet controller info:
echo Await for the info to show up
echo We need to copy the info for __:__:_ as below:
lspci | grep -i ethernet
echo -e "\e[31;47m**Please remember copy above info as Configuration need**\e[0m"

#Check on the Ethernet info for twice:
##1##
echo We need to check twice for the Ethernet Infromation
echo This is the First Check
read -p "Type the Ethernet Rev to check on the more info that we needed " eth1
lspci -s ${eth1} -vvv
sleep 2s
lspci -s ${eth1} -vvv>>04-Eth01-info.txt
sleep 5s
echo To make more easily way to check:
lspci -s ${eth1} -vvv | grep -i Subsystem
sleep 5s
lspci -s ${eth1} -vvv | grep -i LnkCap
sleep 5s
echo The info should to show on OK as below!
lspci -s ${eth1} -vvv | grep -i LnkSta
sleep 5s
#Check on the Ethernet info for twice:
##2##
echo We need to check twice for the Ethernet Infromation
echo This is the Second Check
lspci | grep -i ethernet
read -p "Type the Ethernet Rev to check on the more info that we needed " eth2
lspci -s ${eth2} -vvv
sleep 2s
lspci -s ${eth2} -vvv>>05-Eth02-info.txt
sleep 5s
echo To make more easily way to check:
lspci -s ${eth2} -vvv | grep -i Subsystem
sleep 5s
lspci -s ${eth2} -vvv | grep -i LnkCap
sleep 5s
echo The info should to show on OK as below!
lspci -s ${eth2} -vvv | grep -i LnkSta
sleep 5s

# The All Info
echo Get all information for this system.
lshw>>06-All-Info.txt
sleep 5s

# record the test date
date>>07-The-Test-Date.txt
sleep 5s

# sort the logs into a zip file
echo The log files sorting......
sleep 8s
zip -m The-Test-Log *.txt

# This is the finish line!! #
echo -e "\e[31;43mThis is the finish line!\e[0m"
sleep 2s
cowsay -f sheep "Your testing files are sorting into the zip already!" | lolcat -a -d 5
#DONE#

