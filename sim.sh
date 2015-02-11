#!/bin/bash

#recover passed array
n=$(($#-$5)) #number of parameters - length of array = begin of array
i=0; j=1
#restore the initially declared array for the different channels
declare -a c
for s in "$@"; do #$(seq $4); do
	if [ $j -gt $n ]; then
		c[i]=$s
		((i++))
	fi
	((j++))
done

echo -e " \e[31m\e[1mrunning $0\e[0m "
echo ""
echo "Starting simulation for total $3 events . . . "
echo ""

f="sim.C"

for i in $(seq 0 $4); do
	echo -e "\e[1;32mProcessing channel ${c[$((4*$i))]}\033[0m" | sed -r 's/_/ --> /g' | sed -r s/"etap"/"eta\'"/g
	echo ""
	for j in $(seq ${c[$((4*$i+1))]}); do
		echo "Pluto simulation, channel ${c[$((4*$i))]} ($(($i+1))/$(($4+1))), file `printf "%02d" $(($j+${c[$((4*$i+3))]}))` ($j/${c[$((4*$i+1))]})">"$1/currentFile"
		echo "Generating file sim_${c[$((4*$i))]}""_`printf "%02d" $(($j+${c[$((4*$i+3))]}))`"
		echo ""
		echo "{ gROOT->ProcessLine(\".x simulate.C(${c[$((4*$i+2))]}, $(($j+${c[$((4*$i+3))]})), \\\"${c[$((4*$i))]}\\\", \\\"$1/sim_data\\\")\"); }">$f
		root -l $f
	done
done

echo ""
echo -e "\e[31m\e[1mFinished simulating the events\e[0m"
echo ""
