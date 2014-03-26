#!/bin/bash

####################
#
# This shell-script start the complete simulation process
# for a number of events defined during the runtime
#
# To execute this script, change to this directory and type
# ./run.sh
#
####################

s=""
#s=$s" etap_e+e-g_oldFF"  # simulate with the old FF
#s=$s" etap_e+e-g_FF1"  # simulate with FF = 1
s=$s" etap_e+e-g"
s=$s" etap_pi+pi-eta"
s=$s" etap_rho0g"
s=$s" etap_mu+mu-g"
s=$s" etap_gg"
s=$s" eta_e+e-g"
s=$s" eta_pi+pi-g"
s=$s" eta_pi+pi-pi0"
s=$s" eta_mu+mu-g"
s=$s" eta_gg"
s=$s" omega_e+e-pi0"
s=$s" omega_pi+pi-pi0"
s=$s" omega_pi+pi-"
s=$s" rho0_e+e-"
s=$s" rho0_pi+pi-"
s=$s" pi0_e+e-g"
s=$s" pi0_gg"
s=$s" pi+pi-pi0"
s=$s" pi+pi-"
s=$s" pi0pi0_4g"
s=$s" pi0eta_4g"
#s=$s" pi+pi0n" ???
# new added channels
s=$s" etap_pi0pi0eta"
s=$s" etap_pi0pi0pi0"
s=$s" etap_pi+pi-pi0"
s=$s" etap_omegag"
s=$s" omega_etag"

round(){
	#echo $(printf %.$2f $(echo "scale=$2;(10^$2*$1+0.5)/10^$2" | bc -l | sed -r s/"\."/","/g))
	echo "scale=$2;(10^$2*$1+0.5)/10^$2" | bc -l | sed 's/^\./0./'  #last sed adds leading zero in case of numbers smaller than 1 (bc returns e. g. .7 instead of 0.7 --> instead $h later will have no value after cutting at the decimal point for these values)
}

#declare -a c=(etap_e+e-g etap_pi+pi-eta etap_rho0g etap_mu+mu-g eta_e+e-g eta_pi+pi-g eta_pi+pi-pi0 eta_mu+mu-g omega_e+e-pi0 omega_pi+pi-pi0 rho0_e+e- rho0_pi+pi- pi0_e+e-g)

function format {  # format the different decay channel strings
	echo $1 | sed -r s/"_"/" --> "/g | sed -r s/"etap"/"eta\'"/g | sed -r s/"eta"/"η"/g | sed -r s/"η "/"η  "/g | sed s/"mu"/"µ"/g | sed -r s/"pi"/"π"/g | sed -r s/"omega"/"ω "/g | sed -r s/"rho"/"ρ"/g | sed -r s/"g"/"γ"/g | sed -r s/"0"/"⁰"/g
}

echo -e "\n \e[36m\e[1m- - - Initializing the simulation process - - -\e[0m \n"
echo "The following channels can be simulated:"
n=0
for i in $s; do
	format $i
	((n++))
done
echo "Total: $n possible channels"
echo ""

echo -n "Should be the same amount of events simulated for all channels? [y/n]: "
read a
while [[ $a != y && $a != n ]]; do
	echo -n "You've entered an invalid response! Please try again: "
	read a
done

