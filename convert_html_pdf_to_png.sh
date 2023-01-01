#!/usr/bin/env bash

# PANDOC does a great job converting LATEX to HTML.
# This file provides a few tweaks to the HTML to make
# the document look even better.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

cd latex

# replace PDF with PNG for images
sed -i '' 's/\("images\/.*\)pdf"/\1png"/' main.html

# instead of embedded images, just point to the PNG as an IMG
sed -i '' 's/<embed/<img/' main.html

# replace tilted quote with straight quote
sed -i '' "s/’/'/g" main.html
sed -i '' 's/“/"/g' main.html

# fix hyperlinked chapter numbers
# CAVEAT: this is a fragile fix since the chapter numbers are hard-coded. 
sed -i '' 's/>\[sec:introduction\]</>1</' main.html
sed -i '' 's/>\[sec:why-bur-hard\]</>4</' main.html
sed -i '' 's/>\[sec:individual-in-org\]</>5</' main.html
sed -i '' 's/>\[sec:process\]</>8</' main.html
sed -i '' 's/>\[sec:communication-within-bureaucracy\]</>6</' main.html

