#!/bin/bash
# ----
# 1. It will detecte the Configuration info first
# 2. The bash will using the Q&A to process test
# 3. It can saving the log at the test tail
# ----
# the BIOS Q&A testing
# write date : 2022/12/02 (YYYY/MM/DD)
# written by : Cindy Liu (Engineer Name)
# only for BIOS FW test

##BIOS TEST##
echo "╭─────────────────────────────╮"
echo "│                             │"
echo "│     BIOS FIRMWARE TEST      │"
echo "│                             │"
echo "╰─────────────────────────────╯"
sleep 2s
##Test Count Down##
for i in {1..5}; do
    echo -n -e "\e[1;32m  Starting in $((6-i)) seconds...  \e[0m\r"
    sleep 1
	done
##Check the System Frist##
echo -e "\e[5m\e[30m\e[43mDetecting Board and Version\e[0m"
sleep 10s
dmidecode -t baseboard | grep -i "Product Name"
sleep 5s
ipmitool raw 0x3c 0x03 | xxd -r -p ;echo
sleep 5s
echo -e "\e[31m\e[47mPlease ensure above info are all correct\e[0m"
sleep 10s

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

#Configuration = CPU
echo -e "\e[30;47m CPU-0 :\e[0m" && lscpu | grep "Model name" && \
echo -e "\e[30;47m CPU-1 :\e[0m" && lscpu | grep "Model name"
#Configuration = MB
echo -e "\e[30;47m MB :\e[0m" && \
ipmitool fru | grep -E "Board (Product|Serial|Part Number)"
#Configuration = Memory
echo -e "\e[30;47m  Memory :\e[0m" && \
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
#Configuration = BIOS
echo -e "\e[30;47m  BIOS Info :\e[0m\nBIOS F/W: $(dmidecode -s bios-version)"
#Configuration = BMC
echo -e "\e[30;47m  BMC FW :\e[0m\nBMC F/W: $(ipmitool raw 0x3a 0x33 | xxd -r -p ;echo | cut -f2)"
#Configuration = SSD/HDD
echo -e "\e[30;47mThe SSD/HDD :\e[0m" && fdisk -l | grep -i model
#Configuration = OS
echo -e "\e[30;47mThe OS info :\e[0m\nDescription: $(lsb_release -d | cut -f2)\nKernel: $(uname -r)"
echo "------------------------------------"
sleep 5s

# Press Down:
echo -e "\e[5;42m Press the down key to continue test \e[0m"
sleep 2s
while true; do
    read -n 1 -s key1
    if [ "$key1" == $'\e' ]; then
        read -n 2 -s key2
        key="$key1$key2"
        if [ "$key" == $'\e[B' ]; then
            echo "You pressed the down arrow key. Continuing with the test..."
            sleep 5s
            break
        else
            echo "Please press the down arrow key to continue."
        fi
    else
        echo "Please press the down arrow key to continue."
    fi
done


# The Test Start Now #
echo " **************************************************************** "
echo " ** ////                                                  //// ** "
echo " **  This program is provided for the server BIOS FW testing.  ** "
echo " **  Please do not power off during the process,               ** "
echo " **  As the testing nears completion,                          ** "
echo " **  the system will perform checks and then shut down.        ** "
echo " **                                                            ** " 
echo " **                  Copyright©  2024 / Engineer by Cindy Liu. ** "
echo " **                                       All rights reserved. ** "
echo " **************************************************************** "
sleep 5s

# MD5 SUM Check:
echo -e "\e[32m We are now need to start testing the MD5 checksum \e[0m"
echo -e "\e[5;44m Detecting the directory  \e[0m" 
sleep 2s && ls
read -p "Please paste the documents which you want to check " md5
md5sum *${md5}
md5sum *${md5}>>01-MD5checksum.txt && sleep 5s

