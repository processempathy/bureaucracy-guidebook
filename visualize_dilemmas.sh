#!/usr/bin/env bash


# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

rm -rf visualize_dilemmas.dot visualize_dilemmas.png
grep '^%GV' latex/dilemmas_and_trilemmas.tex  | sed 's/%GV //' > visualize_dilemmas.dot


docker run --rm -v `pwd`:/scratch -w /scratch/ --user `id -u`:`id -g` datasci dot -Tpng visualize_dilemmas.dot > visualize_dilemmas.png
