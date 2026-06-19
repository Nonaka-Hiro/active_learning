#!/bin/bash -l
source $deepmd_root/script/a64fx_fj/env.sh
export PLE_MPI_STD_EMPTYFILE=off
# Do this in interact mode!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# YOU NEED TO CHANGE!!!!!!!!!!!!
iter=7
p_iter=$[ $iter -1 ]
#***************************************************

#supercell size
nlat_x=3;nlat_y=3;nlat_z=3
dp=($(seq 0 1 7));num_dp=${#dp[@]}
strain=(e1 e2 e3 e4 e5 e6);num_strain=${#strain[@]}
n1=$(echo "-0.20 - ${p_iter}*0.02" | bc -l )
n2=$(echo "0.30 - ${p_iter}*0.02" | bc -l )
s1=$(echo "0.10 + ${p_iter}*0.01" | bc -l )
s2=$(echo "0.20 + ${p_iter}*0.01" | bc -l )

n_strain=($n1 $n2);num_n_strain=${#n_strain[@]}
s_strain=($s1 $s2);num_s_strain=${#s_strain[@]}
dim=3;num=$[ $num_n_strain -1 ]

mass_C=12.011   # C
mass_Ti=47.867   # Ti
temp=1000

for ele in TiC; do
    cd $ele
    cd 2_grid_data

    ###elastic constants
    cd 2_Hselect
    cd iter_${iter}     # 2025_TiC_iter_data/TiC/2_grid_data/2_Hselect/iter_X

    for struc in Ti3C2; do
        python ${struc}_H_ranking.py #out Mg_hcp_H_ranking.csv
        nline=`cat ${ele}_${struc}_H_ranking.csv | wc -l`
        selected=$(echo "scale=2;$nline*0.5" | bc -l)
        int_sel=${selected%.*}
        head -${int_sel} ${ele}_${struc}_H_ranking.csv > selected_${ele}_${struc}.csv

cat > distribute_struc.py << EOF
import pandas as pd
import os
from pathlib import Path
import shutil

temp="${temp}K"

info_file="selected_${ele}_${struc}.csv" #make sure this file do exist
selected_info = pd.read_csv(info_file, header=0)
print(selected_info)

path=selected_info.iloc[:,1]
print('No. of paths: ',path.shape[0])

for isys in range(path.shape[0]):
    print(path[isys])
    folder=path[isys].split('/')        #例)/vol0002/mdt0/data/hp230257/nonaka/2025_TiC_iter_data/TiC/2_grid_data/1_mdrelax/iter_2/Ti3C2/3x3x3/2_e1/2_e2/2_e3/2_e4/2_e5/1_e6 folder[1]~[18]
    folder_name="abmd_"+folder[11]+"_"+folder[12]+"_"+temp+"_"+folder[13]+"_"+folder[14]+"_"+folder[15]+"_"+folder[16]+"_"+folder[17]+"_"+folder[18]
    os.mkdir(folder_name)
    os.chdir(folder_name)
    for i in range(8):
        my_file=Path(path[isys]+"/"+str(i)+"/result")
        if my_file.is_file():
            os.mkdir(str(i))
            os.chdir(str(i))
            src=path[isys]+"/"+str(i)+"/relaxed.lmp"
            shutil.copyfile(src, "relaxed.lmp")
            #cmd="atomsk relaxed.lmp -fractional POSCAR"
            #os.system(cmd)
            src="../../../../../2_grid_data/2_Hselect/iter_5/abmd_Ti3C2_3x3x3_1000K_1_e1_1_e2_2_e3_1_e4_2_e5_1_e6/4/pjsub_run_vasp_abmd.sh"
            shutil.copyfile(src, "pjsub_run_vasp_abmd.sh")
            src="../../../../../1_init_data/2_abmd/Ti3C2/3x3x3/1000K/scale/scale_1.00/POTCAR"
            shutil.copyfile(src, "POTCAR")
            src="../../../../../1_init_data/2_abmd/Ti3C2/3x3x3/1000K/scale/scale_1.00/INCAR"
            shutil.copyfile(src, "INCAR")
            os.chdir("../")
    os.chdir("../")
EOF

        python distribute_struc.py

    done
    cd ../../../../; pwd

done

echo "All finished."

