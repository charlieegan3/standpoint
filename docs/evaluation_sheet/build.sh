osascript -e 'quit app "PDF Expert"'

pdflatex sheet
open sheet.pdf

rm -f *.aux *.bbl *.blg *.dvi *.log *.toc *.snm *.out *.nav
