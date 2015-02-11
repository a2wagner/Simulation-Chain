#!/bin/bash

n=$(($#-$6)) #begin of array
i=0; j=1
declare -a c
for s in "$@"; do
	if [ $j -gt $n ]; then
		c[i]=$s
		((i++))
	fi
	((j++))
done

echo -e " \e[31m\e[1mrunning $0\e[0m "
echo ""
echo "Conversion of the $3 Pluto-generated files"
echo ""

for i in $(seq 0 $5); do
	for j in $(seq ${c[$((4*$i+1))]}); do
		echo "Converting files for Geant, channel ${c[$((4*$i))]} ($(($i+1))/$(($5+1))), file `printf "%02d" $(($j+${c[$((4*$i+3))]}))` ($j/${c[$((4*$i+1))]})">currentFile
		"$2"/pluto2mkin --input "$1/sim_data/sim_${c[$((4*$i))]}"_`printf "%02d" $(($j+${c[$((4*$i+3))]}))`.root
		# The vertex position can be smeared according to the target length (z vertex) and the beam diameter (x and y verices)
		# The z smearing is uniform, x and y are gaussian shaped. The example below is for a 10cm target with 2cm beam diameter. Change values accordingly.
		#./p2mkin --input "$1/sim_${c[$((4*$i))]}"_`printf "%02d" $(($j+${c[$((4*$i+3))]}))`.root --target length=10 --beam diam=2
		mv sim_${c[$((4*$i))]}""_`printf "%02d" $(($j+${c[$((4*$i+3))]}))`_mkin.root "$1/sim_data/"
	done
done

echo ""
echo -e "\e[31m\e[1mFinished converting $3 files\e[0m"
echo ""
