#!/bin/bash
cd "$( cd "$( dirname "$0" )" && pwd )"
# We need to recompile before testing
./compiler.sh
mocha debug
