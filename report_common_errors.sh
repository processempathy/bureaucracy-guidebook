#!/usr/bin/env bash

# Replace x with y.
# See list from https://www.plainlanguage.gov/guidelines/words/use-simple-words-phrases/
# and "On Writing Well", page

# strict error handling
#set -x
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
#set -o errexit   # set -e : exit the script if any statement returns a non-true return value

clear

echo "Citations should avoid line breaks"
grep -R -i " \\\\cite" latex/*.tex
read -p "Press any key to resume ..."
clear

echo "Are marginpar consistent?"
grep -R -i marginpar latex/*.tex | cut -d":" -f2 | sort | uniq
read -p "Press any key to resume ..."
clear

echo "Are marginpar followed by an index entry?"
read -p "Press any key to resume ..."
echo "#################################################################"
clear
grep -R -i marginpar latex/*.tex -A1
read -p "Press any key to resume ..."
clear

echo "'an' should proceed a word that starts with a vowel"
read -p "Press any key to resume ..."
echo "#################################################################"
grep -R -i " a a" latex/*.tex
grep -R -i " a e" latex/*.tex
grep -R -i " a i" latex/*.tex
grep -R -i " a o" latex/*.tex
grep -R -i " a u" latex/*.tex
grep -R -i " a y" latex/*.tex
read -p "Press any key to resume ..."
clear

echo "Periods should be followed by spaces"
grep -R -i "\.[a-z]" latex/*.tex | grep -v http | grep -v "e\.g" | grep -v "includegraph"
read -p "Press any key to resume ..."
clear

echo "I used to use 'i.e.' wrong; see https://theoatmeal.com/comics/ie for an explanation"
grep -R -i "i\.e\." latex/*.tex
read -p "Press any key to resume ..."
clear

echo "Latex doesn't like \""
grep -R -i \"[a-z] latex/*.tex
read -p "Press any key to resume ..."
clear

echo "I used ******* to denote separate sections of notes."
grep -R -i "\*\*\*\*\*" latex/*.tex
read -p "Press any key to resume ..."
clear

echo "I started lists with *"
grep -R -i "^\*" latex/*.tex
read -p "Press any key to resume ..."
clear

echo "Identify duplicate words"
grep -R -i -E "\b(\w+)\s+\1\b" latex/*.tex
read -p "Press any key to resume ..."
clear

echo "********* Simplify ***************"

echo "assistance --> help"
grep -R -i assistance latex/*.tex
read -p "Press any key to resume ..."
clear

echo "numerous --> many"
grep -R -i numerous latex/*.tex
read -p "Press any key to resume ..."
clear

echo "facilitate --> ease"
grep -R -i facilitate latex/*.tex
read -p "Press any key to resume ..."
clear

echo "individual --> man or woman"
grep -R -i individual latex/*.tex
read -p "Press any key to resume ..."
clear

echo "remainder --> rest"
grep -R -i remainder latex/*.tex
read -p "Press any key to resume ..."
clear

echo "initial --> first|early"
grep -R -i initial latex/*.tex
read -p "Press any key to resume ..."
clear

echo "implement --> do|enact|perform|fulfull|accomplish"
grep -R -i implement latex/*.tex
read -p "Press any key to resume ..."
clear

echo "sufficient --> enough"
grep -R -i sufficient latex/*.tex
read -p "Press any key to resume ..."
clear

echo "attempt --> try"
grep -R -i attempt latex/*.tex
read -p "Press any key to resume ..."
clear

echo "referred to as --> called"
grep -R -i "referred to as" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press any key to resume ..."
fi
clear

echo "with the possible exception of --> except"
grep -R -i "with the possible exception of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press any key to resume ..."
fi
clear

echo "due to the fact that --> because"
grep -R -i "due to the fact that" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press any key to resume ..."
fi
clear

echo "for the purpose of --> for"
grep -R -i "for the purpose of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press any key to resume ..."
fi
clear




