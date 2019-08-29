Combining maps
--------------

In many cases it is more convenient to produce a single document for multiple sub-directories. To assist
in this, `submod.sh` generates two latex files. For example::

    ./submod.sh OFF_submod.list > OFF_submod.tex

will have produced: `OFF_submod.tex` and `OFF_submod_inner.tex`. The latter is the latex without the 
document pre- and post-amble. `*inner.tex` files can be concatenated together and inserted just before
the `\\end{document}` statement of any full latex file to create a multipage, multi-drectory listing.

This can be dressed further by including a title page with a colour key legend. Here is an example for
the OCE directory. Note this example uses an additional latex package: `pgfpages` to enable multiple
pages on each a4, landscape page::

  #!/bin/bash
  #
  # Need to rename OCE_submod_inner.tex because we want this first in the list
    mv OCE_submod_inner.tex OCE_submod_inside.tex
  #
  # First add the preamble and title page with colour key legend
  #
  cat << EOFA > alloce.tex
  % Author: A. C. Coward
  \documentclass{article}[a4paper]
  \usepackage{tikz}
  \usepackage{adjustbox}
  \usetikzlibrary{trees}
  \usepackage[margin=0.75in]{geometry}
  \usepackage{pgfpages}
  \pgfpagesuselayout{2 on 1}[a4paper,landscape]
  \newsavebox{\mysavebox}
  \newlength{\myrest}
  \setlength{\textheight}{1.0\textheight}
  \begin{document}
  \tikzstyle{every node}=[draw=black,thick,anchor=west]
  \tikzstyle{f90fil}=[rectangle, minimum height=0.65cm, minimum width=3.5cm, draw=black,fill=yellow!30]
  \tikzstyle{f90mod}=[rectangle, minimum height=0.65cm, minimum width=3.5cm,draw=black,fill=red!30]
  \tikzstyle{f90sub}=[minimum height=0.65cm, draw=black,fill=green!30]
  \tikzstyle{f90fun}=[minimum height=0.65cm, draw=black,fill=blue!30]
  \tikzstyle{f90gen}=[minimum height=0.65cm, draw=black,fill=orange!35]
  \tikzstyle{gright}=[grow=right, level distance=2cm, edge from parent path={(\tikzparentnode.east) |- (\tikzchildnode.west)}]
  \tikzstyle{gdown}=[ grow via three points={one child at (2.5,0.0) and
                      two children at (2.5,0.0) and (2.5,-0.8)},
                      edge from parent path={(\tikzparentnode.east) |- (\tikzchildnode.west)}]
  %%
  %% End of latex preamble
  %% Start title page
  %%
  \begin{center}
  {\LARGE\textbf NEMO v4.0 OCE file, module, subroutine and function map}
  \end{center}
  \bigskip
  %%
  %% Add directory layout (use colourless nodes)
  %%
  \begin{center}
  \begin{tikzpicture}[%
                      grow via three points={one child at (0.5,-0.65) and
                      two children at (0.5,-0.65) and (0.5,-1.3)},
                      edge from parent path={(\tikzparentnode.south) |- (\tikzchildnode.west)}]
    \node {./OCE}
     child{ node {ASM}}
     child{ node {BDY}}
     child{ node {C1D}}
     child{ node {CRS}}
     child{ node {DIA}}
     child{ node {DIU}}
     child{ node {DOM}}
     child{ node {DYN}}
     child{ node {FLO}}
     child{ node {ICB}}
     child{ node {IOM}}
     child{ node {LBC}}
     child{ node {LDF}}
     child{ node {OBS}}
     child{ node {OCE}}
     child{ node {SBC}}
     child{ node {STO}}
     child{ node {TRA}}
     child{ node {TRD}}
     child{ node {USR}}
     child{ node {ZDF}}
     ;
  \end{tikzpicture}
  \par\par\bigskip
  %%
  %% Add colour key legend
  %%
  \vskip 1cm
  \begin{tikzpicture}[%
                      grow via three points={one child at (-1.75,-0.8) and
                      two children at (-1.75,-0.8) and (-1.75,-1.6)},
                      edge from parent path={(\tikzparentnode.south)  (\tikzchildnode.west)}]
    \node [minimum height=0.65cm, minimum width=3.5cm] {Colour key}
    child{ node [f90fil] {File}}
    child{ node [f90mod] {Module}}
    child{ node [f90sub,minimum height=0.65cm, minimum width=3.5cm] {Subroutine}}
    child{ node [f90gen,minimum height=0.65cm, minimum width=3.5cm] {Generic subroutine}}
    child{ node [f90fun,minimum height=0.65cm, minimum width=3.5cm] {Function}}
    ;
  \end{tikzpicture}
  
  \end{center}
  %%
  %% End of title page
  %%
  EOFA
  #
  # Now add all the 'inner' latex files starting with the main directory
  # 
    cat OCE_submod_inside.tex *inner.tex >> alloce.tex
  #
  # Finally add the end document statement
  #
  cat << EOFB >> alloce.tex
  \end{document}
  EOFB

The first a4 side of the multipage document produced by the resulting latex file should appear as:

  .. autoimage:: alloce 
      :scale-html: 50


