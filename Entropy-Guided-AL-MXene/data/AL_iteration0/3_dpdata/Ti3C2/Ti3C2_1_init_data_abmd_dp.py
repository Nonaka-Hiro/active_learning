from dpdata import System,LabeledSystem,MultiSystems
import os
import glob
deforms=["scale", "e1", "e2", "e3", "e4", "e5", "e6"]

for deform in deforms:  
    print(deform)
    path_name="/vol0200/data/hp230257/nonaka/2025_TiC_init_data/TiC/1_init_data/2_abmd/Ti3C2/3x3x3/1000K/"+deform+"/**/OUTCAR"     #folder[1]~folder[14]
    print(path_name)
    poscar_path=glob.glob(str(path_name), recursive=True)
    print(poscar_path)
    for i in range(len(poscar_path)):
        ms=MultiSystems()
        print(poscar_path[i])
        folder=poscar_path[i].split('/')
        folder_name=folder[6]+"_"+"init_data_"+folder[9]+"_"+folder[10]+"_"+folder[11]+"_"+folder[12]+"_"+folder[13]
        # 多分 TiC_init_data_Ti3C2_3x3x3_1000K_scale_scale_0.90 みたいになる
        

        cmd = "grep Ela " + poscar_path[i] +" > ElapsedTime.txt"
        os.system(cmd)
        if os.path.getsize("ElapsedTime.txt") > 0:
            labelsys=LabeledSystem(poscar_path[i],fmt='outcar')
            print(labelsys)
            ms.append(labelsys)
            ms.to_deepmd_raw(folder_name)
            ms.to_deepmd_npy(folder_name, set_size=2500)
            print(ms)

