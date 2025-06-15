#!/bin/tcsh -f

source $MODULESHOME/init/csh

cd ../SHiELD_SRC/
echo `pwd`

git clone https://github.com/breichl/WW3.git
cd WW3
git checkout 33e4e13
