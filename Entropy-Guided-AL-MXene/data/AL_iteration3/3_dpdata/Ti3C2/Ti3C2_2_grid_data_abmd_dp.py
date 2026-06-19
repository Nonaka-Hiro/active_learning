from dpdata import System,LabeledSystem,MultiSystems
import os
import glob
from pathlib import Path
deforms=[0, 1, 2, 3, 4, 5, 6, 7]

for deform in deforms:  
    print(deform)
    path_name="/vol0200/data/hp230257/nonaka/2025_TiC_iter_data/TiC/2_grid_data/2_Hselect/iter_3/*Ti3C2*/"+str(deform)+"/OUTCAR"       #folder[1]~[12]
    print(path_name)
    poscar_path=glob.glob(str(path_name), recursive=True)
    print(poscar_path)
    for i in range(len(poscar_path)):
        ms=MultiSystems()
        print(poscar_path[i])
        folder=poscar_path[i].split('/')
        folder_name=folder[6]+"_"+folder[7]+"_"+folder[9]+"_"+folder[10]+"_"+folder[11]
        # 多分 TiC_2_grid_data_iter_2_abmd_Ti3C2_3x3x3_1000K_2_e1_2_e2_1_e3_1_e4_2_e5_2_e6_3 みたいになる
        my_file = Path(poscar_path[i])
        if my_file.is_file():
            cmd = "grep Ela " + poscar_path[i] +" > ElapsedTime.txt"
            os.system(cmd)
            if os.path.getsize("ElapsedTime.txt") > 0:
                labelsys=LabeledSystem(poscar_path[i],fmt='outcar')
                print(labelsys)
                ms.append(labelsys)
                ms.to_deepmd_raw(folder_name)
                ms.to_deepmd_npy(folder_name, set_size=2500)
                print(ms)