# BIOS Release Date:
read -p "Start to check the BIOS Release Date? [Y/N]" yn
[ "${yn}" == "Y" -o "${yn}" == "y" ] && echo "please confirm with the Release Note: " && dmidecode -s bios-release-date
[ "${yn}" == "N" -o "${yn}" == "n" ] && echo "the date won’t check & will exit this test" && exit 0

# BMC Release Firmware Check & repling to the Date from mail
read -p "Ready for the check with the BMC Firmware? [Y/N]" yn
[ "${yn}" == "Y" -o "${yn}" == "y" ] && echo "please confirm with the Release Note: " && ipmitool raw 0x3a 0x33 | xxd -r -p
[ "${yn}" == "N" -o "${yn}" == "n" ] && echo "the date won’t check & will exit this test" && exit 0
sleep 3s

# Print again the FW and echo the right info
echo "This line will show again the BMC Firmware make you clearly to check."
ipmitool raw 0x3a 0x33 | xxd -r -p ;echo
echo check on your release mail for the FW name and date!
sleep 5s

# Mac Address Check:
while true; do
    read -p "Are you ready to check the Mac Address? [Y/N] " yn
    ## The Y/N answer ## 
    if [[ "${yn}" == "Y" || "${yn}" == "y" ]]; then
        echo "Here to check the BMC Mac Address"
        macaddr=$(ipmitool lan print)
        # PASS/FAIL Results
        if echo "$macaddr" | grep -q "00:15:b2"; then
            echo -e "\e[32m BMC Mac Address PASS \e[0m"
        else
            echo -e "\e[31m BMC Mac Address FAIL \e[0m"
        fi
        # ASRR MB message
        if echo "$macaddr" | grep -q "a8:a1:59:fd"; then
            echo -e "\e[33m we detected the ASRR MB, please check with your project. \e[0m"
        fi
        break
    ## The Y/N answer ## 
    elif [[ "${yn}" == "N" || "${yn}" == "n" ]]; then
        echo "The test might be not finish!"
    else
        echo "Invalid input, please enter Y or N."
    fi
done
sleep 5s

# BIOS Version:
read -p "Ready to start the data check after BIOS update? [Y/N]" yn
[ "${yn}" == "Y" -o "${yn}" == "y" ] && echo "The BIOS Version is" && dmidecode -s bios-version
echo "also check with the 37 test item!"
[ "${yn}" == "N" -o "${yn}" == "n" ] && echo "if you typo this still will show the version to you: " && dmidecode -t bios

# confirm with the next step or not:
echo "Now jump to the test items for CPU/Memory/NUMA DATA to continue check!"
sleep 10s

# for CPU recognition check:
read -p "If you want to continue checking the CPU, type CPU " CPU
dmidecode -t processor
echo -e "go check the ${CPU} info above"

# for Memory size/speed detection:
read -p "If you want to continue checking the Memory, type Memory " Memory
lsmem
echo -e "go check the ${Memory} info above"

# NUMA DATA:
read -p "Do you want to continue run the NUMA DATA? [Y/N]" yn
[ "${yn}" == "Y" -o "${yn}" == "y" ] && echo "OK, continue" && numactl --hardware
[ "${yn}" == "N" -o "${yn}" == "n" ] && echo "Oh, now exit this test" && exit 0
sleep 5s

# Intel(R) HT Technology function check
echo " After checking the NUMA DATA, now still need to check the technology# "
read -p "Are you ready for check the Intel(R) HT Technology function? [Y/N] " yn
[ "${yn}" == "Y" -o "${yn}" == "y" ] && echo "The Intel(R) HT Technology# is:" && cat /proc/cpuinfo | grep processor | wc -l
[ "${yn}" == "N" -o "${yn}" == "n" ] && echo "OK, the testing will stop now...." && exit 0
sleep 2s

# The checking details (for CPU/NUMA)
echo Please check the info as above result for the data correct or not.
sleep 2s
lscpu | grep -i "CPU(s)" && \
lscpu | grep -i "Thread" && \
lscpu | grep -i "NUMA node"
sleep 5s

