#!/bin/bash
nmods=$(grep -i -c -e MODULE newsubmod.list)
ncons=$(grep -i -c -e CONTAINS newsubmod.list)
nfils=$(grep -c -i -e '[Fh]90' newsubmod.list)
nints=$(grep -i -c -e INTERFACE newsubmod.list)
#
lmods=($( grep -n -T MODULE   newsubmod.list | awk '{print $1}'))
lcons=($( grep -n -T CONTAINS newsubmod.list | awk '{print $1-1}'))
lfils=($( grep -n -T '[Fh]90' newsubmod.list | awk '{print $1+1}'))
lints=($( grep -n -T INTERFACE newsubmod.list | awk '{print $1}'))
#
ierr=0
if (( $nmods < $nfils ))   ; then ierr=$(($ierr+1 )) ; fi
if (( $ncons > $nfils ))   ; then ierr=$(($ierr+1 )) ; fi
if [ $ncons -ne $nmods ]   ; then ierr=$(($ierr+1 )) ; fi
if [ $ierr == 0 ] ; then 
   if [ $nints > 0 ] ; then
      # check no INTERFACE statements appear between MODULE and CONTAINS
      m=$(( ${#lints[@]} - 1 ))
      p=$(( ${#lmods[@]} - 1 ))
      for i in `seq 0 1 $m`
       do
        f=${lints[$i]}
        for n in `seq 0 1 $p`
        do
         if [ $f -gt ${lmods[$n]} ] &&  [ $f -le ${lcons[$n]} ] ; then
          echo "Error detected: misplaced INTERFACE statement at line: "$f
          exit
         fi
        done
       done
   fi
   exit 
fi
#
# Other errors detected produce a report:
#
echo "==================================="
echo "|      Errors detected            |"
echo "==================================="
ierr=0
echo "# files      = "$nfils
echo "# modules    = "$nmods
echo "# contains   = "$ncons
echo "# interfaces = "$nints
echo "==================================="
if (( $nmods < $nfils )) ; then 
   found=0
   echo -n "Some files do not contain a MODULE statement.    "
   ierr=$(($ierr+1 ))
   m=$((${#lfils[@]}<${#lmods[@]}?${#lfils[@]}:${#lmods[@]}))
   for n in `seq 0 1 $(( $m - 1 ))`
   do
      if [ ${lmods[$n]} -gt ${lfils[$n]} ] ; then
         found=1
         printf "\e[38;7;196m%s %s \e[0m\n" " First suspect occurs near line:" ${lfils[$n]}
         break
      fi
   done
   if (( $found == 0 )) ; then
     printf "\e[38;7;196m%s %s \e[0m\n" " Suspect not located. Probably at the end of submod list"
   fi
   echo "See full list of line numbers for filename(+1) and MODULE statements below: "
   echo -n "files  : "
   for w in ${lfils[@]}; do printf "%4d " $w; done
   echo
   echo -n "Modules: "
   for w in ${lmods[@]}; do printf "%4d " $w; done
fi
#
if (( $ierr > 0 )) ; then echo ; echo "===================================" ; fi
#
ierr=0
if [ $ncons -ne $nfils ] ; then 
   found=0
   echo -n "Some files contain no or multiple CONTAINS statements. "
   ierr=$(($ierr+1 ))
   m=$((${#lcons[@]}<${#lmods[@]}?${#lcons[@]}:${#lmods[@]}))
   for n in `seq 1 1 $(( $m - 1 ))`
   do 
      if [ ${lmods[$n]} -gt ${lcons[$n]} ] ; then
         found=1
         printf "\e[38;7;196m%s %s \e[0m\n" " First suspect occurs near line:" ${lcons[$n]}
         break
      fi
   done
   if (( $found == 0 )) ; then
     printf "\e[38;7;196m%s %s \e[0m\n" " Suspect not located. Probably at the end of submod list"
   fi
   echo "See full list of line numbers for MODULE and CONTAINS(-1) statements below: "
   echo -n "Modules : "
   for w in ${lmods[@]}; do printf "%4d " $w; done
   echo
   echo -n "Contains: "
   for w in ${lcons[@]}; do printf "%4d " $w; done
fi
if (( $ierr > 0 )) ; then echo ; echo "===================================" ; fi
