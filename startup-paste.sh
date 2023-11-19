#!/bin/sh

while ! sbcl --dynamic-space-size 1024  \
    --lose-on-corruption \
    --disable-ldb \
    --no-sysinit \
    --userinit ~/ql-sbclrc \
    --disable-debugger \
    --load "start-paste.lisp"
    do
    sleep 5
done