# about devices check and stress:
echo -e "\e[5m\e[45mThe device recognition test items start now.\e[0m"
echo -e "\e[5m\e[31mfive seconds awaiting.....\e[0m"
sleep 10s
##Device recognition (CPU)##
echo " The device recognition of CPUs. "
read -p "Are you ready for checking the CPU recognition? [Y/N] " yn
[ "${yn}" == "Y" -o "${yn}" == "y" ] && echo "Please make sure that your CPU has been recognize: " && lscpu | grep "Model name"
[ "${yn}" == "N" -o "${yn}" == "n" ] && echo "OK, the testing will stop now...." && exit 0
sleep 5s
##Stress check (CPU)##
#only use the QT Cycling Test Script for stress test#
##Device recognition (Memory)##
echo " The device recognition of Memory. "
read -p "Are you ready for checking the Memory recognition? [Y/N] " yn
[ "${yn}" == "Y" -o "${yn}" == "y" ] && echo "Please check on your memory size and number: " && lsmem
[ "${yn}" == "N" -o "${yn}" == "n" ] && echo "OK, the testing will stop now...." && exit 0
sleep 5s

##Stress check (Memory)##
#only use the QT Cycling Test Script for stress test#

echo -e "\e[5m\e[20;45m  Now this testing is already done for 70%\e[0m"
sleep 3s
echo -e "\e[33m\e[4m  We only need to check some details for this project.\e[0m"
sleep 15s
# if the data run is good (sensor reading)
read -p "Are you ready for check the all BMC sensor reading? [Y/N] " yn
[ "${yn}" == "Y" -o "${yn}" == "y" ] && echo "OK, now start test the time" && ipmitool sensor
[ "${yn}" == "N" -o "${yn}" == "n" ] && echo "Oh, please go to check the time setting" && exit 0
sleep 5s
echo -e "\e[33m\e[4mDetecing the ERROR info\e[0m"
sleep 2s
ipmitool sensor | grep "error"
sleep 5s

# KCS Function check:
echo -e "\e[31m\e[1mPlease check your Keyboard\\Mouse\\Screen\e[0m"
read -p "If Keyboard OK, please type OK " Keyboard
read -p "If Mouse OK, please type OK " Mouse
read -p "If Screen OK, please type OK " Screen
echo -e "your Keyboard is ${Keyboard},Mouse is ${Mouse},Screen is ${Screen}"
sleep 5s

# the RTC check:
read -p "Are you ready to check the BIOS RTC? [Y/N]" yn
[ "${yn}" == "Y" -o "${yn}" == "y" ] && echo "OK, now start test the time" && ipmitool sel time get
[ "${yn}" == "N" -o "${yn}" == "n" ] && echo "Oh, please go to check the time setting" && exit 0
echo -e "\e[30;47m This is your time for now: \e[0m"
echo `date`
read -p "Do you want to contiune to check the local BIOS RTC? [Y/N]" yn
[ "${yn}" == "Y" -o "${yn}" == "y" ] && echo -e "\e[30;47m Below is your local time: \e[0m" && hwclock --localtime
[ "${yn}" == "N" -o "${yn}" == "n" ] && echo "Oh, please go to check the time setting" && exit 0

# FRU check:
while true; do
    read -p "Continue to check the BMC Revison? [Y/N] " yn
    ## The Y/N answer ## 
    if [[ "${yn}" == "Y" || "${yn}" == "y" ]]; then
        echo " The BMC FW Revison is: "
        FWrev=$(ipmitool mc info)
        # PASS/FAIL Results
        if echo "$FWrev" | grep -q "Manufacturer ID           : 42385"; then
            echo -e "\e[32m BMC Firmware Revison PASS \e[0m"
        else
            echo -e "\e[31m BMC Firmware Revison FAIL \e[0m"
        fi
        break
    ## The Y/N answer ##    
    elif [[ "${yn}" == "N" || "${yn}" == "n" ]]; then
        echo "The test might be not finish!"
    else
        echo "Invalid input, please enter Y or N."
    fi
