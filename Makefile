SHELL := /bin/bash
LIBDIR=${HOME}/Rlibs/lib
PACKAGE=mread.yaml
VERSION=$(shell grep Version DESCRIPTION |awk '{print $$2}')
TARBALL=${PACKAGE}_${VERSION}.tar.gz
PKGDIR=.
CHKDIR=.

## Set libPaths:
## export R_LIBS=${LIBDIR}

spelling:
	Rscript -e 'spelling::spell_check_package(".")'

testing:
	cp ${TARBALL} ${MRGSOLVE_TEST_LOC}
	touch ${MRGSOLVE_TEST_LOC}/${TARBALL}
	cp -r inst/maintenance/unit ${MRGSOLVE_TEST_LOC}
	cd ${MRGSOLVE_TEST_LOC} && git commit -am "testing release" && git push -u origin master

covr:
	Rscript "inst/maintenance/covr.R"

no-test:
	make build
	R CMD check ${TARBALL} --no-tests

everything:
	make all
	make pkgdown

pkgdown:
	Rscript "inst/maintenance/pkgdown.R"
	cp -r DOCS/ ../../mrgsolve/docs/
	touch ../../mrgsolve/docs/.nojekyll

test-all:
	export R_LIBS=$(LIBDIR)
	Rscript -e 'testthat::test_dir("tests/testthat/")'

cran:
	make house
	make doc
	make build
	R CMD CHECK --as-cran ${TARBALL} -o ${CHKDIR}

travis_build:
	make housemodel
	make doc
	make build
	make install

readme:
	Rscript -e 'library(rmarkdown); render("README.Rmd")'

all:
	make doc
	make build
	make install

.PHONY: doc
doc:
	Rscript inst/script/doc_mrgsolve.R

build:
	R CMD build --md5 $(PKGDIR) --no-manual

install:
	R CMD INSTALL --install-tests ${TARBALL} -l ~/Rlibs

install-build:
	R CMD INSTALL --build --install-tests ${TARBALL}

check:
	make doc
	make build
	R CMD check ${TARBALL} -o ${CHKDIR} --no-manual

qcheck:
	make doc
	make build
	R CMD check ${TARBALL} -o ${CHKDIR} --no-manual --no-codoc

check-cran:
	make house
	make doc
	make build
	R CMD check --as-cran ${TARBALL} -o ${CHKDIR}

test:
	R CMD INSTALL ${PKGDIR}
	make test-all

test1:
	Rscript -e 'testthat::test_file("tests/testthat.R")'

test2:
	Rscript -e 'testthat::test_dir("inst/maintenance/unit")'

clean:
	if test -d ${CHKDIR}/mrgsolve.Rcheck; then rm -rf ${CHKDIR}/mrgsolve.Rcheck;fi
	rm src/*.o
	rm src/*.so

datasets:
	Rscript inst/maintenance/datasets.R

travis:
	make build
	R CMD check --as-cran --no-manual ${TARBALL} -o ${CHKDIR}
	make test2

rhub:
	Rscript -e 'rhub::check_for_cran(env_vars = c(`_R_CHECK_FORCE_SUGGESTS_` = "false"))'

check-fedora:
	Rscript -e 'rhub::check_on_fedora(env_vars = c(`_R_CHECK_FORCE_SUGGESTS_` = "false"))'
check-devel:
	Rscript -e 'rhub::check_with_rdevel()'

check-win:
	Rscript -e 'devtools::check_win_devel()'

check-winhub:
	Rscript -e 'rhub::check_on_windows()'

.PHONY: doxygen
doxygen:
	doxygen doxyfile

