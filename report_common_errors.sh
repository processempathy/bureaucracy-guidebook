#!/usr/bin/env bash

# Look for known issues in the latex.
# This script assists in copyediting.
# No changes to the Latex files are made.

# Replace x with y.
# See list from https://www.plainlanguage.gov/guidelines/words/use-simple-words-phrases/
# and "On Writing Well", page

# Websites that produce simplified text:
# * https://www.simplish.org/
# * https://rewordify.com/index.php

# "even users with graduate degrees completed tasks faster
#  when language was simplified. They also didn't have a
#  negative reaction to the simplified content."
# source: https://asistdl.onlinelibrary.wiley.com/doi/full/10.1002/meet.1450420179

# TODO: detect medical falicies; see
# https://www.frontiersin.org/articles/10.3389/fpsyg.2015.01100/full

# strict error handling
#set -x
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
#set -o errexit   # set -e : exit the script if any statement returns a non-true return value

clear

# grep
# -R              = recursive
# -i              = case insensitive
# -n              = show line number
# --color='auto'  = hightlight the match

echo "find incorrect use of href"
grep -R -i -n --color='auto' href latex/*.tex | grep -i -v http
if [[ $? -eq 0 ]]; then
    echo "THERE SHOULD BE ZERO INSTANCES!"
    read -p "Press ENTER key to resume ..."
fi
clear

echo "find incorrect use of hyperref"
grep -R -i -n --color='auto' hyperref latex/*.tex | grep -i http
if [[ $? -eq 0 ]]; then
    echo "THERE SHOULD BE ZERO INSTANCES!"
    read -p "Press ENTER key to resume ..."
fi
clear

echo "find duplicate words"
# https://stackoverflow.com/a/41611621/1164295
egrep -R -i -n --color='auto' "(\b[a-zA-Z]+)\s+\1\b" latex/*.tex
if [[ $? -eq 0 ]]; then
    echo "THERE SHOULD BE ZERO INSTANCES!"
    read -p "Press ENTER key to resume ..."
fi
clear

echo "Citations should avoid line breaks"
grep -R -i -n --color='auto' " \\\\cite" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "your own -> your"
grep -R -i -n --color='auto' "your own" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "Are marginpar consistent?"
grep -R -i --color='auto' marginpar latex/*.tex | cut -d":" -f2- | sort | uniq -c
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "Are marginpar followed by an index entry?"
echo "output shown next."
read -p "Press ENTER key to resume ..."
echo "#################################################################"
clear
grep -R -i -n --color='auto' "\\marginpar{\[tag\] story" -A2 latex/*.tex
read -p "Press ENTER key to resume ..."
grep -R -i -n --color='auto' "\\marginpar{\[tag\] folk" -A1 latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "'an' should proceed a word that starts with a vowel"
read -p "Press ENTER key to resume ..."
echo "#################################################################"
grep -R -i -n --color='auto' " a a" latex/*.tex
grep -R -i -n --color='auto' " a e" latex/*.tex
grep -R -i -n --color='auto' " a i" latex/*.tex
grep -R -i -n --color='auto' " a o" latex/*.tex
grep -R -i -n --color='auto' " a u" latex/*.tex
grep -R -i -n --color='auto' " a y" latex/*.tex
read -p "Press ENTER key to resume ..."
clear

echo "your office --> you"
grep -R -i -n --color='auto' "your office" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "/ (slash) --> and|or"
grep -R -i -n --color='auto' "/" latex/*.tex | grep --invert-match http | grep --invert-match includegraphics
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "Periods should be followed by spaces"
grep -R -i -n --color='auto' "\.[A-Za-z]" latex/*.tex | grep -v http | grep -v "i\.e" | grep -v "e\.g" | grep -v "includegraph"
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "question marks should be followed by spaces"
grep -R -i -n --color='auto' "?[A-Za-z]" latex/*.tex | grep -v http
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "I used to use 'i.e.' wrong; see https://theoatmeal.com/comics/ie for an explanation"
grep -R -i -n --color='auto' "i\.e\." latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "Latex doesn't like \""
grep -R -i -n --color='auto' \"[a-z] latex/*.tex | grep --invert-match :%
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "I used ******* to denote separate sections of notes."
grep -R -i -n --color='auto' "\*\*\*\*\*" latex/*.tex  | grep --invert-match :%
read -p "Press ENTER key to resume ..."
clear

echo "I started lists with *"
grep -R -i -n --color='auto' "^\*" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "Identify duplicate words"
grep -R -i -n --color='auto' -E "\b(\w+)\s+\1\b" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "********* Simplify: Remove phrases that don't mean anything ***************"


echo "remove 'a bit'"
grep -R -i -n --color='auto' "a bit" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "remove 'sort of'"
grep -R -i -n --color='auto' "sort of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "remove 'in a sense'"
grep -R -i -n --color='auto' "in a sense" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "remove 'rather'"
grep -R -i -n --color='auto' "rather" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "be advised --> (omit)"
grep -R -i -n --color='auto' "be advised" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "********** Simplify: Replace X with Y ***********"

echo "assistance --> help"
grep -R -i -n --color='auto' assistance latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "numerous --> many"
grep -R -i -n --color='auto' numerous latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "individual --> man or woman"
grep -R -i -n --color='auto' individual latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "remainder --> rest"
grep -R -i -n --color='auto' remainder latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "initial --> first|early"
grep -R -i -n --color='auto' initial latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "implement --> carry out|start|do|enact|perform|fulfull|accomplish"
grep -R -i -n --color='auto' implement latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "sufficient --> enough"
grep -R -i -n --color='auto' sufficient latex/*.tex | grep --invert-match insufficient
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "referred to as --> called"
grep -R -i -n --color='auto' "referred to as" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "with the possible exception of --> except"
grep -R -i -n --color='auto' "with the possible exception of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "due to the fact that --> because"
grep -R -i -n --color='auto' "due to the fact that" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "for the purpose of --> for"
grep -R -i -n --color='auto' "for the purpose of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

#**************************************
# the following list is from
# https://www.plainlanguage.gov/guidelines/words/use-simple-words-phrases/
#**************************************

echo "a and/or b --> a or b or both	"
grep -R -i -n --color='auto' " and/or " latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "accompany --> go with"
grep -R -i -n --color='auto' "accompany" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "accomplish --> carry out|do"
grep -R -i -n --color='auto' "accomplish" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "accorded --> given"
grep -R -i -n --color='auto' "accorded" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "eliminate 'very'"
# https://prowritingaid.com/grammar/1000047/Why-shouldn-t-you-use-the-word-very-in-your-writing
grep -R -i -n --color='auto' " very " latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "accordingly --> so"
grep -R -i -n --color='auto' "accordingly" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "accrue --> add|gain"
grep -R -i -n --color='auto' "accrue" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "accurate --> correct|exact|right"
grep -R -i -n --color='auto' "accurate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "additional --> added|more|other"
grep -R -i -n --color='auto' "additional" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "address --> discuss"
grep -R -i -n --color='auto' "address" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "addressees --> you"
grep -R -i -n --color='auto' "addressees" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "addressees are requested --> (omit)|please"
grep -R -i -n --color='auto' "addressees are requested" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "adjacent to --> next to"
grep -R -i -n --color='auto' "adjacent to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "advantageous --> helpful"
grep -R -i -n --color='auto' "advantageous" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "adversely impact on --> hurt|set back"
grep -R -i -n --color='auto' "adverse* impact on" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "advise --> recommend|tell"
grep -R -i -n --color='auto' "advise" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "afford an opportunity --> allow|let"
grep -R -i -n --color='auto' "afford an opportunity" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "aircraft --> plane"
grep -R -i -n --color='auto' "aircraft" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "allocate --> divide"
grep -R -i -n --color='auto' "allocate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "anticipate --> expect"
grep -R -i -n --color='auto' "anticipate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "a number of --> some"
grep -R -i -n --color='auto' "a number of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "apparent --> clear|plain"
grep -R -i -n --color='auto' "apparent" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "appreciable --> many"
grep -R -i -n --color='auto' "appreciable" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "appropriate --> (omit)|proper|right"
grep -R -i -n --color='auto' "appropriate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "approximate --> about"
grep -R -i -n --color='auto' "approximate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "arrive onboard --> arrive"
grep -R -i -n --color='auto' "arrive onboard" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "as a means of --> to"
grep -R -i -n --color='auto' "as a means of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "ascertain --> find out|learn"
grep -R -i -n --color='auto' "ascertain" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "as prescribed by --> in|under"
grep -R -i -n --color='auto' "as prescribed by" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "assist, assistance --> aid|help"
grep -R -i -n --color='auto' "assist" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "attain --> meet"
grep -R -i -n --color='auto' "attain" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "attempt --> try"
grep -R -i -n --color='auto' "attempt" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "at the present time --> at present|now"
grep -R -i -n --color='auto' "at the present time" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "benefit --> help"
grep -R -i -n --color='auto' "benefit" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "by means of --> by|with"
grep -R -i -n --color='auto' "by means of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "capability --> ability"
grep -R -i -n --color='auto' "capability" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "caveat --> warning"
grep -R -i -n --color='auto' "caveat" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "close proximity --> near"
grep -R -i -n --color='auto' "close proximity" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "combat environment --> combat"
grep -R -i -n --color='auto' "combat environment" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "combined --> joint"
grep -R -i -n --color='auto' "combined" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "commence --> begin|start"
grep -R -i -n --color='auto' "commence" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "comply with --> follow"
grep -R -i -n --color='auto' "comply with" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "component --> part"
grep -R -i -n --color='auto' "component" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "comprise --> form|include|make up"
grep -R -i -n --color='auto' "comprise" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "concerning --> about|on"
grep -R -i -n --color='auto' "concerning" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "consequently --> so"
grep -R -i -n --color='auto' "consequently" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "consolidate --> combine|join|merge"
grep -R -i -n --color='auto' "consolidate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "constitutes --> is|forms|makes up"
grep -R -i -n --color='auto' "constitutes" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "contains --> has"
grep -R -i -n --color='auto' "contains" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "convene --> meet"
grep -R -i -n --color='auto' "convene" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "currently --> (omit)|now"
grep -R -i -n --color='auto' "currently" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "deem --> believe|consider|think"
grep -R -i -n --color='auto' "deem" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "elect --> choose|pick"
grep -R -i -n --color='auto' " elect" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "eliminate --> cut|drop|end"
grep -R -i -n --color='auto' "eliminate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "employ --> use"
grep -R -i -n --color='auto' "employ" latex/*.tex | grep --invert-match employee
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "encounter --> meet"
grep -R -i -n --color='auto' "encounter" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "endeavor --> try"
grep -R -i -n --color='auto' "endeavor" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "ensure --> make sure"
grep -R -i -n --color='auto' "ensure" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "enumerate --> count"
grep -R -i -n --color='auto' "enumerate" latex/*.tex | grep --invert-match begin | grep --invert-match end
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "equipments --> equipment"
grep -R -i -n --color='auto' "equipments" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "equitable --> fair"
grep -R -i -n --color='auto' "equitable" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "establish --> set up|prove|show"
grep -R -i -n --color='auto' "establish" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "evidenced --> showed"
grep -R -i -n --color='auto' "evidenced" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "evident --> clear"
grep -R -i -n --color='auto' "evident" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "exhibit --> show"
grep -R -i -n --color='auto' "exhibit" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "expedite --> hasten|speed up"
grep -R -i -n --color='auto' "expedite" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "expeditious --> fast|quick"
grep -R -i -n --color='auto' "expeditious" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "expend --> spend"
grep -R -i -n --color='auto' "expend" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "expertise --> ability"
grep -R -i -n --color='auto' "expertise" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "expiration --> end"
grep -R -i -n --color='auto' "expiration" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "facilitate --> ease|help"
grep -R -i -n --color='auto' "facilitate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "failed to --> didn’t"
grep -R -i -n --color='auto' "failed to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "feasible --> can be done|workable"
grep -R -i -n --color='auto' "feasible" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "females --> women"
grep -R -i -n --color='auto' "females" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "finalize --> complete|finish"
grep -R -i -n --color='auto' "finalize" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "for a period of --> for"
grep -R -i -n --color='auto' "for a period of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "for example,______etc --> for example|such as"
grep -R -i -n --color='auto' "for example,.*etc" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "forfeit --> give up|lose"
grep -R -i -n --color='auto' "forfeit" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "forward --> send"
grep -R -i -n --color='auto' "forward" latex/*.tex | grep --invert-match straightforward
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "frequently --> often"
grep -R -i -n --color='auto' "frequently" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "function --> act|role|work"
grep -R -i -n --color='auto' "function" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "furnish --> give|send"
grep -R -i -n --color='auto' "furnish" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "has a requirement for --> needs"
grep -R -i -n --color='auto' "has a requirement for" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "herein --> here"
grep -R -i -n --color='auto' "herein" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "heretofore --> until now"
grep -R -i -n --color='auto' "heretofore" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "herewith --> below|here"
grep -R -i -n --color='auto' "herewith" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "however --> but"
grep -R -i -n --color='auto' "however" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "identical --> same"
grep -R -i -n --color='auto' "identical" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "identify --> find|name|show"
grep -R -i -n --color='auto' "identify" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "immediately --> at once"
grep -R -i -n --color='auto' "immediately" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "impacted --> affected|changed"
grep -R -i -n --color='auto' "impacted" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in accordance with --> by|following|per|under"
grep -R -i -n --color='auto' "in accordance with" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in addition --> also|besides|too"
grep -R -i -n --color='auto' "in addition" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in an effort to --> to"
grep -R -i -n --color='auto' "in an effort to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "inasmuch as --> since"
grep -R -i -n --color='auto' "inasmuch as" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in a timely manner --> on time|promptly"
grep -R -i -n --color='auto' "in a timely manner" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "inception --> start"
grep -R -i -n --color='auto' "inception" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "incumbent upon --> must"
grep -R -i -n --color='auto' "incumbent upon" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "indicate --> show|write down"
grep -R -i -n --color='auto' "indicate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "indication --> sign"
grep -R -i -n --color='auto' "indication" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "initiate --> start"
grep -R -i -n --color='auto' "initiate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in lieu of --> instead"
grep -R -i -n --color='auto' "in lieu of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in order that --> for|so"
grep -R -i -n --color='auto' "in order that" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in order to --> to"
grep -R -i -n --color='auto' "in order to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in regard to --> about|concerning|on"
grep -R -i -n --color='auto' "in regard to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in relation to --> about|with|to"
grep -R -i -n --color='auto' "in relation to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


# I'm not familiar with this, but it means "among other things"
echo "inter alia --> (omit)"
grep -R -i -n --color='auto' "inter alia" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "interface --> meet|work with"
grep -R -i -n --color='auto' "interface" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "interpose no objection --> don’t object"
grep -R -i -n --color='auto' "interpose no objection" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in the amount of --> for"
grep -R -i -n --color='auto' "in the amount of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in the event of --> if"
grep -R -i -n --color='auto' "in the event of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in the near future --> shortly|soon"
grep -R -i -n --color='auto' "in the near future" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in the process of --> (omit)"
grep -R -i -n --color='auto' "in the process of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in view of --> since"
grep -R -i -n --color='auto' "in view of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in view of the above --> so"
grep -R -i -n --color='auto' "in view of the above" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "is applicable to --> applies to"
grep -R -i -n --color='auto' "is applicable to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "is authorized to --> may"
grep -R -i -n --color='auto' "is authorized to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "is in consonance with --> agrees with|follows"
grep -R -i -n --color='auto' "is in consonance with" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "is responsible for --> (omit)|handles"
grep -R -i -n --color='auto' "is responsible for" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "it appears --> seems"
grep -R -i -n --color='auto' "it appears" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "it is --> (omit)"
grep -R -i -n --color='auto' "it is" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "it is essential --> must|need to"
grep -R -i -n --color='auto' "it is essential" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "it is requested --> please|we request|I request"
grep -R -i -n --color='auto' "it is requested" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "liaison --> discussion"
grep -R -i -n --color='auto' "liaison" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "limited number --> limits"
grep -R -i -n --color='auto' "limited number" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "magnitude --> size"
grep -R -i -n --color='auto' "magnitude" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "maintain --> keep|support"
grep -R -i -n --color='auto' "maintain" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "maximum --> greatest|largest|most"
grep -R -i -n --color='auto' "maximum" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "methodology --> method"
grep -R -i -n --color='auto' "methodology" latex/*.tex | grep --invert-match :%
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "minimize --> decrease|method"
grep -R -i -n --color='auto' "minimize" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "minimum --> least|smallest"
grep -R -i -n --color='auto' "minimum" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "modify --> change"
grep -R -i -n --color='auto' "modify" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "monitor --> check|watch"
grep -R -i -n --color='auto' "monitor" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "necessitate --> cause|need"
grep -R -i -n --color='auto' "necessitate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "notify --> let know|tell"
grep -R -i -n --color='auto' "notify" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "not later than 10 May --> by 10 May|before 11 May"
grep -R -i -n --color='auto' "not later than " latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "not later than 1600 --> by 1600"
grep -R -i -n --color='auto' "not later than 1600" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "notwithstanding --> inspite of|still"
grep -R -i -n --color='auto' "notwithstanding" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "numerous --> many"
grep -R -i -n --color='auto' "numerous" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "objective --> aim|goal"
grep -R -i -n --color='auto' "objective" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "obligate --> bind|compel"
grep -R -i -n --color='auto' "obligate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "observe --> see"
grep -R -i -n --color='auto' "observe" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "on a regular basis --> (omit)"
grep -R -i -n --color='auto' "on a regular basis" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "operate --> run|use|work"
grep -R -i -n --color='auto' "operate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "optimum --> best|greatest|most"
grep -R -i -n --color='auto' "optimum" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "option --> choice|way"
grep -R -i -n --color='auto' "option" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "parameters --> limits"
grep -R -i -n --color='auto' "parameters" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "participate --> take part"
grep -R -i -n --color='auto' "participate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "perform --> do"
grep -R -i -n --color='auto' "perform" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "permit --> let"
grep -R -i -n --color='auto' "permit" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "pertaining to --> about|of|on"
grep -R -i -n --color='auto' "pertaining to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "portion --> part"
grep -R -i -n --color='auto' "portion" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "possess --> have|own"
grep -R -i -n --color='auto' "possess" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "practicable --> practical"
grep -R -i -n --color='auto' "practicable" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "preclude --> prevent"
grep -R -i -n --color='auto' "preclude" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "previous --> earlier"
grep -R -i -n --color='auto' "previous" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "previously --> before"
grep -R -i -n --color='auto' "previously" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "prioritize --> rank"
grep -R -i -n --color='auto' "prioritize" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "prior to --> before"
grep -R -i -n --color='auto' "prior to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "proceed --> do|go ahead|try"
grep -R -i -n --color='auto' "proceed" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "procure --> (omit)"
grep -R -i -n --color='auto' "procure" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "proficiency --> skill"
grep -R -i -n --color='auto' "proficiency" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "promulgate --> issue|publish"
grep -R -i -n --color='auto' "promulgate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "provide --> give|offer|say"
grep -R -i -n --color='auto' "provide" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "provided that --> if"
grep -R -i -n --color='auto' "provided that" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "provides guidance for --> guides"
grep -R -i -n --color='auto' "provides guidance for" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "purchase --> buy"
grep -R -i -n --color='auto' "purchase" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "pursuant to --> by|following|per|under"
grep -R -i -n --color='auto' "pursuant to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "reflect --> say|show"
grep -R -i -n --color='auto' "reflect" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "regarding --> about|of|on"
grep -R -i -n --color='auto' "regarding" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "relative to --> about|on"
grep -R -i -n --color='auto' "relative to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "relocate --> move"
grep -R -i -n --color='auto' "relocate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "remain --> stay"
grep -R -i -n --color='auto' "remain" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "remainder --> rest"
grep -R -i -n --color='auto' "remainder" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "remuneration --> pay|payment"
grep -R -i -n --color='auto' "remuneration" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "render --> give|make"
grep -R -i -n --color='auto' "render" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "represents --> is"
grep -R -i -n --color='auto' "represents" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "request --> ask"
grep -R -i -n --color='auto' "request" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "require --> must|need"
grep -R -i -n --color='auto' "require" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "requirement --> need"
grep -R -i -n --color='auto' "requirement" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "reside --> live"
grep -R -i -n --color='auto' "reside" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "retain --> keep"
grep -R -i -n --color='auto' "retain" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


# not clear what the intent with this one is
echo "said, some, such --> the|this|that"
grep -R -i -n --color='auto' "said, some, such" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "selection --> choice"
grep -R -i -n --color='auto' "selection" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "set forth in --> in"
grep -R -i -n --color='auto' "set forth in" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "similar to --> like"
grep -R -i -n --color='auto' "similar to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "solicit --> ask for|request"
grep -R -i -n --color='auto' "solicit" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "state-of-the-art --> latest"
grep -R -i -n --color='auto' "state-of-the-art" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "subject --> the|this|your"
grep -R -i -n --color='auto' "subject" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "submit --> give|send"
grep -R -i -n --color='auto' "submit" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "subsequent --> later|next"
grep -R -i -n --color='auto' "subsequent" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "subsequently --> after|later|then"
grep -R -i -n --color='auto' "subsequently" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "substantial --> large|much"
grep -R -i -n --color='auto' "substantial" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "successfully complete --> complete|pass"
grep -R -i -n --color='auto' "successfully complete" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "sufficient --> enough"
grep -R -i -n --color='auto' "sufficient" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "take action to --> (omit)"
grep -R -i -n --color='auto' "take action to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "terminate --> end|stop"
grep -R -i -n --color='auto' "terminate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "the month of --> (omit)"
grep -R -i -n --color='auto' "the month of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "there are --> (omit)"
grep -R -i -n --color='auto' "there are" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "therefore --> so"
grep -R -i -n --color='auto' "therefore" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "therein --> there"
grep -R -i -n --color='auto' "therein" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "there is --> (omit)"
grep -R -i -n --color='auto' "there is" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "thereof --> its|their"
grep -R -i -n --color='auto' "thereof" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "the undersigned --> I"
grep -R -i -n --color='auto' "the undersigned" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "the use of --> (omit)"
grep -R -i -n --color='auto' "the use of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

# not clear what the intent of this is
echo "this activity, command --> us|we"
grep -R -i -n --color='auto' "this activity, command" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "timely --> prompt"
grep -R -i -n --color='auto' "timely" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "time period --> (either one)"
grep -R -i -n --color='auto' "time period" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "transmit --> send"
grep -R -i -n --color='auto' "transmit" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "type --> (omit)"
grep -R -i -n --color='auto' "type" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "under the provisions of --> under"
grep -R -i -n --color='auto' "under the provisions of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "until such time as --> until"
grep -R -i -n --color='auto' "until such time as" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "utilize, utilization --> use"
grep -R -i -n --color='auto' "utilize, utilization" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "validate --> confirm"
grep -R -i -n --color='auto' " validate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "viable --> practical|workable"
grep -R -i -n --color='auto' " viable" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "vice --> instead of|versus"
grep -R -i -n --color='auto' " vice" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "warrant --> call for|permit"
grep -R -i -n --color='auto' "warrant" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "whereas --> because|since"
grep -R -i -n --color='auto' "whereas" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "with reference to --> about"
grep -R -i -n --color='auto' "with reference to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "with the exception of --> except for"
grep -R -i -n --color='auto' "with the exception of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "witnessed --> saw"
grep -R -i -n --color='auto' "witnessed" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

# EOF
