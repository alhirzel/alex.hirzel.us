HAKYLL=./hakyll

build: ${HAKYLL}
	${HAKYLL} rebuild

clean:
	${HAKYLL} clean
	rm ${HAKYLL}

deploy: ${HAKYLL}
	${HAKYLL} deploy

${HAKYLL}: hakyll.hs
	ghc --make hakyll.hs
	rm -f hakyll.o hakyll.hi

.PHONY: build clean deploy

