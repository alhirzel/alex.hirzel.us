hakyll=./hakyll

DEFAULT: build



# catch updates to these files
PAGES: $(wildcard *.html)
TEMPLATES: $(wildcard *.mt)



# actions
deploy: build
	rsync -rv htdocs/ nfsn:/home/public

build: hakyll PAGES TEMPLATES
	${hakyll} rebuild

clean:
	-${hakyll} clean
	rm -f ${hakyll}



# build commands for the hakyll script
hakyll: hakyll.hs
	ghc --make hakyll.hs
	rm -f hakyll.o hakyll.hi



.PHONY: PAGES TEMPLATES update up build bu clean cl
