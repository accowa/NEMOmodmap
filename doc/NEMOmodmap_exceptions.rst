Special cases
==============

The example presented so far was a simple one that required no manual intervention to
complete the processing chain.  Unfortunately there are examples within the NEMO source
tree that fail at the first hurdle by not producing a valid submod.list file. There are
several reasons why this can occur and in each case a quick hand edit is usually
sufficient to resolve the issue. In no particular order of priority, the issues that can
occur are listed here. The reason why they occur and the simplest fix to each is provided
in the subsequent sections:

* Multiple CONTAINS statements and duplicate declarations
* No MODULE statement
* INTERFACE statements occurring before the CONTAINS statement
* Apparently empty modules

Multiple CONTAINS statements
----------------------------

This one occurs because of modules that still contain preprocessor keys which can remove large blocks of code. Often
in these circumstances alternative, 'dummy' routines are provided to satisfy the linker. Unfortunately this means two
CONTAINS statements and duplicate SUBROUTINE declarations. Take this example (albeit a rather obsolete one) from the 
`SBC` directory::

  sbcice_cice.F90
  MODULE sbcice_cice
  CONTAINS
     INTEGER FUNCTION sbc_ice_cice_alloc
     SUBROUTINE sbc_ice_cice
     SUBROUTINE cice_sbc_init
     SUBROUTINE cice_sbc_in
     SUBROUTINE cice_sbc_out
     SUBROUTINE cice_sbc_hadgam
     SUBROUTINE cice_sbc_final
     SUBROUTINE cice_sbc_force
     SUBROUTINE nemo2cice
     SUBROUTINE cice2nemo
  CONTAINS
     SUBROUTINE sbc_ice_cice      ! Dummy routine
     SUBROUTINE cice_sbc_init     ! Dummy routine
     SUBROUTINE cice_sbc_final     ! Dummy routine

In this example the solution is obviously just to delete the second CONTAINS statement and
duplicate subroutine names.  Of course this snippet is taken from a lengthy
`newsubmod.list` file so spotting this issue isn't necessarily straight-forward. To
assist, there is an additional script: `sanity_submod.sh` that does its best to discover
issues and pinpoint line numbers. More on that later though after all the potential issues
have been discussed.

No MODULE statement
-------------------

This one occurs primarily in `.h90` files that aren't whole files. Here is one example from 
the `SBC` directory::

  sbcwave.F90
  MODULE sbcwave
  CONTAINS
     SUBROUTINE sbc_stokes
     SUBROUTINE sbc_wstress
     SUBROUTINE sbc_wave
     SUBROUTINE sbc_wave_init
  
  tide.h90
  
  tideini.F90
  MODULE tideini
  CONTAINS
     SUBROUTINE tide_init

(note `tide.h90` hidden in the middle there). There are also a few examples in the `NST` directory of non-modular
programs with subroutines but no modules. E.g.::

  agrif2model.F90
  SUBROUTINE Agrif2Model
  SUBROUTINE Agrif_Set_numberofcells
  SUBROUTINE Agrif_Get_numberofcells
  SUBROUTINE Agrif_Allocationcalls
  SUBROUTINE Agrif_probdim_modtype_def
  SUBROUTINE Agrif_clustering_def
  SUBROUTINE Agrif2Model

the best solution here is to insert a `MODULE none` statement followed by a CONTAINS
statement before the first SUBROUTINE statement.

INTERFACE statements occurring before the CONTAINS statement
------------------------------------------------------------

