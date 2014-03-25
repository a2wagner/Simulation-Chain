Simulation Chain
================

These are the scripts which I use to simulate events. Further programs used are the Pluto event generator and the Geant4 simulation code from the A2. 

The scripts will run interactive, the only thing is to start everything via `./run.sh`.


Prerequisites
-------------

In order to run the detector simulation with Gean4, the file `vis.mac` has to be placed in the macros folder in the Geant4 working directory with a properly set `$G4WORKDIR` environment variable. 

Converting the files generated with Pluto to use them within Geant4, the pluto2mkin converter, written by Dominik Werthmüller, is needed. With the current scripts the compiled binary must be placed as `p2mkin` in the top directory where run.sh etc. are stored. 

