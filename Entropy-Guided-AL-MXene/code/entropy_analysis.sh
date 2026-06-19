#!/bin/bash -l
source $deepmd_root/script/a64fx_fj/env.sh
export PLE_MPI_STD_EMPTYFILE=off
# Do this in iteractive mode!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# YOU NEED TO CHANGE!!!!!!!!!!!!!!!!!!!!!!
iter=7
p_iter=$[ $iter -1 ]
#******************************************************

#supercell size
nlat_x=3;nlat_y=3;nlat_z=3
dp=($(seq 0 1 7));num_dp=${#dp[@]}
strain=(e1 e2 e3 e4 e5 e6);num_strain=${#strain[@]}
n_strain=(-0.20 0.30);num_n_strain=${#n_strain[@]}
s_strain=(0.10 0.20);num_s_strain=${#s_strain[@]}
dim=3;num=$[ $num_n_strain -1 ]

mass_C=12.011   # C
mass_Ti=47.867   # Ti

#*********************************************************
Ti3C2_tol=6

for ele in TiC; do
    cd $ele
    cd 2_grid_data

    ###elastic constants
    rm -r 2_Hselect/iter_${iter}; mkdir 2_Hselect/iter_${iter}
    cd 1_mdrelax
    cd iter_${iter}

    for  struc in Ti3C2; do
        echo ${struc}; echo "H, Path" > ../../2_Hselect/iter_${iter}/${ele}_${struc}_H.csv
        cd ${struc}
        cd ${nlat_x}x${nlat_z}x${nlat_z}

        for i in `seq 1 $num_n_strain`;do
            cd ${i}_e1

            for j in `seq 1 $num_n_strain`;do
                cd ${j}_e2

                for k in `seq 1 $num_n_strain`;do
                    cd ${k}_e3

                    for l in `seq 1 $num_s_strain`;do
                        cd ${l}_e4

                        for m in `seq 1 $num_s_strain`;do
                            cd ${m}_e5
                            
                            for n in `seq 1 $num_s_strain`;do 
                                cd ${n}_e6
                                rm empty Hi.csv  Hsum.txt std.csv var.csv
                                tol_name=${struc}_tol
                                tol=${!tol_name}
#make python calculate standard deviation
cat > calc_std.py << EOF
import numpy as np
import pandas as pd
import os
from pathlib import Path

elastic_arr=[]
for i in np.arange(8):
    i_dir=str(i)
    os.chdir(i_dir)
    path = os.getcwd()
    print(path)

    my_file=Path("./result")
    if my_file.is_file():
        elastic_c=pd.read_csv("result", delim_whitespace = True, header=None)
        elastic_arr.append(elastic_c.iloc[:,4])
        os.chdir("../")
    else:
        print("result is empty.\n")
        os.chdir("../")
        cmd="echo empty >> empty"
        os.system(cmd)
        #break

num_lines=0
my_emptyfile=Path("./empty")
if my_emptyfile.is_file():
    with open("empty", "rb") as f:
        num_lines = sum(1 for _ in f)

if num_lines > $tol:
    print("empty files exist\n")
else:
    elastic_std=np.std(elastic_arr,axis=0)
    np.savetxt("std.csv", elastic_std, delimiter=",")
    elastic_var=np.var(elastic_arr,axis=0)
    np.savetxt("var.csv", elastic_var, delimiter=",")
    Hi=0.5*(1+np.log(2*np.pi*elastic_var))
    np.savetxt("Hi.csv", Hi, delimiter=",")
    H=np.sum(Hi)
    cmd="echo "+str(H)+" > Hsum.txt"
    os.system(cmd)

EOF

                                python calc_std.py
                                
                                if [ -f ./Hsum.txt ]; then
                                    Hsum=`cat Hsum.txt`
                                    echo -n $Hsum, >>  ../../../../../../../../../../2_Hselect/iter_${iter}/${ele}_${struc}_H.csv
                                    dir=`pwd`
                                    echo $dir >>  ../../../../../../../../../../2_Hselect/iter_${iter}/${ele}_${struc}_H.csv
                                fi
                                cd ../; pwd

                            done
                            cd ../; pwd

                        done
                        cd ../; pwd

                    done
                    cd ../; pwd

                done
                cd ../; pwd

            done
            cd ../; pwd

        done
        cd ../../; pwd

cat > ../../2_Hselect/iter_${iter}/${struc}_H_ranking.py << EOF
import pandas as pd
Hi=pd.read_csv('${ele}_${struc}_H.csv')
Hi_sort=Hi.sort_values(by=["H"], ascending=False, na_position='last')
Hi_sort.to_csv("${ele}_${struc}_H_ranking.csv", index=False)
EOF

    done
    cd ../../../../; pwd

done

echo "All finished."