This one doesn't indicate any non-conformity to the coding convention but is rather an indication that
generic subroutines are present and human interaction is required to decide how the module contents
are to be presented. Take this example from the `OCE` main directory::

  lib_fortran.F90
  MODULE lib_fortran
     INTERFACE glob_sum
     INTERFACE glob_sum_full
     INTERFACE local_sum
     INTERFACE sum3x3
     INTERFACE glob_min
     INTERFACE glob_max
     INTERFACE SIGN
  CONTAINS
     FUNCTION local_sum_2d
     FUNCTION local_sum_3d
     SUBROUTINE sum3x3_2d
     SUBROUTINE sum3x3_3d
     SUBROUTINE DDPDD
     SUBROUTINE glob_sum_1d
     SUBROUTINE glob_sum_2d
     SUBROUTINE glob_sum_full_2d
     SUBROUTINE glob_sum_3d
     SUBROUTINE glob_sum_full_3d
     FUNCTION SIGN_SCALAR
     FUNCTION SIGN_ARRAY_1D
     FUNCTION SIGN_ARRAY_2D
     FUNCTION SIGN_ARRAY_3D
     FUNCTION SIGN_ARRAY_1D_A
     FUNCTION SIGN_ARRAY_2D_A
     FUNCTION SIGN_ARRAY_3D_A
     FUNCTION SIGN_ARRAY_1D_B
     FUNCTION SIGN_ARRAY_2D_B
     FUNCTION SIGN_ARRAY_3D_B

showing all the component variations that make up the generic routines and functions is probably not required. 
If it is then just delete the INTERFACE statements, but a better solution is probably to delete the internal
variants and just present the generic names. This is achieved by moving the INTERFACE statements below the 
CONTAINS statements and deleting any surplus. I.e.::

  lib_fortran.F90
  MODULE lib_fortran
  CONTAINS
     INTERFACE glob_sum
     INTERFACE glob_sum_full
     INTERFACE local_sum
     INTERFACE sum3x3
     INTERFACE glob_min
     INTERFACE glob_max
     INTERFACE SIGN
     FUNCTION local_sum_2d
     FUNCTION local_sum_3d
     SUBROUTINE DDPDD
  
Apparently empty modules
------------------------

Some modules are intentionally empty of any contained routines. For example::

  par_kind.F90
  MODULE par_kind

in these cases simply insert a dummy routine [although it would be better to change the logic to handle these
correctly, ``TBD``]::

  par_kind.F90
  MODULE par_kind
  CONTAINS
     SUBROUTINE empty

Some others are apparently empty because they rely on the preprocessor to include content from h90 files. These
are primarily in the OBS directory and can be fixed by suitably combining the list entries for the relevant .F90
and .h90 files.

The sanity_submod.sh script
---------------------------

As mentioned earlier some of these issues can be difficult to spot in lengthy submod list files. To assist, the 
sanity_submod.sh script can be run immediately after generating the newsubmod.list file. It should catch most
issues and pinpoint the first occurrence in the file. A null return indicates no errors were detected. Here are
some examples of its output whilst iteratively fixing issues in `OCE`::

  mksubmodlist
  sanity_submod.sh
  ===================================
  |      Errors detected            |
  ===================================
  # files      = 12
  # modules    = 10
  # contains   = 7
  # interfaces = 7
  ===================================
  Some files do not contain a MODULE statement.     First suspect occurs near line: 28
  See full list of line numbers for filename(+1) and MODULE statements below:
  files  :    2   28   38   48   53   56   59   65   68   73   89   97
  Modules:    2   38   48   53   56   59   65   68   73   89
  ===================================
  Some files contain no or multiple CONTAINS statements.  Suspect not located. Probably at the end of submod list
  See full list of line numbers for MODULE and CONTAINS(-1) statements below:
  Modules :    2   38   48   53   56   59   65   68   73   89
  Contains:    9   38   48   59   68   73   89
  ===================================
  
  vi newsubmod.list   #remove files without MODULES
  sanity_submod.sh
  ===================================
  |      Errors detected            |
  ===================================
  # files      = 10
  # modules    = 10
  # contains   = 7
  # interfaces = 7
  ===================================
  Some files contain no or multiple CONTAINS statements.  Suspect not located. Probably at the end of submod list
  See full list of line numbers for MODULE and CONTAINS(-1) statements below:
  Modules :    2   28   38   43   46   49   55   58   63   79
  Contains:    9   28   38   49   58   63   79
  ===================================
  
  vi newsubmod.list   # Add CONTAINS and SUBROUTINE empty lines where necessary
  sanity_submod.sh
  Error detected: misplaced INTERFACE statement at line: 3
  
  vi newsubmod.list   # Sort out misplaced interface statements
  sanity_submod.sh
  
  # No return. Job done
  
  mv newsubmod.list OCE_submod.list
  
  
