from dpdata import LabeledSystem, MultiSystems      #System
import os
import glob
from pathlib import Path

#追加部分始め
dir_path = os.path.join('/vol0200/data/hp230257/lijunliu/computation/2025_MXene_dp_potential/ISIF3_Ti3C2_bulk_ismear1_5frames/poscars_disps.3.3.3.-6')

# poscars_disps.3.3.3.-6内で 'disp-' で始まるサブディレクトリのみをカウント
disp_dirs = [
    name for name in os.listdir(dir_path)
    if name.startswith('disp-') and os.path.isdir(os.path.join(dir_path, name))
]

count = len(disp_dirs)

print("Ti3C2_bulk内の disp- ディレクトリ数: {count}")

#追加部分終わり. 成功を確認（06/09）

count = count + 1       #forループのrangeのために1を足す

for disp in range(1, count):        #1~dispファイル数までの繰り返しになってるはず
    print(str(disp).zfill(3))
    path_name="/vol0200/data/hp230257/lijunliu/computation/2025_MXene_dp_potential/ISIF3_Ti3C2_bulk_ismear1_5frames/poscars_disps.3.3.3.-6/disp-"+str(disp).zfill(3)+"/OUTCAR"      #str(disp).zfill(3)にすることで001~555表示
    #print(path_name)
    poscar_path=glob.glob(str(path_name), recursive=True)
    #print(poscar_path)

    for i in range(len(poscar_path)):
        ms=MultiSystems()
        print(poscar_path[i])
        folder=poscar_path[i].split('/')
        folder_name = "Ti3C2_bulk" + "_" + folder[8] + "_" + str(1000) + "K" + "_" + folder[9]       #str(1000)してなかったからエラー出た
        #多分 Ti3C2_bulk_poscars_disps.3.3.3.-6_1000K_disp-XXX っていうfolder_nameになるはず

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

