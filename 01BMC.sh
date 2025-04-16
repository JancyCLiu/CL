#!/bin/bash
# ----
# 1. It will detecte the Configuration info first
# 2. This will using the Q&A to process test
# 3. It can saving the log at the test tail
# ----
# write date : 2022/12/02 (YYYY/MM/DD)
# written by : Cindy Liu (Engineer Name)
# only for BMC FW test

##BMC TEST##
echo "╭─────────────────────────────╮"
echo "│                             │"
echo "│      BMC FIRMWARE TEST      │"
echo "│                             │"
echo "╰─────────────────────────────╯"
sleep 2s
##Test Count Down##
for i in {1..5}; do
    echo -n -e "\e[1;32m  Starting in $((6-i)) seconds...  \e[0m\r"
    sleep 1
	done
##Check the System Frist##
echo -e "\e[5m\e[30m\e[43m Detecting Board and Version\e[0m"
sleep 10s
dmidecode -t baseboard | grep -i "Product Name" && \
ipmitool raw 0x3a 0x33 | xxd -r -p ;echo && \
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
#Configuration = MB
echo -e "\e[31;47mThe MB :\e[0m" && \
ipmitool fru | grep -E "Board (Product|Serial|Part Number)"
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
#Configuration = BIOS
echo -e "\e[30;47m  BIOS Info :\e[0m\nBIOS F/W: $(dmidecode -s bios-version)"
#Configuration = BMC
echo -e "\e[30;47m  BMC FW :\e[0m\nBMC F/W: $(ipmitool raw 0x3a 0x33 | xxd -r -p ;echo | cut -f2)"
#Configuration = SSD/HDD
echo -e "\e[30;47mThe SSD/HDD :\e[0m" && fdisk -l | grep -i model
#Configuration = OS
echo -e "\e[31;47mThe OS info :\e[0m\nDescription: $(lsb_release -d | cut -f2)\nKernel: $(uname -r)"
echo "------------------------------------"
sleep 15s

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
echo " ********************************************************************** "
echo " **  ////                                                      ////  ** "
echo " **  This program is provided for testing the FW of the server BMC.  ** "
echo " **  Please do not arbitrarily turn off the power during use,        ** "
echo " **  At the end of the test process,                                 ** "
echo " **  you can be automatically save the test log.                     ** "
echo " **                                                                  ** "
echo " **                         Copyright©  2024 / Engineer by Cindy Liu.** "
echo " **                                             All rights reserved. ** "
echo " ********************************************************************** "
sleep 5s

# MD5 SUM Check:
echo -e "\e[32m We are now need to start testing the MD5 checksum \e[0m"
echo -e "\e[5;44m Detecting the directory  \e[0m" 
sleep 2s && ls
read -p "Please paste the documents which you want to check " md5
md5sum *${md5}
md5sum *${md5}>>01-MD5checksum.txt && sleep 5s

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

# FRU check:
read -p "Ready to check up the BMC FRU? [Y/N]" yn
[ "${yn}" == "Y" -o "${yn}" == "y" ] && echo "OK, please check the data below:" && ipmitool fru && dmidecode -t baseboard
[ "${yn}" == "N" -o "${yn}" == "n" ] && echo "Oh, the test will be over." && exit 0
sleep 5s

# BMC FW Name check:
read -p "Continue to check the BMC FW? [Y/N]" yn
[ "${yn}" == "Y" -o "${yn}" == "y" ] && echo "The BMC FW name is:" && ipmitool raw 0x3a 0x33 | xxd -r -p ;echo
[ "${yn}" == "N" -o "${yn}" == "n" ] && echo "Oh, the test will be over." && exit 0
sleep 5s

# BMC FW Revison check:
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
sleep 5s

# Basic KCS function check:
echo -e "\e[30;43m  the Keyboard Controller Style(KCS Function) status check  \e[0m"
read -p "How is your Keyboard?  (good/bad) " K
read -p "How is your Mouse?  (good/bad) " C
read -p "How is your Screen?  (good/bad) " S
sleep 2s
echo -e "\e[5m\e[30;43m  Detecting the KCS status..  \e[0m" 
sleep 5s
echo -e "The basic KCS function check result: Keyboard is ${K}, Mouse is ${C}, Screen is ${S}."
sleep 8s

#BMC Self Test(55 00):
echo -e "\e[32m  *BMC Self Test Check*  \e[0m"
sleep 2s
while true; do
    read -p "Continue to check the BMC Self Test? [Y/N] " yn
    ## The Y/N answer ## 
    if [[ "${yn}" == "Y" || "${yn}" == "y" ]]; then
        echo " The Return Number is: " && \
        ipmitool raw 0x6 0x4
        BMCselfno=$(ipmitool raw 0x6 0x4)
        # PASS/FAIL Results
        if echo "$BMCselfno" | grep -q "55 00"; then
            echo -e "\e[42m BMC Self Test Check PASS \e[0m"
        else
            echo -e "\e[41m BMC Self Test Check FAIL \e[0m"
        fi
        break
    ## The Y/N answer ##    
    elif [[ "${yn}" == "N" || "${yn}" == "n" ]]; then
        echo "The test might be not finish!"
    else
        echo "Invalid input, please enter Y or N."
    fi
done

# Basic IOL connection check:
echo -e "\e[5;44m The Basic IOL Function Check \e[0m" && sleep 5s \
echo -e "\e[4m Please set your own ssh ip to check the IOL Function. \e[0m"
echo "  Please copy below info to later test using.  "
ip a | grep -i "inet"
sleep 5s
read -p "Please enter your own local ssh IP  " issh
ssh ${issh} ipmitool sdr elist
sleep 5s

