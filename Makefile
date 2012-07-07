HAKYLL=./hakyll

DEFAULT: build



# catch updates to these files
PAGES: $(wildcard *.html)
TEMPLATES: $(wildcard *.mt)



# actions
deploy: build
	rsync -rv htdocs/ nfsn:/home/public

build: ${HAKYLL} PAGES TEMPLATES
	${HAKYLL} rebuild

clean:
	-${HAKYLL} clean
	rm -f ${HAKYLL}



# build commands for the hakyll script
${HAKYLL}: hakyll.hs
	ghc --make hakyll.hs
	rm -f hakyll.o hakyll.hi



.PHONY: PAGES TEMPLATES update up build bu clean cl
