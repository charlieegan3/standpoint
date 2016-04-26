osascript -e 'quit app "PDF Expert"'

rm graphs/*.pdf
cp ../../evaluation/r_analysis/*.pdf graphs/

pdflatex -shell-escape abdnthesis
bibtex abdnthesis
pdflatex -shell-escape abdnthesis
pdflatex -shell-escape abdnthesis

rm -f *.aux *.bbl *.blg *.dvi *.log *.toc

open abdnthesis.pdf
texcount *.tex
