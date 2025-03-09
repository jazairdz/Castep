#!/bin/sh
# Developped by Dr. Abderrahmane Reggad
# Email: abde.reggad@gmail.com

seed=ZnO

cat > $seed.cell.tmpl <<EOF
%block lattice_abc
@A@ @A@ @C@
90.0 90.0 120.0
%endblock lattice_abc

%BLOCK positions_frac
O 0.333333333333333 0.666666666666667 0.381840368591548
O -0.333333333333333 -0.666666666666667 0.881840368591548
Zn 0.333333333333333 0.666666666666667 0.000759631408452
Zn -0.333333333333333 -0.666666666666667 0.500759631408452
%ENDBLOCK positions_frac

kpoint_mp_grid 3 3 2

symmetry_generate
EOF

for ratio in `seq -w 1.5 0.05 1.70`
do

#clean up before starting the work
rm -f ${seed}.castep

echo " running c/a= $ratio"

for alat in `seq -w 3.00 0.05 3.50`
do
  
  clat=$(echo "$ratio * $alat" | bc)
  sed -e "s/@A@/$alat/g" -e "s/@C@/$clat/g" $seed.cell.tmpl > $seed.cell
    
  echo " running $alat  "
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
