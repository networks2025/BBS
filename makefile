#depends on
#pandoc (you may need haskell-updater to install it)
#dev-texlive/texlive-fontsrecommended
#dev-texlive/texlive-latexrecommended

all:
	pandoc syllabus_networks.md --variable colorlinks=true -o syllabus_networks.pdf
