#!/bin/sh
# Developped by Dr. Abderrahmane Reggad
# Email: abde.reggad@gmail.com

seed=ZnO

rm -f fit_Burch.py


for ratio in `seq -w 1.5 0.05 1.70`
do
rm -f results.out

cat >> fit_Burch.py <<EOF

#!/usr/bin/python3
# Matt Probert 21/02/2017

# simple script to load a text file of Vol (A^3) vs E (eV)
# and do a Burch-Murnaghan EOS fit

from scipy.optimize import leastsq
import numpy as np
import matplotlib.pyplot as plt
import sys

#get EV filename and load data - file must be 2 columns containing volume and energy

vols, energies = np.loadtxt('${seed}_${ratio}.dat',unpack=True)

#initial values [E0, B0, B', V0] from starting point as a basic guess
param0 = [ energies[0], 200, 2.0, vols[0]]

def Murnaghan(params, vol):    #EOS from Phys. Rev. B 28, 5480 (1983)
    E0, B0, BP, V0 = params    #unpack params
    E = E0 + B0 * vol / BP * (((V0 / vol)**BP) / (BP - 1) + 1) - V0 * B0 / (BP - 1.0)
    return E

def residuals(pars, y, x):
    res =  y - Murnaghan(pars, x)
    return res

#do the non-linear fit
params,success = leastsq(residuals, param0, args=(energies, vols))
if (not success):
    print('Failed to fit Burch-Murnaghan curve')
    exit()

#standard CASTEP units has V in ang^3 and E in eV
#and B=V*d2E/dV^2 so convert to SI B->B*1.602E-19/10E-30 = B*1.602E11 Pa = B*1.602E2 GPa
print(" Results for c/a= $ratio")
print("Burch-Murnaghan fit parameters:")
print("E0 = %10.4f eV"%(params[0]))
print("B0 = %10.4f eV.ang^-3"%(params[1]))
print("B' = %10.4f "%(params[2]))
print("V0 = %10.4f ang^3"%(params[3]))
print("")
print("Bulk modulus = %10.4f GPa"%(params[1]*1.602E2))
print("")
print("Graph of data and fit saved as BMM_curve.png - please check all is OK")
print("   ")

col = (np.random.random(), np.random.random(), np.random.random())

#plot the raw data and fitted curve on top to file as a cross-check
plt.plot(vols,energies, 'r.')

plt.xlim(40, 52)
plt.ylim(-4451.7, -4451.5)

x = np.linspace(min(vols), max(vols), 50)
y = Murnaghan(params, x)
plt.plot(x, y, c=col, label='c/a=$ratio')

plt.xlabel('Volume')
plt.ylabel('Energy')
plt.title('Energy VS Volume ')
plt.legend(loc='best')
plt.savefig('BMM_curve.png')

EOF

# run python script
python3 fit_Burch.py >> results.out
done



