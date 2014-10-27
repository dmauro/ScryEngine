#!/bin/bash
cd "$( cd "$( dirname "$0" )" && pwd )"
./compiler.sh
mocha
