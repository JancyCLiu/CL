#!/bin/bash
# the main bash for combining all test tools
# write date : 2023/10/27
# written by : Cindy Liu
# for combining the all bash

echo -e "\e[31m\e[1mWhich job would you like to do?\e[0m"
echo "1. Full BMC Test"
echo "2. Full BIOS Test"
echo "3. Only the configuration check"
echo "4. For CPU of AVL Test"
echo "5. For Memory of AVL Test"
echo "6. For Ethernet of AVL Test"
read -p "\e[5m\e[31m\e[1m  *Please select the options*  \e[0m" 123456

case $123456 in
    1)
        #Full Test of BMC
        echo -e "\e[4m\e[30;47m**You choose Job 1**\e[0m"
        chmod 777 * ; ./01BMC.sh
        ;;
    2)
        #Full Test of BIOS
        echo -e "\e[4m\e[30;47m**You choose Job 2**\e[0m"
        chmod 777 * ; ./01BIOS.sh
        ;;
    3)
        #Full Test of Configuration
        echo -e "\e[4m\e[30;47m**You choose Job 3**\e[0m"
        chmod 777 * ; ./03ConfigInfo.sh
        ;;
    4)
        #Full Test of CPU
        echo -e "\e[4m\e[30;47m**You choose Job 4**\e[0m"
        chmod 777 * ; ./01CPU.sh
        ;;
    5)
        #Full Test of MEM
        echo -e "\e[4m\e[30;47m**You choose Job 5**\e[0m"
        chmod 777 * ; ./01MEM.sh
    6)
        #Full Test of Eth
        echo -e "\e[4m\e[30;47m**You choose Job 6**\e[0m"
        chmod 777 * ; ./01Ethernet.sh
    *)
        echo "Invalid choice. Please enter a number from 1 to 6."
        ;;
esac




