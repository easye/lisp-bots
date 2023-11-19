#!/bin/sh

export LIBRARY_PATH=$HOME/lfp/lib
export CPATH=$HOME/lfp/include
export LD_LIBRARY_PATH=$HOME/lfp/lib

while ! sbcl --dynamic-space-size 1024  \
    --lose-on-corruption \
    --disable-ldb \
    --no-sysinit \
    --userinit ~/ql-sbclrc \
    --disable-debugger \
    --load "start-bots.lisp"
    do
    sleep 5
done
