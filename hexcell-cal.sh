#!/bin/sh
# Developped by Dr. Abderrahmane Reggad
# Email: abde.reggad@gmail.com

seed=ZnO

rm -f $seed_lattice.out

echo -n "Enter optimized volume corresponding to optimized ratio (ang^3): " 
read vol 

echo -n "Enter optimized value of c/a: " 
read ratio

x=$(echo $vol*2 | bc)
y=$(echo $ratio*4.326 | bc)
z=$(echo $x/$y | bc)
alat=$(echo "scale=3; sqrt($z)" | bc -l)
clat=$(echo $alat*$ratio | bc)

cat >> ${seed}_lattice.out <<EOF
Lattice parameters

a = $alat ang    c = $clat ang

c/a = $ratio     Volume = $vol ang^3

EOF
