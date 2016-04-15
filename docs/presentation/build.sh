osascript -e 'quit app "PDF Expert"'

pdflatex presentation
open presentation.pdf

rm -f *.aux *.bbl *.blg *.dvi *.log *.toc *.snm *.out *.nav
