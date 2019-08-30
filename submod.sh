#!/bin/bash
#
input=$1
dir=`basename $input | sed -e's/_.*//'`
inner=`basename $input | sed -e's/\..*//'`"_inner.tex"
# write out the preamble:
echo "% Author: A. C. Coward"
echo "\documentclass{article}"
echo "\usepackage{tikz}"
echo "\usepackage{adjustbox}"
echo "\usetikzlibrary{trees}"
echo "\newsavebox{\mysavebox}"
echo "\newlength{\myrest}"
echo "\setlength{\textheight}{1.25\textheight}"
echo "\begin{document}"
echo "\tikzstyle{every node}=[draw=black,thick,anchor=west]"
echo "\tikzstyle{f90fil}=[rectangle, minimum height=0.65cm, minimum width=3.5cm, draw=black,fill=yellow!30]"
echo "\tikzstyle{f90mod}=[rectangle, minimum height=0.65cm, minimum width=3.5cm,draw=black,fill=red!30]"
echo "\tikzstyle{f90sub}=[minimum height=0.65cm, draw=black,fill=green!30]"
echo "\tikzstyle{f90fun}=[minimum height=0.65cm, draw=black,fill=blue!30]"
echo "\tikzstyle{f90gen}=[minimum height=0.65cm, draw=black,fill=orange!35]"
echo "\tikzstyle{gright}=[grow=right, level distance=2cm, edge from parent path={(\tikzparentnode.east) |- (\tikzchildnode.west)}]"
echo "\tikzstyle{gdown}=[ grow via three points={one child at (2.5,0.0) and"
echo "                    two children at (2.5,0.0) and (2.5,-0.8)},"
echo "                    edge from parent path={(\tikzparentnode.east) |- (\tikzchildnode.west)}]"
echo "\newpage" > $inner
echo "\begin{lrbox}{\mysavebox}%"                                                                     | tee -a  $inner
echo "\begin{tikzpicture}[%"                                                                          | tee -a $inner
echo "                    grow via three points={one child at (0.5,-0.8) and"                         | tee -a $inner
echo "                    two children at (0.5,-0.8) and (0.5,-1.6)},"                                | tee -a $inner
echo "                    edge from parent path={(\tikzparentnode.south) |- (\tikzchildnode.west)}]"  | tee -a $inner
echo "  \node {./"${dir}"}"                                                                           | tee -a $inner
skip=0
while IFS= read -r line
do
  if [ $skip == 0 ] || [[ -z "${line// }" ]] ; then         # skip any non-blank lines after a second CONTAINS
    if [[ $line == *"F90"* ]] || [[ $line == *"h90"* ]]; then
      f=`echo $line | sed -e 's/_/\\\_/g'`
      echo "child { node [f90fil] {"${f}"}"                                                          | tee -a $inner
    elif [[ $line == *"MODULE"* ]]; then
      f=`echo $line | sed -e 's/MODULE //' -e 's/_/\\\_/g'`
      echo "  child [gright] { node [f90mod] {"${f}"}"                                               | tee -a $inner
      m=0                                     # initialise a counter for CONTAINS statements
    elif [[ $line == *"CONTAINS"* ]]; then
      skip=0
      if [ $m -gt 0 ] ; then 
        skip=1                                # second or more CONTAINS in this block - skip to the next empty line
      else 
        c=-1                                  # new CONTAINS block - initialise the subprogram counter
      fi
      m=$(( $m + 1 ))                         # increment counter (only one is allowed per MODULE)
    elif [[ $line == *"SUBROUTINE"* ]]; then
      c=$(( $c + 1 ))
      f=`echo $line | sed -e 's/^.*SUBROUTINE //' -e 's/_/\\\_/g'`
      if [[ $c == 0 ]]; then                                   # if this is the first subprogram
         line0="child [gright] { node [f90sub] {"${f}"}}"      # starting line if this turns out to be a singleton
         line1="[gdown] child { node [f90sub] {"${f}"}}"       # starting line if there are multiple subprograms
      else                                                     # else there are multiple subprograms
        if [[ $c == 1 ]]; then echo "     "$line1                                                     | tee -a $inner  ; fi
        echo "            child { node [f90sub] {"${f}"}}"                                            | tee -a $inner
      fi
    elif [[ $line == *"FUNCTION"* ]]; then
      c=$(( $c + 1 ))
      f=`echo $line | sed -e 's/^.*FUNCTION //' -e 's/_/\\\_/g'`
      if [[ $c == 0 ]]; then                                   # if this is the first subprogram
         line0="child [gright] { node [f90fun] {"${f}"}}"      # starting line if this turns out to be a singleton
         line1="[gdown] child { node [f90fun] {"${f}"}}"       # starting line if there are multiple subprograms
      else                                                     # else there are multiple subprograms
        if [[ $c == 1 ]]; then echo "     "$line1                                                     | tee -a $inner   ; fi
        echo "            child { node [f90fun] {"${f}"}}"                                            | tee -a $inner
      fi
    elif [[ $line == *"INTERFACE"* ]]; then
      c=$(( $c + 1 ))
      f=`echo $line | sed -e 's/^.*INTERFACE //' -e 's/_/\\\_/g'`
      if [[ $c == 0 ]]; then                                   # if this is the first subprogram
         line0="child [gright] { node [f90gen] {"${f}"}}"      # starting line if this turns out to be a singleton
         line1="[gdown] child { node [f90gen] {"${f}"}}"       # starting line if there are multiple subprograms
      else                                                     # else there are multiple subprograms
        if [[ $c == 1 ]]; then echo "     "$line1                                                     | tee -a $inner ; fi
        echo "            child { node [f90gen] {"${f}"}}"                                            | tee -a $inner
      fi
    elif [[ -z "${line// }" ]] ; then
      if [[ $c == 0 ]]; then                                   # subprogram turned out to be a singleton
        echo "    "$line0                                                                             | tee -a $inner
      fi
      echo "        }"                                                                                | tee -a $inner
      echo "      }"                                                                                  | tee -a $inner
      if [[ $c -ge 1 ]]; then                                  # add appropriate number of spacers
       for i in `seq 1 1 $(( $c + 1 ))`
       do
        echo "    child [missing] {}"                                                                 | tee -a $inner
       done
      fi
      c=-1
      skip=0
    fi
  fi
done < $input
echo ";"                                                                                              | tee -a $inner
echo "\end{tikzpicture}"                                                                              | tee -a $inner
echo "\end{lrbox}%"                                                                                   | tee -a $inner
echo "%"                                                                                              | tee -a $inner
echo "\ifdim\ht\mysavebox>\textheight"                                                                | tee -a $inner
echo "    \setlength{\myrest}{\ht\mysavebox}%"                                                        | tee -a $inner
echo "    \loop\ifdim\myrest>\textheight"                                                             | tee -a $inner
echo "        \newpage\par\noindent"                                                                  | tee -a $inner
echo "        \clipbox{0 {\myrest-\textheight} 0 {\ht\mysavebox-\myrest}}{\usebox{\mysavebox}}%"      | tee -a $inner
echo "        \addtolength{\myrest}{-\textheight}%"                                                   | tee -a $inner
echo "    \repeat"                                                                                    | tee -a $inner
echo "    \newpage\par\noindent"                                                                      | tee -a $inner
echo "    \clipbox{0 0 0 {\ht\mysavebox-\myrest}}{\usebox{\mysavebox}}%"                              | tee -a $inner
echo "\else"                                                                                          | tee -a $inner
echo "    \usebox{\mysavebox}%"                                                                       | tee -a $inner
echo "\fi"                                                                                            | tee -a $inner
echo "\end{document}" 
  
