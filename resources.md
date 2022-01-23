


# typesetting using Latex

* <https://en.wikibooks.org/wiki/LaTeX>

## typsetting a book using Latex

* <https://tex.stackexchange.com/questions/66902/latex-template-for-typesetting-a-novel>

## Latex to HTML

See <https://texfaq.org/FAQ-LaTeX2HTML> and <https://tex.stackexchange.com/a/3083/235813>

### pandoc

```
pandoc myTexFile.tex -f latex -t html -s -o myHtmlFile.html --bibliography myTexBiblio.bib
```
* `-f` specifies the source format, LaTeX
* `-t` specifies the target format (HTML)
* `-s` tells pandoc to produce a 'standalone' HTML file
* `-o` specifies the output filename
* `--bibliography` gives pandoc the .bib file for the citations in myTexFile.tex

From <https://www.danwjoyce.com/data-blog/2018/2/20/latex-to-html-via-pandoc>

### <https://tug.org/tex4ht/>

```
htlatex mydocument.tex
```

