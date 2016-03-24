osascript -e 'quit app "PDF Expert"'

pdflatex abdnthesis
bibtex abdnthesis
pdflatex abdnthesis
pdflatex abdnthesis

rm -f *.aux *.bbl *.blg *.dvi *.log *.toc

open abdnthesis.pdf
texcount *.tex
