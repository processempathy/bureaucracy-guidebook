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

echo "find incorrect use of href"
grep -R -i href *.tex | grep -i -v http
if [[ $? -eq 0 ]]; then
    echo "THERE SHOULD BE ZERO INSTANCES!"
    read -p "Press ENTER key to resume ..."
fi
clear

echo "find incorrect use of hyperref"
grep -R -i hyperref *.tex | grep -i http
if [[ $? -eq 0 ]]; then
    echo "THERE SHOULD BE ZERO INSTANCES!"
    read -p "Press ENTER key to resume ..."
fi
clear

echo "find duplicate words"
# https://stackoverflow.com/a/41611621/1164295
egrep -R -i "(\b[a-zA-Z]+)\s+\1\b" *.tex
if [[ $? -eq 0 ]]; then
    echo "THERE SHOULD BE ZERO INSTANCES!"
    read -p "Press ENTER key to resume ..."
fi
clear

echo "Citations should avoid line breaks"
grep -R -i " \\\\cite" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "your own -> your"
grep -R -i "your own" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "Are marginpar consistent?"
grep -R -i marginpar latex/*.tex | cut -d":" -f2- | sort | uniq
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "Are marginpar followed by an index entry?"
echo "output shown next."
read -p "Press ENTER key to resume ..."
echo "#################################################################"
clear
grep -R -i "\\marginpar{\[tag\] story" -A2 latex/*.tex
read -p "Press ENTER key to resume ..."
grep -R -i "\\marginpar{\[tag\] folk" -A1 latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "'an' should proceed a word that starts with a vowel"
read -p "Press ENTER key to resume ..."
echo "#################################################################"
grep -R -i " a a" latex/*.tex
grep -R -i " a e" latex/*.tex
grep -R -i " a i" latex/*.tex
grep -R -i " a o" latex/*.tex
grep -R -i " a u" latex/*.tex
grep -R -i " a y" latex/*.tex
read -p "Press ENTER key to resume ..."
clear

echo "Periods should be followed by spaces"
grep -R -i "\.[A-Za-z]" latex/*.tex | grep -v http | grep -v "i\.e" | grep -v "e\.g" | grep -v "includegraph"
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "question marks should be followed by spaces"
grep -R -i "?[A-Za-z]" latex/*.tex | grep -v http
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "I used to use 'i.e.' wrong; see https://theoatmeal.com/comics/ie for an explanation"
grep -R -i "i\.e\." latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "Latex doesn't like \""
grep -R -i \"[a-z] latex/*.tex | grep --invert-match :%
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "I used ******* to denote separate sections of notes."
grep -R -i "\*\*\*\*\*" latex/*.tex  | grep --invert-match :%
read -p "Press ENTER key to resume ..."
clear

echo "I started lists with *"
grep -R -i "^\*" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "Identify duplicate words"
grep -R -i -E "\b(\w+)\s+\1\b" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "********* Simplify: Remove phrases that don't mean anything ***************"


echo "remove 'a bit'"
grep -R -i "a bit" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "remove 'sort of'"
grep -R -i "sort of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "remove 'in a sense'"
grep -R -i "in a sense" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "remove 'rather'"
grep -R -i "rather" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "be advised --> (omit)"
grep -R -i "be advised" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "********** Simplify: Replace X with Y ***********"

echo "assistance --> help"
grep -R -i assistance latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "numerous --> many"
grep -R -i numerous latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "individual --> man or woman"
grep -R -i individual latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "remainder --> rest"
grep -R -i remainder latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "initial --> first|early"
grep -R -i initial latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "implement --> carry out|start|do|enact|perform|fulfull|accomplish"
grep -R -i implement latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "sufficient --> enough"
grep -R -i sufficient latex/*.tex | grep --invert-match insufficient
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "referred to as --> called"
grep -R -i "referred to as" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "with the possible exception of --> except"
grep -R -i "with the possible exception of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "due to the fact that --> because"
grep -R -i "due to the fact that" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "for the purpose of --> for"
grep -R -i "for the purpose of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

#**************************************
# the following list is from
# https://www.plainlanguage.gov/guidelines/words/use-simple-words-phrases/
#**************************************

echo "a and/or b --> a or b or both	"
grep -R -i " and/or " latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "accompany --> go with"
grep -R -i "accompany" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "accomplish --> carry out|do"
grep -R -i "accomplish" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "accorded --> given"
grep -R -i "accorded" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "eliminate 'very'"
# https://prowritingaid.com/grammar/1000047/Why-shouldn-t-you-use-the-word-very-in-your-writing
grep -R -i " very " latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

echo "accordingly --> so"
grep -R -i "accordingly" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "accrue --> add|gain"
grep -R -i "accrue" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "accurate --> correct|exact|right"
grep -R -i "accurate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "additional --> added|more|other"
grep -R -i "additional" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "address --> discuss"
grep -R -i "address" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "addressees --> you"
grep -R -i "addressees" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "addressees are requested --> (omit)|please"
grep -R -i "addressees are requested" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "adjacent to --> next to"
grep -R -i "adjacent to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "advantageous --> helpful"
grep -R -i "advantageous" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "adversely impact on --> hurt|set back"
grep -R -i "adverse* impact on" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "advise --> recommend|tell"
grep -R -i "advise" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "afford an opportunity --> allow|let"
grep -R -i "afford an opportunity" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "aircraft --> plane"
grep -R -i "aircraft" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "allocate --> divide"
grep -R -i "allocate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "anticipate --> expect"
grep -R -i "anticipate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "a number of --> some"
grep -R -i "a number of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "apparent --> clear|plain"
grep -R -i "apparent" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "appreciable --> many"
grep -R -i "appreciable" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "appropriate --> (omit)|proper|right"
grep -R -i "appropriate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "approximate --> about"
grep -R -i "approximate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "arrive onboard --> arrive"
grep -R -i "arrive onboard" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "as a means of --> to"
grep -R -i "as a means of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "ascertain --> find out|learn"
grep -R -i "ascertain" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "as prescribed by --> in|under"
grep -R -i "as prescribed by" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "assist, assistance --> aid|help"
grep -R -i "assist" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "attain --> meet"
grep -R -i "attain" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "attempt --> try"
grep -R -i "attempt" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "at the present time --> at present|now"
grep -R -i "at the present time" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "benefit --> help"
grep -R -i "benefit" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "by means of --> by|with"
grep -R -i "by means of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "capability --> ability"
grep -R -i "capability" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "caveat --> warning"
grep -R -i "caveat" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "close proximity --> near"
grep -R -i "close proximity" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "combat environment --> combat"
grep -R -i "combat environment" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "combined --> joint"
grep -R -i "combined" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "commence --> begin|start"
grep -R -i "commence" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "comply with --> follow"
grep -R -i "comply with" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "component --> part"
grep -R -i "component" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "comprise --> form|include|make up"
grep -R -i "comprise" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "concerning --> about|on"
grep -R -i "concerning" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "consequently --> so"
grep -R -i "consequently" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "consolidate --> combine|join|merge"
grep -R -i "consolidate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "constitutes --> is|forms|makes up"
grep -R -i "constitutes" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "contains --> has"
grep -R -i "contains" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "convene --> meet"
grep -R -i "convene" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "currently --> (omit)|now"
grep -R -i "currently" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "deem --> believe|consider|think"
grep -R -i "deem" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "delete --> cut|drop"
grep -R -i "delete" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "demonstrate --> prove|show"
grep -R -i "demonstrate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "depart --> leave"
grep -R -i "depart" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "designate --> appoint|choose|name"
grep -R -i "designate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "desire --> want|wish"
grep -R -i "desire" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "determine --> decide|figure|find"
grep -R -i "determine" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "disclose --> show"
grep -R -i "disclose" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "discontinue --> drop|stop"
grep -R -i "discontinue" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "disseminate --> give|issue|pass|send"
grep -R -i "disseminate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "due to the fact that --> due to|since"
grep -R -i "due to the fact that" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "during the period --> during"
grep -R -i "during the period" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "effect modifications --> make changes"
grep -R -i "effect modifications" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "elect --> choose|pick"
grep -R -i "elect" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "eliminate --> cut|drop|end"
grep -R -i "eliminate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "employ --> use"
grep -R -i "employ" latex/*.tex | grep --invert-match employee
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "encounter --> meet"
grep -R -i "encounter" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "endeavor --> try"
grep -R -i "endeavor" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "ensure --> make sure"
grep -R -i "ensure" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "enumerate --> count"
grep -R -i "enumerate" latex/*.tex | grep --invert-match begin | grep --invert-match end
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "equipments --> equipment"
grep -R -i "equipments" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "equitable --> fair"
grep -R -i "equitable" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "establish --> set up|prove|show"
grep -R -i "establish" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "evidenced --> showed"
grep -R -i "evidenced" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "evident --> clear"
grep -R -i "evident" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "exhibit --> show"
grep -R -i "exhibit" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "expedite --> hasten|speed up"
grep -R -i "expedite" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "expeditious --> fast|quick"
grep -R -i "expeditious" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "expend --> spend"
grep -R -i "expend" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "expertise --> ability"
grep -R -i "expertise" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "expiration --> end"
grep -R -i "expiration" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "facilitate --> ease|help"
grep -R -i "facilitate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "failed to --> didn’t"
grep -R -i "failed to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "feasible --> can be done|workable"
grep -R -i "feasible" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "females --> women"
grep -R -i "females" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "finalize --> complete|finish"
grep -R -i "finalize" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "for a period of --> for"
grep -R -i "for a period of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "for example,______etc --> for example|such as"
grep -R -i "for example,.*etc" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "forfeit --> give up|lose"
grep -R -i "forfeit" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "forward --> send"
grep -R -i "forward" latex/*.tex | grep --invert-match straightforward
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "frequently --> often"
grep -R -i "frequently" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "function --> act|role|work"
grep -R -i "function" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "furnish --> give|send"
grep -R -i "furnish" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "has a requirement for --> needs"
grep -R -i "has a requirement for" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "herein --> here"
grep -R -i "herein" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "heretofore --> until now"
grep -R -i "heretofore" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "herewith --> below|here"
grep -R -i "herewith" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "however --> but"
grep -R -i "however" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "identical --> same"
grep -R -i "identical" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "identify --> find|name|show"
grep -R -i "identify" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "immediately --> at once"
grep -R -i "immediately" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "impacted --> affected|changed"
grep -R -i "impacted" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in accordance with --> by|following|per|under"
grep -R -i "in accordance with" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in addition --> also|besides|too"
grep -R -i "in addition" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in an effort to --> to"
grep -R -i "in an effort to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "inasmuch as --> since"
grep -R -i "inasmuch as" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in a timely manner --> on time|promptly"
grep -R -i "in a timely manner" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "inception --> start"
grep -R -i "inception" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "incumbent upon --> must"
grep -R -i "incumbent upon" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "indicate --> show|write down"
grep -R -i "indicate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "indication --> sign"
grep -R -i "indication" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "initiate --> start"
grep -R -i "initiate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in lieu of --> instead"
grep -R -i "in lieu of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in order that --> for|so"
grep -R -i "in order that" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in order to --> to"
grep -R -i "in order to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in regard to --> about|concerning|on"
grep -R -i "in regard to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in relation to --> about|with|to"
grep -R -i "in relation to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


# I'm not familiar with this, but it means "among other things"
echo "inter alia --> (omit)"
grep -R -i "inter alia" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "interface --> meet|work with"
grep -R -i "interface" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "interpose no objection --> don’t object"
grep -R -i "interpose no objection" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in the amount of --> for"
grep -R -i "in the amount of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in the event of --> if"
grep -R -i "in the event of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in the near future --> shortly|soon"
grep -R -i "in the near future" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in the process of --> (omit)"
grep -R -i "in the process of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in view of --> since"
grep -R -i "in view of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "in view of the above --> so"
grep -R -i "in view of the above" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "is applicable to --> applies to"
grep -R -i "is applicable to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "is authorized to --> may"
grep -R -i "is authorized to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "is in consonance with --> agrees with|follows"
grep -R -i "is in consonance with" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "is responsible for --> (omit)|handles"
grep -R -i "is responsible for" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "it appears --> seems"
grep -R -i "it appears" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "it is --> (omit)"
grep -R -i "it is" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "it is essential --> must|need to"
grep -R -i "it is essential" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "it is requested --> please|we request|I request"
grep -R -i "it is requested" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "liaison --> discussion"
grep -R -i "liaison" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "limited number --> limits"
grep -R -i "limited number" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "magnitude --> size"
grep -R -i "magnitude" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "maintain --> keep|support"
grep -R -i "maintain" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "maximum --> greatest|largest|most"
grep -R -i "maximum" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "methodology --> method"
grep -R -i "methodology" latex/*.tex | grep --invert-match :%
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "minimize --> decrease|method"
grep -R -i "minimize" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "minimum --> least|smallest"
grep -R -i "minimum" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "modify --> change"
grep -R -i "modify" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "monitor --> check|watch"
grep -R -i "monitor" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "necessitate --> cause|need"
grep -R -i "necessitate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "notify --> let know|tell"
grep -R -i "notify" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "not later than 10 May --> by 10 May|before 11 May"
grep -R -i "not later than " latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "not later than 1600 --> by 1600"
grep -R -i "not later than 1600" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "notwithstanding --> inspite of|still"
grep -R -i "notwithstanding" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "numerous --> many"
grep -R -i "numerous" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "objective --> aim|goal"
grep -R -i "objective" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "obligate --> bind|compel"
grep -R -i "obligate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "observe --> see"
grep -R -i "observe" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "on a regular basis --> (omit)"
grep -R -i "on a regular basis" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "operate --> run|use|work"
grep -R -i "operate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "optimum --> best|greatest|most"
grep -R -i "optimum" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "option --> choice|way"
grep -R -i "option" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "parameters --> limits"
grep -R -i "parameters" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "participate --> take part"
grep -R -i "participate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "perform --> do"
grep -R -i "perform" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "permit --> let"
grep -R -i "permit" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "pertaining to --> about|of|on"
grep -R -i "pertaining to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "portion --> part"
grep -R -i "portion" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "possess --> have|own"
grep -R -i "possess" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "practicable --> practical"
grep -R -i "practicable" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "preclude --> prevent"
grep -R -i "preclude" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "previous --> earlier"
grep -R -i "previous" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "previously --> before"
grep -R -i "previously" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "prioritize --> rank"
grep -R -i "prioritize" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "prior to --> before"
grep -R -i "prior to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "proceed --> do|go ahead|try"
grep -R -i "proceed" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "procure --> (omit)"
grep -R -i "procure" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "proficiency --> skill"
grep -R -i "proficiency" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "promulgate --> issue|publish"
grep -R -i "promulgate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "provide --> give|offer|say"
grep -R -i "provide" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "provided that --> if"
grep -R -i "provided that" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "provides guidance for --> guides"
grep -R -i "provides guidance for" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "purchase --> buy"
grep -R -i "purchase" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "pursuant to --> by|following|per|under"
grep -R -i "pursuant to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "reflect --> say|show"
grep -R -i "reflect" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "regarding --> about|of|on"
grep -R -i "regarding" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "relative to --> about|on"
grep -R -i "relative to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "relocate --> move"
grep -R -i "relocate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "remain --> stay"
grep -R -i "remain" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "remainder --> rest"
grep -R -i "remainder" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "remuneration --> pay|payment"
grep -R -i "remuneration" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "render --> give|make"
grep -R -i "render" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "represents --> is"
grep -R -i "represents" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "request --> ask"
grep -R -i "request" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "require --> must|need"
grep -R -i "require" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "requirement --> need"
grep -R -i "requirement" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "reside --> live"
grep -R -i "reside" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "retain --> keep"
grep -R -i "retain" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


# not clear what the intent with this one is
echo "said, some, such --> the|this|that"
grep -R -i "said, some, such" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "selection --> choice"
grep -R -i "selection" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "set forth in --> in"
grep -R -i "set forth in" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "similar to --> like"
grep -R -i "similar to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "solicit --> ask for|request"
grep -R -i "solicit" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "state-of-the-art --> latest"
grep -R -i "state-of-the-art" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "subject --> the|this|your"
grep -R -i "subject" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "submit --> give|send"
grep -R -i "submit" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "subsequent --> later|next"
grep -R -i "subsequent" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "subsequently --> after|later|then"
grep -R -i "subsequently" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "substantial --> large|much"
grep -R -i "substantial" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "successfully complete --> complete|pass"
grep -R -i "successfully complete" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "sufficient --> enough"
grep -R -i "sufficient" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "take action to --> (omit)"
grep -R -i "take action to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "terminate --> end|stop"
grep -R -i "terminate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "the month of --> (omit)"
grep -R -i "the month of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "there are --> (omit)"
grep -R -i "there are" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "therefore --> so"
grep -R -i "therefore" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "therein --> there"
grep -R -i "therein" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "there is --> (omit)"
grep -R -i "there is" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "thereof --> its|their"
grep -R -i "thereof" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "the undersigned --> I"
grep -R -i "the undersigned" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "the use of --> (omit)"
grep -R -i "the use of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear

# not clear what the intent of this is
echo "this activity, command --> us|we"
grep -R -i "this activity, command" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "timely --> prompt"
grep -R -i "timely" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "time period --> (either one)"
grep -R -i "time period" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "transmit --> send"
grep -R -i "transmit" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "type --> (omit)"
grep -R -i "type" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "under the provisions of --> under"
grep -R -i "under the provisions of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "until such time as --> until"
grep -R -i "until such time as" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "utilize, utilization --> use"
grep -R -i "utilize, utilization" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "validate --> confirm"
grep -R -i "validate" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "viable --> practical|workable"
grep -R -i "viable" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "vice --> instead of|versus"
grep -R -i "vice" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "warrant --> call for|permit"
grep -R -i "warrant" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "whereas --> because|since"
grep -R -i "whereas" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "with reference to --> about"
grep -R -i "with reference to" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "with the exception of --> except for"
grep -R -i "with the exception of" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "witnessed --> saw"
grep -R -i "witnessed" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "your office --> you"
grep -R -i "your office" latex/*.tex
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear


echo "/ (slash) --> and|or"
grep -R -i "/" latex/*.tex | grep --invert-match http | grep --invert-match includegraphics
if [[ $? -eq 0 ]]; then
    read -p "Press ENTER key to resume ..."
fi
clear