# Basic SOL connection check:
echo -e "\e[5;44m The Basic SOL Function Check \e[0m" && sleep 5s \
echo -e "\e[4m Please set the remote ssh ip to check the SOL Function. \e[0m"
read -p "Please enter your remote ssh IP  : " sship
echo "Please recheck the below info and enter to later test.... "
ipmitool lan print | grep "IP Address"
read -p "Please copy above info (BMC IP) for SOL test needed : " BMCIP
read -p "Please enter the BMC Name for later test (admin) : " BMCN
read -p "Please enter the BMC Password for later test (admin123) : " BMCP
sleep 5s
# SOL info setting and checking:
read -p "ready to check the SOL Function? [Y/N]" yn
[ "${yn}" == "Y" -o "${yn}" == "y" ] && echo "SOL Function Test Start : " && ssh ${sship} ipmitool -I lanplus -H ${BMCIP} -U ${BMCN} -P ${BMCP} sol set && sleep 5s
[ "${yn}" == "N" -o "${yn}" == "n" ] && echo "Please get back to complete your test." && exit 0
echo -e "\e[5mSetting to the SOL ACTIVATE\e[0m" && \
ssh ${sship} ipmitool -I lanplus -H ${BMCIP} -U ${BMCN} -P ${BMCP} sol activate
sleep 5s
echo -e "\e[5mSetting to the SOL DEACTIVATE\e[0m" && \
ssh ${sship} ipmitool -I lanplus -H ${BMCIP} -U ${BMCN} -P ${BMCP} sol deactivate
sleep 10s

# The Sensor Reading Check:
echo -e "\e[5m\e[41mThe Sensor Reading Check\e[0m"
sleep 5s
read -p "ready to check the Sensor Reading? [Y/N]" yn
[ "${yn}" == "Y" -o "${yn}" == "y" ] && echo -e "\e[7m\e[33mPlease open the SDR list to check\e[0m" && sleep 5s && ipmitool sdr elist
[ "${yn}" == "N" -o "${yn}" == "n" ] && echo "Please get back to complete your test." && exit 0
sleep 5s
echo -e "\e[7m\e[31mPlease make sure the reading has no abnormal\e[0m"
sleep 5s
echo -e "\e[5m\e[33mAwaiting the results checking without any error.....     please wait...\e[0m"
sleep 5s
ipmitool sdr elist | grep -i "error"
sleep 8s
echo -e "\e[5m\e[33m checking the results....   please await...\e[0m"
# Check the sensor reading without abnormal
output=$(ipmitool sdr elist | grep -i "na")
## abnormal yes or not
if [ -z "$output" ]; then
    echo -e "\e[42m  No any abnormal of sensor reading  \e[0m"
else
    echo "$output" && echo -e "\e[41m  Detected some abnormal  \e[0m"
fi
sleep 5s
output=$(ipmitool sdr elist | grep -i "ns")
## output yes or not
if [ -z "$output" ]; then
    echo -e "\e[42m  No any abnormal of sensor reading  \e[0m"
else
    echo "$output" && echo -e "\e[41m  Detected some abnormal  \e[0m"
fi
sleep 10s

# The Time Check Zone:
echo -e "\e[30;41mThe Server Time Function Check\e[0m"
sleep 5s
read -p "ready to check the Time? [Y/N]" yn
[ "${yn}" == "Y" -o "${yn}" == "y" ] && echo -e "\e[5m\e[33mBelow will start to check the time\e[0m"
[ "${yn}" == "N" -o "${yn}" == "n" ] && echo "Please get back to complete your test." && exit 0
sleep 5s
echo -e "\e[36m    #1 The FIRST WAY     \e[0m"
sleep 5s
timedatectl status && sleep 8s
echo -e "\e[32m    #2 The SECOND WAY    \e[0m"
hwclock --utc && sleep 8s
echo -e "\e[35m    #3 The THIRD WAY     \e[0m"
timeconfig --utc && sleep 10s


## complete line ##
echo -e "\e[7m\e[35m  THE TESTING NEARS COMPLETION   \e[0m"
# background AUTO-LOG ((02BMC))
sleep 10s
echo -e "\e[5;42m  If all results are GOOD  \e[0m"
sleep 5s
read -p "Do you need to sorting the log files? [Y/N]" yn
[ "${yn}" == "Y" -o "${yn}" == "y" ] && echo -e "\e[5m\e[30;43m  **Log Files Sort Processing**  \e[0m" && nohup ./02BMC-AUTO.sh
[ "${yn}" == "N" -o "${yn}" == "n" ] && echo -e "\e[30;43m**Test has been exit**\e[0m" && echo "No log files but already done for this FW test !" && exit 0
sleep 5s
echo -e "\e[5m\e[43m  **Log Files Sort Done**  \e[0m"
sleep 15s
# sort the log files into a zip file
echo -e "\e[43mPlease set a name of your test log \e[0m"
read -p " Enter your file name : " logname
logname="${logname}_test_log"
zip -m ${logname} *.txt
# log files done
echo -e "\e[5m\e[30;43m  **Log Files Sort Done**  \e[0m"
sleep 15s


# This is the finish line!! #
echo " ██████╗  ██████╗ ███╗   ██╗███████╗ "
echo " ██╔══██╗██╔═══██╗████╗  ██║██╔════╝ "
echo " ██║  ██║██║   ██║██╔██╗ ██║█████╗ "
echo " ██║  ██║██║   ██║██║╚██╗██║██╔══╝ "
echo " ██████╔╝╚██████╔╝██║ ╚████║███████╗ "
echo " ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝ "
sleep 10s

exit 1

## END LINE ##

