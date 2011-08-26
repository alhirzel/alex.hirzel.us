hakyll=./hakyll

DEFAULT: build



# catch updates to these files
PAGES: $(wildcard *.html)
TEMPLATES: $(wildcard *.mt)



# actions
# TODO: write this
up update: build
	#rsync -rv htdocs/ nfsn:/home/public

bu build: hakyll PAGES TEMPLATES
	${hakyll} build

cl clean: hakyll
	${hakyll} clean
	rm -f ${hakyll}



# build commands for the hakyll script
hakyll: hakyll.hs
	ghc --make hakyll.hs
	rm -f hakyll.o hakyll.hi
	${hakyll} clean



.PHONY: PAGES TEMPLATES update up build bu clean cl
