#!/bin/bash
#
#Sanity checker for subprogram lists to be input into submod.sh
#
# Usage: ./sanity_submod.sh  (assumes newsubmod.list as input)
#      or ./sanity_submod.sh another_submod.list  (to operate on another_submod.list)
#      or ./sanity_submod.sh -w
#      or ./sanity_submod.sh another_submod.list -w to provide counts and warnings
#
if [ $# -gt 2 ] ; then 
  echo "Too many arguments"
  echo "Usage: ./sanity_submod.sh [another_submod.list] [-w]"
  exit
fi
#
iwarn=0
infile="newsubmod.list"
if [ $# -gt 0 ] ; then 
  for a in $*
   do
    if [ "$a" == "-w" ] ; then
      iwarn=1
    else
     infile=$a
    fi
   done
fi
#
if [ ! -f ${infile} ] ; then
 echo ${infile} " not found"
 exit
fi
#
nmods=$(grep -i -c -e MODULE    ${infile})
ncons=$(grep -i -c -e CONTAINS  ${infile})
nfils=$(grep -c -i -e '[Fh]90'  ${infile})
nints=$(grep -i -c -e INTERFACE ${infile})
#
# Use next 4 lines if grep supports the -T option:
# lmods=($( grep -n -T MODULE    ${infile} | awk '{print $1}'))
# lcons=($( grep -n -T CONTAINS  ${infile} | awk '{print $1-1}'))
# lfils=($( grep -n -T '[Fh]90'  ${infile} | awk '{print $1+1}'))
# lints=($( grep -n -T INTERFACE ${infile} | awk '{print $1}'))
# Otherwise use next 4 lines
lmods=($( grep -n MODULE    ${infile} | sed -e's/:/ : /' | awk '{print $1}'))
lcons=($( grep -n CONTAINS  ${infile} | sed -e's/:/ : /' | awk '{print $1-1}'))
lfils=($( grep -n '[Fh]90'  ${infile} | sed -e's/:/ : /' | awk '{print $1+1}'))
lints=($( grep -n INTERFACE ${infile} | sed -e's/:/ : /' | awk '{print $1}'))
#
ierr=0
if [[ $nmods -ne $nfils ]] ; then ierr=$(($ierr+1 )) ; fi
if [ $iwarn == 1 ] ; then
  if [ $ncons -ne $nfils ] ; then ierr=$(($ierr+1 )) ; fi
  if [ $ncons -ne $nmods ] ; then ierr=$(($ierr+1 )) ; fi
fi
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
echo "|          File stats             |"
echo "==================================="
ierr=0
echo "# files      = "$nfils
echo "# modules    = "$nmods
echo "# contains   = "$ncons
echo "# interfaces = "$nints
echo "==================================="
if (( $nmods < $nfils )) ; then 
   echo "==================================="
   echo "|      Errors detected            |"
   echo "==================================="
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
if [ $iwarn == 1 ] ; then
  found=0
  echo "==================================="
  echo "|          Warnings               |"
  echo "==================================="
  if [ $ncons -lt $nfils ] ; then 
   echo -n "Some files do not contain a CONTAINS statements. "
   ierr=$(($ierr+1 ))
  fi
  if [ $ncons -gt $nfils ] ; then 
   echo -n "Some files contain multiple CONTAINS statements. "
   ierr=$(($ierr+1 ))
  fi
  if (( $ierr > 0 )) ; then 
   m=$((${#lcons[@]}<${#lmods[@]}?${#lcons[@]}:${#lmods[@]}))
   for n in `seq 1 1 $(( $m - 1 ))`
    do 
       if [ ${lmods[$n]} -ne ${lcons[$n]} ] ; then
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
   echo ; echo "==================================="
 fi
fi
