#!/usr/bin/env bash

# PANDOC does a great job converting LATEX to HTML.
# This file provides a few tweaks to the HTML to make
# the document look even better.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

# replace PDF with PNG for images
sed -i '' 's/\("images\/.*\)pdf"/\1png"/' latex/main.html

# instead of embedded images, just point to the PNG as an IMG
sed -i '' 's/<embed/<img/' latex/main.html

# replace tilted quote with straight quote
#sed -i '' "s/’/'/g" main.html
#sed -i '' 's/“/"/g' main.html

# single quote
sed -i '' "s/&#x2018;/'/g" latex/main.html
sed -i '' "s/&#x2019;/'/g" latex/main.html

# CAVEAT: ampersand needs to be escaped in the output because it means "match" for sed
# space
sed -i '' "s/&#xA0;/\&nbsp;/g" latex/main.html

# double quote
sed -i '' 's/&#x201D;/"/g' latex/main.html
sed -i '' 's/&#x201C;/"/g' latex/main.html

# copyright symbol
#sed -i '' 's/&#xA9;/\(C\)/g' latex/main.html

# em dash
sed -i '' 's/&#x2013;/--/g' latex/main.html

# footnote return indicator
sed -i '' 's/&#x21A9;&#xFE0E;/\&nbsp;return to text/g' latex/main.html

# fix hyperlinked chapter numbers
# CAVEAT: this is a fragile fix since the chapter numbers are hard-coded.
sed -i '' 's/>\[sec:introduction\]</>1</' latex/main.html
sed -i '' 's/>\[sec:why-bur-hard\]</>4</' latex/main.html
sed -i '' 's/>\[sec:individual-in-org\]</>5</' latex/main.html
sed -i '' 's/>\[sec:process\]</>8</' latex/main.html
sed -i '' 's/>\[sec:communication-within-bureaucracy\]</>6</' latex/main.html

# EOF