done
sleep 10s

# The First Test Finish Line #
echo -e "\e[5m\e[42m     BIOS Firmware Test Done     \e[0m"
sleep 5s

## complete line ##
echo -e "\e[7m\e[35m  THE TESTING NEARS COMPLETION   \e[0m"
# background AUTO-LOG ((02BIOS))
sleep 10s
echo -e "\e[5;42m  If all results are GOOD  \e[0m"
sleep 5s
read -p "Do you need the log files sorting? [Y/N]" yn
[ "${yn}" == "Y" -o "${yn}" == "y" ] && echo -e "\e[5m\e[30;43m  **Log Files Sort Processing**  \e[0m" && nohup ./02BIOS-AUTO.sh
[ "${yn}" == "N" -o "${yn}" == "n" ] && echo -e "\e[37;91m Seems you do not need the log file, this test will immediately exit.\e[0m" && exit 0
sleep 5s
# sort the log files into a zip file
echo -e "\e[43mPlease set a name of your test log \e[0m"
read -p " Enter your file name : " logname
logname="${logname}_test_log"
zip -m ${logname} *.txt
# log files done
echo -e "\e[5m\e[30;43m  **Log Files Sort Done**  \e[0m"
sleep 15s


# The IPMI command boot in BIOS and Warm boot cycle up:
##Set the net boot to bios##
echo -e "\e[93mThe IPMI command boot in BIOS test item \e[0m"
read -p "Start to test the ipmi boot in command?(Y/N): " yn
if [[ "${yn}" == "Y" || "${yn}" == "y" ]]; then
	echo -e "\e[5m\e[20;45m setting the ipmi command to boot in BIOS \e[0m"
    ipmitool chassis bootdev bios options=efiboot && sleep 10s
elif [[ "${yn}" == "N" || "${yn}" == "n" ]]; then
	echo " Seems you no need to check the boot command "
	echo " The test will continue to next warm power off test " && sleep 5s
else
	echo "Invalid input, please enter Y or N"
	exit 1
fi
##Set the power action##
read -p "Start the power action? (Y/N): " yn
if [[ "${yn}" == "Y" || "${yn}" == "y" ]]; then
	echo -e "\e[30;43mPlease have your check for later BIOS set up menu will in the first boot in or not\e[0m"
	echo -e "\e[5m\e[41m  **WARNING  **POWER WILL SHUT DOWN in 10s**  WARNING**  \e[0m"
    sleep 10s && ipmitool power reset
elif [[ "${yn}" == "N" || "${yn}" == "n" ]]; then
	echo " Please choose your power off time: "
	read -p "[A.15s\\B.20s\\C.25s]" abc
	[ "${abc}" == "A" -o "${abc}" == "a" ] && echo "power off count down 15s" && sleep 15s && ipmitool power off
	[ "${abc}" == "B" -o "${abc}" == "b" ] && echo "power off count down 20s" && sleep 20s && ipmitool power off
	[ "${abc}" == "C" -o "${abc}" == "c" ] && echo "power off count down 25s" && sleep 25s && ipmitool power off
else
	read -p "Please input the STOP reason :" STOP
        echo -e "Due to the ${STOP}, the test will exit now."
	exit 1
fi

# Second Test Finish Line #
echo " ██████╗  ██████╗ ███╗   ██╗███████╗ "
echo " ██╔══██╗██╔═══██╗████╗  ██║██╔════╝ "
echo " ██║  ██║██║   ██║██╔██╗ ██║█████╗ "
echo " ██║  ██║██║   ██║██║╚██╗██║██╔══╝ "
echo " ██████╔╝╚██████╔╝██║ ╚████║███████╗ "
echo " ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝ "
exit 1

## END LINE ##





