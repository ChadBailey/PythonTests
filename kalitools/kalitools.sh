#!/bin/bash
#https://tools.kali.org/

apt-get install aircrack-ng #wifi cracker - sniffer
./bully/debinst-bully.sh #bruteforce tool for wps keys
apt-get install wireshark tshark #tcp sniffer and cap file reader (generated by aircrack/airodump). tshark is a lite cli tool for wireshark
apt-get install john #john the ripper -hash brute force tool - /usr/sbin/john
apt install hydra #services login cracker
dpkg -i ipscan_3.5.2_amd64.deb #Angry IP Scanner 64bit -/usr/bin/ipscan
apt install libbluetooth-dev && cd ./Bluelog && make && make install && bluelog #bluelog logs all bt devices when run unattended - https://github.com/MS3FGX/Bluelog/blob/master/README


