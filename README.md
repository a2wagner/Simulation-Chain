Simulation Chain
================

These are the scripts which I use to simulate events. Further programs used are the Pluto event generator and the Geant4 simulation code from the A2.

The scripts will run interactive, the only thing is to adapt the paths where the data should be stored as well as where the a2geant package is located and start everything via `./run.sh`.

New channels can be added very easy using the same nomenclature for the decays as found in the scripts. By simply commenting the lines belonging to certain channels at the beginning of the `run.sh` their terminal prompt will be skipped.


Prerequisites
-------------

The following programs have to be installed and set up properly:

- [ROOT framework](http://root.cern.ch/ "ROOT")
- [Pluto event generator](http://www-hades.gsi.de/?q=pluto "Pluto")
- For the detector simulation:
	- [Geant4](http://geant4.cern.ch/ "Geant4")
	- [A2 Geant4 package](https://github.com/A2-Collaboration/a2geant "A2 package")

In order to run the detector simulation with Geant4, the file `vis.mac` has to be placed in the macros folder where the A2 Geant4 package had been installed.

Converting the files generated with Pluto to use them within Geant4, the pluto2mkin converter, written by Dominik Werthmüller, is needed. It should be located in the A2 Geant directory as well. In case it is missing the sources to build it are in the pluto2mkin.tar.gz. Change the path to the executable in the script `convert.sh` accordingly.


###Path changes in the scripts

####Scripts changed at 11.2.2015 for easier portability:

Basically you have to change two paths right at the beginning of the `run.sh`. The variable `DATA_OUTPUT_PATH` specifies where the simulated data will be stored. If not existent, the folders `sim_data` and `g4_run` will be created. The variable `A2_GEANT_PATH` must hold the path to the a2geant directory where the A2 and pluto2mkin executables are located. That's all.

####In case you use the version prior to the 11.2.2015:

Some paths must be changed according to the current location of the scripts and the A2 package. For most of the scripts the current directory is used, except for the file `det.sh` and `vis.mac`.

1. In `det.sh` the line `cd $G4WORKDIR/bin/$G4SYSTEM` has to be changed to the directory in which the executable `A2` is placed as well as the macros folder. All paths `/data/simulation/background/channels/` must be replaced with the path to the current scripts location. 
2. Besides this shell script the `vis.mac` inside the macros folder of the A2 package must be replaced by the one from this repository. In `vis.mac` in the only not commented line `/control/execute /home/wagners/Desktop/g4work/bin/Linux-g++/g4run_multi.mac` the path `/home/.../Linux-g++` has to be replaced with the path used in the previous point, `$G4WORKDIR/bin/$G4SYSTEM`, without environment variables.

By default the Pluto generated data will be stored in the directory sim_data and the detector simulated data will be stored in g4_sim. The folder g4run contains the per channel information for the particles to be tracked within Geant4. The tracking information can easily be accessed by running the `pluto2mkin` converter which displays the needed information.


Trouble-Shooting
----------------

- If you are using Ubuntu (probably > 11.04) and recieve some 'undefined reference' errors, it is recommended to install the gold linker which replaces the standard ld linker to resolve this issue, `sudo apt-get install binutils-gold`.

