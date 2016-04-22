osascript -e 'quit app "PDF Expert"'

rm graphs/*.pdf
cp ../../evaluation/r_analysis/*.pdf graphs/

pdflatex abdnthesis
#bibtex abdnthesis
#pdflatex abdnthesis
#pdflatex abdnthesis

rm -f *.aux *.bbl *.blg *.dvi *.log *.toc

open abdnthesis.pdf
texcount *.tex
