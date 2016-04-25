osascript -e 'quit app "PDF Expert"'

pdflatex $1
open $1.pdf

rm -f *.aux *.bbl *.blg *.dvi *.log *.toc *.snm *.out *.nav
