#!/bin/sh
# Matt Probert 01/12/2016
# modified by Reggad Abderrahmane

seed=Cr 
var='afm fm'
for magst in $var; do

alat=2.88  
echo 'Generating energy-volume data for '${seed}-${magst}


#clean up before starting the work
rm -f ${seed}-${magst}_EV.castep
rm -f ${seed}-${magst}_EV.dat

#set up the range of lattice parameters to test
for a in `seq -w 2.78 0.03 3.08` ; do
    echo '   doing a= '$a
    #replace every occurrence of the 'reference value' by 'a'
    sed -e 's/'$alat'/'$a'/g' ${seed}-${magst}.cell > ${seed}-${magst}_EV.cell
    
    cp ${seed}-${magst}.param ${seed}-${magst}_EV.param
    #do the work
    
    mpirun -np 2 castep.mpi ${seed}-${magst}_EV


#analyse the runs and extract the values we need into a single results file
grep 'cell volume' ${seed}-${magst}_EV.castep | awk '{print $5}' > V
grep 'Final energy' ${seed}-${magst}_EV.castep | awk '{print $5}' > E
paste V E > ${seed}-${magst}_EV.dat
rm V E
done

echo 'finished with results in '${seed}-${magst}_EV.dat

num_atoms=`grep "Total number of ions" ${seed}-${magst}_EV.castep | head -1 | awk '{print $8}'`
echo 'NB each run contains '${num_atoms}' atoms'
echo '       '
done
