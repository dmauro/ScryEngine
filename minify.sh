#!/bin/bash
cd "$( cd "$( dirname "$0" )" && pwd )"
# Recompile the js
./compiler.sh
# And then minify
VERSION="0.0.0"
YEAR="2014"
java -jar compiler.jar --js bin/engine.js --js_output_file scryengine-$VERSION.min.js
printf "/*\n  Scry Engine version ${VERSION} (c) ${YEAR} David Mauro.\n  Licensed under the Apache License, Version 2.0\n  http://www.apache.org/licenses/LICENSE-2.0\n*/\n"|cat - scryengine-$VERSION.min.js > /tmp/out && mv /tmp/out scryengine-$VERSION.min.js