if [ $a = y ]; then #simulate the same amount of events for all files
	echo "How much files per channel should be generated?"
	read nf
	echo "How much events should be stored in each file?"
	read ne
	echo ""
	n=0
	for i in $s; do
		c[4*n]=$i
		c[4*n+1]=$nf
		c[4*n+2]=$ne

		#determine biggest number used for the generated files to start from there [maybe possible via iteration over file list via for i in $(ls); do (or ls -1 instead of only ls)]
		mxsim=`ls -1 sim_data | grep -v mkin | grep $i"_" | sed 's/^.*_\(.*\)\..*$/\1/' | sort -nr | head -1`  # maximum number used for Pluto generated files
		#explanation: list generated files | without mkin in its name | for the actual channel | get string between last occurrence of an underscore and the following dot (should deliver only the numbering used for the different files), e. g. delivers number for bla_bla_number.extension | sort this list numerically and reversed | and assign the first value (highest number) to the variable [grep $s inserted later, even possible without for all channels]
		mxgnt=`ls -1 g4_sim | grep $i"_" | sed 's/^.*_\(.*\)\..*$/\1/' | sort -nr | head -1`  # maximum number used for Geant4 simulated files
		#remove leading zeros
		mxsim=${mxsim#0*} #alternative with sed -e 's/^0*//'
		mxgnt=${mxgnt#0*}
		if [ -z $mxsim ]; then mxsim=0; fi  # no Pluto files existing
		if [ -z $mxgnt ]; then mxgnt=0; fi  # no Geant4 files existing
		if [ $mxsim -gt $mxgnt ]  # are there more Pluto generated files than simulated ones with Geant?
		then
			echo -e " \e[31m\e[1m     Warning\e[0m\n "
			echo -e "Maybe there are some files for channel `format $i` \n  that still aren't simulated with Geant4..."
			read -p "Will continue the process by pressing [Enter] "
			echo ""
			c[4*n+3]=$mxsim
		elif [ $mxsim = $mxgnt ]; then
			c[4*n+3]=$mxgnt
		else
			echo -e " \e[31m\e[1m     Warning\e[0m\n "
			echo -e "There seems to be more Geant4 simulation files than\n  Pluto generated files for channel `format $i`..."
			read -p "Will continue the process by pressing [Enter] "
			echo ""
			c[4*n+3]=$mxgnt
		fi
		((n++))
	done

	#write this information into the array for the other scripts (used if overall highest file number is used instead of considering every channel for its own)
	#j=0
	#for i in $(seq 3 4 $((4*$n))); do #put information into every fourth array-entry
	#	c[i]=${ns[j]}
	#	((j++))
	#done
else #n (no) was chosen, the amount of simulated events will be chosen independently for every channel
	n=0; j=0
	for i in $s; do
		echo -e "How much files should be generated for channel \e[1m`format $i`\e[0m \n(type 0 or just hit Enter if this channel should not be simulated)"
		read nf
		if [ -z $nf ] || [ $nf = 0 ]; then  # skip channel if input is empty or 0
			echo "Will not consider this channel."
		elif [ $nf -gt 0 ]; then
			c[4*j]=$i
			echo "How much events should be stored in each file?"
			read ne
			c[4*j+1]=$nf
			c[4*j+2]=$ne

			#determine biggest number used for the generated files to start from there
			mxsim=`ls -1 sim_data | grep -v mkin | grep $i"_" | sed 's/^.*_\(.*\)\..*$/\1/' | sort -nr | head -1`  # maximum number used for Pluto generated files
			mxgnt=`ls -1 g4_sim | grep $i"_" | sed 's/^.*_\(.*\)\..*$/\1/' | sort -nr | head -1`  # maximum number used for Geant4 simulated files
			#remove leading zeros
			mxsim=${mxsim#0*}
			mxgnt=${mxgnt#0*}
			if [ -z $mxsim ]; then mxsim=0; fi  # no Pluto files existing
			if [ -z $mxgnt ]; then mxgnt=0; fi  # no Geant4 files existing
			if [ $mxsim -gt $mxgnt ]  # are there more Pluto generated files than simulated ones with Geant?
			then
				echo -e " \e[31m\e[1m     Warning\e[0m\n "
				echo -e "Maybe there are some files for channel `format $i` \n  that still aren't simulated with Geant4..."
				read -p "Will continue the process by pressing [Enter] "
				echo ""
				c[4*j+3]=$mxsim
			elif [ $mxsim = $mxgnt ]; then
				c[4*j+3]=$mxgnt
			else
				echo -e " \e[31m\e[1m     Warning\e[0m\n "
				echo -e "There seems to be more Geant4 simulation files than\n  Pluto generated files for channel `format $i`..."
				read -p "Will continue the process by pressing [Enter] "
				echo ""
				c[4*j+3]=$mxgnt
			fi
			((j++))
		else
			echo "Invalid input, will skip this channel!"
		fi
		echo ""
		((n++))
	done
fi

#echo -e "Array contains ${#c[*]} elements: ${c[@]} \n" #for debugging purposes

echo "$((${#c[*]}/4)) channels configured. The following simulation will take place:"
t=0; f=0
for i in $(seq 0 $((${#c[*]}/4-1))); do
	echo -ne "   Channel `format ${c[$((4*$i))]}` :\t"
	if [ `echo ${c[$((4*$i))]} | sed -r s/"_"/" --> "/g | wc -m` -lt 13 ]; then echo -ne "\t"; fi  # add an additional tab for short channels for better aligning
	echo "${c[$((4*$i+1))]} files per `echo ${c[$((4*$i+2))]} | sed -e 's/000000000$/G/' |sed -e 's/000000$/M/' | sed -e 's/000$/k/'` events (total `echo $((${c[$((4*$i+1))]}*${c[$((4*$i+2))]})) | sed -e 's/000000000$/G/' |sed -e 's/000000$/M/' | sed -e 's/000$/k/'` events)"
	t=$(($t + ${c[$((4*$i+1))]}*${c[$((4*$i+2))]}))
	f=$(($f + ${c[$((4*$i+1))]}))
done
echo -e " Total `echo $t | sed -e 's/000000000$/G/' |sed -e 's/000000$/M/' | sed -e 's/000$/k/'` events in $f files\n"

#Laufzeit: 5,6M Events (400k pro Kanal bei 14 Kanälen) dauern knapp 51,5 Stunden (2d, 3,5h) [--> ca. 9,2 Stunden pro 1M Events]
#58 million events done in around 22 days and 6 hours (1923784 s ~534.4 hours) --> ca. 9,213 hours per 1M events
d=$(round $t/1000000*9.21 1)  # round estimated time in hours to one decimal place
#h=$(echo $d | sed 's/.[^.]*$//')  # sed cuts all after last occuring dot (cuts all if no dot exists...)
h=$(echo $d | sed 's/\..*//')  # sed cuts all after first occuring dot, if existing
# Note: time estimation only valid for my computer which uses a 3.20GHz Intel Dual-Core and 4GB of RAM 
echo -n "Pretty rough time estimation (based on a 3.2GHz Intel Dual-Core and 4GB RAM): "
if [ $h -gt 24 ]; then
	echo "$d hours (about $(($h/24)) days and $(($h%24)) hours)"
elif [ $h = 0 ]; then
	echo "less than an hour"
else
	echo "$d hours"
fi
#echo "Pretty rhough time estimation: `echo "scale=2;(10^2*$t/5600000*51.5+0.5)/10^2" | bc -l` hours"
echo ""
read -p "Start the whole simulation process by hitting enter."

echo ""
echo -e " \e[36m\e[1m- - - Starting the simulation process - - -\e[0m "
echo ""
#echo "The following channels will be simulated:"
#for i in ${c[@]}; do
#	echo $i | sed -r s/"_"/" --> "/g | sed -r s/"etap"/"eta\'"/g | sed -r s/"eta"/"η"/g | sed -r s/"η "/"η  "/g | sed s/"mu"/"µ"/g | sed -r s/"pi"/"π"/g | sed -r s/"omega"/"ω "/g | sed -r s/"rho"/"ρ"/g | sed -r s/"g"/"γ"/g
#done
#echo "Total: ${#c[*]} channels"
#echo ""

#start=$(date +%s.%N) #%N for nano seconds, if time difference is less than one second; therefore the "bc" is used by calculating the elapsed time
start=$(date +%s)
begin=$(date +"%A, %e. %B %Y %k:%M:%S %Z")

#arguments: total number of files, total events, number of channels (start counting from 0), length of array, array content
./sim.sh $f $t $((${#c[*]}/4-1)) ${#c[*]} ${c[@]} #${c[*]}
./convert.sh $f $t $((${#c[*]}/4-1)) ${#c[*]} ${c[@]}
./det.sh $f $t $((${#c[*]}/4-1)) ${#c[*]} ${c[@]}

mv sim_*.root sim_data
mv g4_sim_*.root g4_sim
rm -f currentFile

#stop=$(date +%s.%N)
stop=$(date +%s)
end=$(date +"%A, %e. %B %Y %k:%M:%S %Z")
echo "Simulation for $((${#c[*]}/4)) channels done (total `echo $t | sed -e 's/000000000$/G/' |sed -e 's/000000$/M/' | sed -e 's/000$/k/'` events)."
echo "Start time: $begin"
echo "Stop time:  $end"
#echo "Elapsed:    $(echo "$stop - $start" | bc) s"
elapsed=$((stop-start))
printf "Elapsed:    %d s (%d days, %d hours and %d minutes)\n" $elapsed $(($elapsed/86400)) $(($elapsed%86400/3600)) $(($elapsed%3600/60))
#printf "Elapsed:    %.3F\n" $(echo "$res2 - $res1" | bc) #wrong decimal seperator

echo ""
echo -e " \e[34m\e[1m- - - F I N I S H E D - - -\e[0m "
echo ""
