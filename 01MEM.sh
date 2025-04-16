#!/bin/bash
# ----
# 1. for AVL test ((Memory/DIMM))
# 2. This will using the Q&A to process test
# 3. It can saving the log at the test tail
# ----
# write date : 2022/12/02 (YYYY/MM/DD)
# written by : Cindy Liu (Engineer Name)
# only for Memory test

##AVL TEST(Memory)##
echo "╭─────────────────────────────╮"
echo "│                             │"
echo "│      AVL_Memory TEST        │"
echo "│                             │"
echo "╰─────────────────────────────╯"
sleep 2s
##Test Count Down##
for i in {1..5}; do
    echo -n -e "\e[1;32m  Starting in $((6-i)) seconds...  \e[0m\r"
    sleep 1
	done
##Showing the Testing Date Frist##
echo Below is your testing date :
cal

#Configuration First#
echo -e "\e[31m\e[1mThe Configuration Check\e[0m"
sleep 5s
text=" Now, We will start output the Configuration Info: "
delay=0.2
for (( i=0; i<${#text}; i++ )); do
  echo -n "${text:$i:1}"
  sleep $delay
done
echo

sleep 5s
#Configuration = MB
echo -e "\e[31;47mThe MB :\e[0m" && \
ipmitool fru | grep -E "Board (Product|Serial|Part Number)"
#Configuration = BIOS
echo -e "\e[30;47m  BIOS Info :\e[0m\nBIOS F/W: $(dmidecode -s bios-version)"
#Configuration = BMC
echo -e "\e[30;47m  BMC FW :\e[0m\nBMC F/W: $(ipmitool raw 0x3a 0x33 | xxd -r -p ;echo | cut -f2)"
#Configuration = CPU
echo -e "\e[30;47m CPU-0 :\e[0m" && lscpu | grep "Model name" && \
echo -e "\e[30;47m CPU-1 :\e[0m" && lscpu | grep "Model name"
#Configuration = Memory
echo -e "\e[31;47mThe Memory :\e[0m" && \
dmidecode -t memory | \
grep -E "Manufacturer|Part Number|Type|Speed|Size" | \
awk -F': ' '{
    if (!seen[$2]++) {
        if(/Manufacturer/) {print ""; print "Manufacturer: " $2} 
        else if(/Part Number/) {print "Part Number: " $2} 
        else if(/Type/ && $0 !~ /Detail/) {print "Type: " $2} 
        else if(/Speed/) {print "Speed: " $2} 
        else if(/Size/ && $0 !~ /No Module Installed/) {print "Size: " $2}
    }
}'
sleep 5s
#Configuration = SSD/HDD
echo -e "\e[30;47mThe SSD/HDD :\e[0m" && lsblk -o MODEL,SIZE
#Configuration = OS
echo -e "\e[31;47mThe OS info :\e[0m\nDescription: $(lsb_release -d | cut -f2)\nKernel: $(uname -r)"
echo "------------------------------------"
sleep 15s


# The Test Start Now #
echo **********************************************************************
echo **                                                                  **
echo **  AVL is what for Approval Vendors List.                          **
echo **  The main function of AVL testing is to provide reference values,**
echo **  for system equipment use.                                       **
echo **  you can be automatically save the test log.                     **
echo **                                                                  ** 
echo **                         Copyright©  2024 / Engineer by Cindy Liu.**
echo **                                             All rights reserved. **
echo **********************************************************************
sleep 5s


#Check on the BIOS Release Date:
read -p "Are you ready to check the BIOS Release Date? [Y/N]" yn
case $yn in
    [Yy]* ) echo "the BIOS Release Date is: $(dmidecode -s bios-release-date)"; break;;
    [Nn]* ) echo "Oh, now exit this test"; exit;;
    * ) echo "Please answer Y or N.";;
  esac
sleep 2s
##BIOS Release Date log file save :
dmidecode -s bios-release-date>>01-BIOS-Date.txt
sleep 5s

#Check on the BMC Release info:
echo Please use the BMC Firmware to check the Release Date
read -p "Are you ready to check the BMC Firmware Name? [Y/N]" yn
case $yn in
    [Yy]* ) echo "the BMC Firmware Name is: $(ipmitool raw 0x3a 0x33 | xxd -r -p ;echo)"; break;;
    [Nn]* ) echo "Oh, now exit this test"; exit;;
    * ) echo "Please answer Y or N.";;
  esac
sleep 2s
##BMC Release info lof file save :
(ipmitool raw 0x3a 0x33 | xxd -r -p ;echo)>>02-BMC-FW.txt
sleep 5s

#Check on the Memory Size:
echo Please check on the size information:
read -p "Are you ready to check the Memory Size now? [Y/N]" yn
[ "${yn}" == "Y" -o "${yn}" == "y" ] && echo "Below is the Memory information" && lsmem
[ "${yn}" == "N" -o "${yn}" == "n" ] && echo "It need be on sure for this info" && exit 0
sleep 2s
##Memory size log file save :
lsmem>>03-Memory-Size.txt
sleep 5s

# sort the log files into a zip file
echo sorting the log files into a zip file......
sleep 8s
zip -m TheTestlog *.txt

#DONE#

