#!/bin/bash
#
modmap_dir=/home/acc/NEMO/NEMOmodmap
#
# Start in src directory
#
# Create module/subroutine/function list for OCE top-directory
#
   cd OCE
   $modmap_dir/mksubmodlist
   mv newsubmod.list OCE_submod.list
#
# Repeat for all OCE subdirectories
#
   for f in ASM  DIA  FLO  LDF BDY  DIU  ICB C1D  DOM  IOM CRS  DYN  LBC OBS SBC TRA ZDF STO TRD USR
   do 
    cd $f
    $modmap_dir/mksubmodlist
    mv newsubmod.list ../${f}_submod.list
    cd ../
   done
#
# Similarly for TOP
#
   cd ../TOP
   $modmap_dir/mksubmodlist
   mv newsubmod.list TOP_submod.list
#
# and TOP subdirectories
#
   for f in AGE C14 CFC PISCES MY_TRC 
   do 
    cd $f
    $modmap_dir/mksubmodlist
    mv newsubmod.list ../${f}_submod.list
    cd ../
   done
#
# .. but PISCES has subdirectories of its own
#
   cd PISCES
   for f in SED P2Z P4Z
   do 
    cd $f
    $modmap_dir/mksubmodlist
    mv newsubmod.list ../${f}_submod.list
    cd ../
   done
#
# Rename these to reference their parent directory
#
   mv P2Z_submod.list ../PISCES_P2Z_submod.list
   mv P4Z_submod.list ../PISCES_P4Z_submod.list
   mv SED_submod.list ../PISCES_SED_submod.list
   cd ../
#
# Also list ICE routunes
#
   cd ../ICE
   $modmap_dir/mksubmodlist
   mv newsubmod.list ../ICE_submod.list
   cd ../
#
# and Finally the remaining bits
#
   for f in NST OFF  SAO  SAS
   do
    cd $f
    $modmap_dir/mksubmodlist
    mv newsubmod.list ../${f}_submod.list 
    cd ../
   done
#
# Which should provide this lot:
# cd ../
# find ./ -name '*submod*'
#
# ./src/TOP
# ./src/TOP/AGE_submod.list         ./src/TOP/C14_submod.list         ./src/TOP/CFC_submod.list
# ./src/TOP/MY_TRC_submod.list      ./src/TOP/PISCES_submod.list      ./src/TOP/TRP_submod.list
# ./src/TOP/PISCES_P2Z_submod.list  ./src/TOP/PISCES_P4Z_submod.list  ./src/TOP/PISCES_SED_submod.list
# 
# ./src/OCE
# ./src/OCE/ASM_submod.list         ./src/OCE/LDF_submod.list         ./src/OCE/DIU_submod.list
# ./src/OCE/ICB_submod.list         ./src/OCE/DOM_submod.list         ./src/OCE/IOM_submod.list
# ./src/OCE/CRS_submod.list         ./src/OCE/DYN_submod.list         ./src/OCE/TRD_submod.list
# ./src/OCE/OBS_submod.list         ./src/OCE/SBC_submod.list         ./src/OCE/TRA_submod.list
# ./src/OCE/ZDF_submod.list         ./src/OCE/OCE_submod.list         ./src/OCE/BDY_submod.list
# ./src/OCE/C1D_submod.list         ./src/OCE/DIA_submod.list         ./src/OCE/FLO_submod.list
# ./src/OCE/LBC_submod.list         ./src/OCE/STO_submod.list         ./src/OCE/USR_submod.list
# 
# ./src/ICE_submod.list
# 
# ./src/OFF_submod.list             ./src/SAO_submod.list
# ./src/SAS_submod.list             ./src/NST_submod.list
