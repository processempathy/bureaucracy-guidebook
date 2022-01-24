#!/usr/bin/env bash


# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

# https://stackoverflow.com/a/9449633/1164295
arr=( $(grep input latex/main.tex | sed 's/.*{//' | sed 's/}.*//') )

# https://stackoverflow.com/a/15394738/1164295
for eachfile in `/bin/ls latex/*.tex`; do filename=`echo $eachfile | sed 's/latex\///' | sed 's/\.tex//'`; if [[ " ${arr[*]} " =~ " ${filename} " ]]; then echo "found " $filename; else echo "DID NOT FIND " $filename; fi; done

