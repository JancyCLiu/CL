#!/bin/bash
# for CPU Testing Bash
# write date : 2023/03/27
# written by : Cindy Liu
# for more easily way to test and run the result
echo Below is your testing date
date

#Check on the CPU Model & Brand
echo Check on the CPU info firstly.
echo and Please copy this info to the report:
sleep 5s
lscpu | grep -i "Model name:" CPUinfo

#Check up the CPU Brand(include Intel/AMD)
CPUinfo=$(lscpu | grep -i "Model name:")

if [[ $CPUinfo == *"Intel"* ]]; then
    echo "Your CPU Brand is Intel, please add in Linpack Tool to complete this test."
elif [[ $CPUinfo == *"AMD"* ]]; then
    echo "Your CPU Brand is AMD, there's no need other tools to test."
else
    echo "Cannot reconize your CPU Brand."
fi


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
echo -e "\e[31;47mThe Storage info :\e[0m"
lsblk -o MODEL
lsblk -o SIZE | grep -i G
sleep 5s
echo -e "\e[31;47mThe OS info :\e[0m"
uname -v
sleep 5s
echo "------------------------------------"
sleep 5s

# STRAT #
echo start test now
read -p "How many CPU that you have set up on the board?" CPUno
echo -e "You already set up the : ${CPUno}" CPU
#Check on the BIOS Release Date:
read -p "Are you ready to check the BIOS Release Date? [Y/N]" yn
case $yn in
    [Yy]* ) echo "the BIOS Release Date is: $(dmidecode -s bios-release-date)";;
    [Nn]* ) echo "Oh, now exit this test"; exit;;
    * ) echo "Please answer Y or N.";;
  esac
##BIOS Release Date Log File save :
echo Please await for two seconds, the Log File is saving.
sleep 2s
dmidecode -s bios-release-date>>01-BIOS-Date.txt

#Check on the BMC Release info:
echo Please use the BMC Firmware to check the Release Date
read -p "Are you ready to check the BMC Firmware Name? [Y/N]" yn
case $yn in
    [Yy]* ) echo "the BMC Firmware Name is: $(ipmitool raw 0x3a 0x33 | xxd -r -p ;echo)";;
    [Nn]* ) echo "Oh, now exit this test"; exit;;
    * ) echo "Please answer Y or N.";;
  esac
echo Please await for two seconds, the Log File is saving.
sleep 2s
##BMC Firmware log File save :
(ipmitool raw 0x3a 0x33 | xxd -r -p ;echo) >>02-BMC-FW.txt
sleep 5s

#Check on the Memory running max size
read -p "Are you ready to check on the Memory Size[Y/N]?" yn
case $yn in
    [Yy]* ) echo "Below is your Memory Size : $(dmidecode -t memory | grep "Size")";;
    [Nn]* ) echo "Oh, now exit this test"; exit;;
    * ) echo "Please answer Y or N.";;
  esac
echo Please await for two seconds, the Log File is saving.
sleep 2s
##The Memory running max size Log File save :
dmidecode -t memory | grep "Size">>03-Memory-Size.txt
sleep 5s

#Check on the Memory running max speed
read -p "Are you ready to check on the Memory Speed?[Y/N]?" yn
case $yn in
    [Yy]* ) echo "Are you ready to check on you Memory Speed[Y/N]? $(dmidecode -t memory | grep "Speed")";;
    [Nn]* ) echo "Oh, now exit this test"; exit;;
    * ) echo "Please answer Y or N.";;
  esac
echo Please await for two seconds, the Log File is saving.
sleep 2s
##The Memory running max speed Log File save :
dmidecode -t memory | grep "Speed">>04-Memory-Speed.txt
sleep 5s

#Check on the Memory Type
read -p "Are you ready to check on the Memory Type[Y/N]?" yn
case $yn in
    [Yy]* ) echo "This info is Memory Type : $(dmidecode -t memory | grep "Type")";;
    [Nn]* ) echo "Oh, now exit this test"; exit;;
    * ) echo "Please answer Y or N.";;
  esac
sleep 3s
echo The Memory running max detail info:
sleep 5s
dmidecode -t memory
sleep 5s

#CPU Cores check
read -p "Are you ready to check the CPU Cores[Y/N]?" yn
echo The CPU info check as below:
case $yn in
    [Yy]* ) echo "This is the CPU Cores info : $(lscpu | grep "socket")";;
    [Nn]* ) echo "Oh, now exit this test"; exit;;
    * ) echo "Please answer Y or N.";;
  esac
echo This test item need to check on the offical website with : CPU Specifications - Total Cores:
#The CPU Cores Log File save:
echo Please await for two seconds, the Log File is saving.
sleep 2s
lscpu | grep "socket">>05-CPU-Cores.txt
sleep 5s

#CPU Threads check
read -p "Are you ready to check the CPU Threads[Y/N]?" yn
echo The CPU info check as below:
case $yn in
    [Yy]* ) echo "Are you ready to check the CPU Threads[Y/N]? $(lscpu | grep "Thread")";;
    [Nn]* ) echo "Oh, now exit this test"; exit;;
    * ) echo "Please answer Y or N.";;
  esac
echo This test item need to check on the offical website with : CPU Specifications - Total Threads:
#The CPU Threads Log File save:
sleep 2s
echo Please await for two seconds, the Log File is saving.
lscpu | grep "Thread">>06-CPU-Threads.txt
sleep 5s

#CPU Max Boost Clock check
echo The CPU info check as below:
case $yn in
    [Yy]* ) echo "Are you ready to check the CPU Max MHz[Y/N]? $(lscpu | grep "max")";;
    [Nn]* ) echo "Oh, now exit this test"; exit;;
    * ) echo "Please answer Y or N.";;
  esac
echo This test item need to check on the offical website with : CPU Specifications - Max Turbo Frequency:
#The CPU Max Boost Clock Log File save:
echo Please await for two seconds, the Log File is saving.
sleep 2s
lscpu | grep "max">>07-CPU-Max-Boots-Clock.txt
sleep 5s

#Get Ready For Brun Your CPU#
echo Get ready for burn your CPU
read -p "Are you ready for get the CPU temperture high? [Y/N]" yn
case $yn in
    [Yy]* ) echo "Now please get ready for your CPU Brun Test after 5 seconds $(sleep 5s)";;
    [Nn]* ) echo "This test will exit"; exit;;
    * ) echo "Please only the answer Y or N.";;
  esac
#CPU BRUN WAY#
#sudo apt-get install stress#
#Check the tool that you have or not

echo Now please get ready for your CPU Brun Test after 5 seconds.
sleep 5s
read -p " How much higher CPU that you want to brun?(1-10) " MU
read -p " How many times that you want to set on?(for seconds) " MA
echo Your CPU will get higher temperature by 5 seconds later.....
sleep 5s
while true;
do stress --cpu ${MU} --timeout ${MA};
sleep 120s;
echo --CPU Status--;
done

#Check on the CPU temperature
echo When doing the CPU stress test, we need to check on the temperature in the same time!
echo Below are the CPU Temperature cycle check:
sleep 5s
echo The CPU cycle check will start after you input the answer.
case $yn in
    [Yy]* ) echo "Are you ready to start to check[Y/N]? $(while true; do ipmitool sdr | grep -i CPU; echo --------; sleep 5; done)";;
    [Nn]* ) echo "Oh, now exit this test"; exit;;
    * ) echo "Please answer Y or N.";;
  esac
# This is the finish line!! #
echo -e "\e[5m\e[20;45m------Test Finish------\e[0m"
