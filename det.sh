#!/bin/bash

n=$(($#-$4))
i=0; j=1
declare -a c
for s in $@; do
	if [ $j -gt $n ]; then
		c[i]=$s
		((i++))
	fi
	((j++))
done

echo -e " \e[31m\e[1mrunning $0\e[0m "
echo ""
echo " - - - Starting detector simulation - - - "
echo ""

cd $G4WORKDIR/bin/$G4SYSTEM

f="g4run_multi.mac"

for i in $(seq 0 $3); do
	echo -e "\e[1;32mProcessing channel ${c[$((4*$i))]}\033[0m" | sed -r 's/_/ --> /g' | sed -r s/"etap"/"eta\'"/g
	echo ""
	for j in $(seq ${c[$((4*$i+1))]}); do
		echo "Processing Geant simulation, channel ${c[$((4*$i))]} ($(($i+1))/$(($3+1))), file `printf "%02d" $(($j+${c[$((4*$i+3))]}))` ($j/${c[$((4*$i+1))]})">/data/simulation/background/channels/currentFile
		echo "Performing run $j"
		echo ""
		rm -f $f
		cp /data/simulation/background/channels/g4run/g4run_${c[$((4*$i))]}.mac $f
		echo "/A2/event/setOutputFile /data/simulation/background/channels/g4_sim_${c[$((4*$i))]}""_`printf "%02d" $(($j+${c[$((4*$i+3))]}))`.root">>$f
		echo "/A2/generator/InputFile /data/simulation/background/channels/sim_${c[$((4*$i))]}""_`printf "%02d" $(($j+${c[$((4*$i+3))]}))`""_mkin.root">>$f
#not needed when A2 is executed with the macro as an argument
#		echo "/run/beamOn ${c[$((4*$i+2))]}">>$f
#		echo "/control/shell killall A2">>$f
#		./A2
		./A2 macros/vis.mac
	done
done

echo ""
echo -e "\e[31m\e[1mFinished the detector simulation\e[0m"
echo ""
