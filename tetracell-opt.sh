#!/bin/sh
# Developped by Dr. Abderrahmane Reggad
# Email: abde.reggad@gmail.com

echo -n "Enter the seed name: " 
read seed 
echo "  "

cat > $seed.cell.tmpl <<EOF
%block lattice_abc
@A@ @A@ @C@
90.0 90.0 90.0
%endblock lattice_abc

%BLOCK positions_frac
 Ti  0.000  0.000  0.000
 Ti  0.500  0.500  0.500
 O   0.305  0.305  0.000
 O  -0.305 -0.305  0.000
 O   0.805  0.195  0.500
 O  -0.805 -0.195  0.500
 %ENDBLOCK positions_frac
 
 %block species_pot
   NCP19
%endblock species_pot

 symmetry_generate

 kpoint_mp_grid 8 8 6
EOF

for ratio in `seq -w 0.55 0.05 0.75`
do

#clean up before starting the work
rm -f ${seed}.castep

echo " running c/a= $ratio"

for alat in `seq -w 4.30 0.05 4.80`
do
  
  clat=$(echo "$ratio * $alat" | bc)
  sed -e "s/@A@/$alat/g" -e "s/@C@/$clat/g" $seed.cell.tmpl > $seed.cell
    
  echo " running a= $alat  "
  mpirun -np 2 castep.mpi ${seed}
  
done

#analyse the runs and extract the values we need into a single results file
grep 'cell volume' ${seed}.castep | awk '{print $5}' > V
grep 'Final energy' ${seed}.castep | awk '{print $5}' > E
paste V E > ${seed}_${ratio}.dat
rm V E
echo 'finished with results in '${seed}_${ratio}.dat
echo "  "
done
