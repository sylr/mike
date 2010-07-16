# Mike's Makefile
# author: Sylvain Rabot <sylvain@abstraction.fr>
# date : 03/07/2010
# copyright : All rights reserved

#          __  _________ ______
#         /  |/  /  _/ //_/ __/
#        / /|_/ // // ,< / _/  
#       /_/  /_/___/_/|_/___/  
#

# The default target of this Makefile is...
dry-run::

ECHO                    = echo
CAT                     = cat
RM                      = rm -f
GIT                     = git
SLEEP                   = sleep
SLEEP_TIME              = 0.1
DATE                    = `date`
PSQL                    ?= psql
PSQL                    += -v 'ON_ERROR_STOP=on'
DATABASE_USER           ?= mike
DATABASE_NAME           ?= mike
DATABASE_TRIGGERS       = $(wildcard triggers/*.pl)
DATABASE_TRIGGERS       += $(wildcard triggers/*.sql)
DATABASE_FILES          = mike.sql
DATABASE_FILES          += $(DATABASE_TRIGGERS)
DATABASE_DUMPS          = $(patsubst %.sql, %.dump, $(filter %.sql, $(DATABASE_FILES)))
DATABASE_DUMPS          += $(patsubst %.pl, %.dump, $(filter %.pl,  $(DATABASE_FILES)))
TARGET_FILE             = mike.o
MIKE_VERSION_FILE       = MIKE_VERSION_FILE
MIKE_COMMIT_DIFF_FILE   = MIKE_COMMIT_DIFF_FILE

$(MIKE_VERSION_FILE):
	@$(RM) $(MIKE_VERSION_FILE)
	@$(SHELL_PATH) ./MIKE_VERSION_GEN $(MIKE_VERSION_FILE) $(MIKE_COMMIT_DIFF_FILE)
-include $(MIKE_VERSION_FILE)

ifeq ($(CREATE_SCHEMA),Yes)
	CREATE_SCHEMA = "DROP SCHEMA IF EXISTS mike CASCADE; CREATE SCHEMA mike;"
else
	CREATE_SCHEMA = ""
endif
	
clean-target:
	@echo '    ' REMOVING $(TARGET_FILE); $(RM) $(TARGET_FILE); $(SLEEP) $(SLEEP_TIME)

info:
	@echo '    ' LINK MIKE_VERSION $(MIKE_VERSION);     echo "INSERT INTO mike.info VALUES ('MIKE_VERSION', '$(MIKE_VERSION)');" >> $(TARGET_FILE); $(SLEEP) $(SLEEP_TIME)
	@echo '    ' LINK MIKE_COMMIT $(MIKE_COMMIT);       echo "INSERT INTO mike.info VALUES ('MIKE_COMMIT', '$(MIKE_COMMIT)');" >> $(TARGET_FILE); $(SLEEP) $(SLEEP_TIME)
	@echo -n; \
	if test -f $(MIKE_COMMIT_DIFF_FILE); then \
	echo '    ' LINK MIKE_COMMIT_DIFF_FILE;             (echo "INSERT INTO mike.info VALUES ('MIKE_COMMIT_DIFF', E'"; \
	                                                        cat $(MIKE_COMMIT_DIFF_FILE) | sed "s/\(['\\]\)/\1\1/g"; \
	                                                        echo "');";) >> $(TARGET_FILE); $(SLEEP) $(SLEEP_TIME); \
	fi
	@echo '    ' LINK INSTALL_DATE $(DATE);             echo "INSERT INTO mike.info VALUES ('INSTALL_DATE', NOW()::varchar);" >> $(TARGET_FILE); $(SLEEP) $(SLEEP_TIME)
	@echo '    ' LINK MIKE_USER;                        echo "INSERT INTO mike.user VALUES (1, 'mike', 'mike');" >> $(TARGET_FILE); $(SLEEP) $(SLEEP_TIME)
    
dumps: clean-target $(DATABASE_DUMPS) info

%.dump : %.sql
	@echo '    ' LINK $<; $(CAT) $< >> $(TARGET_FILE); $(SLEEP) $(SLEEP_TIME)

%.dump : %.pl
	@echo '    ' LINK $<; $(CAT) $< >> $(TARGET_FILE); $(SLEEP) $(SLEEP_TIME)

dry-run:: dumps
	@echo '    ' EXECUTING; $(SLEEP) $(SLEEP_TIME)
	@echo; ($(ECHO) "BEGIN;"; $(ECHO) $(CREATE_SCHEMA); $(CAT) $(TARGET_FILE); $(ECHO) "ROLLBACK;") | $(PSQL) -U $(DATABASE_USER) -d $(DATABASE_NAME)
	@echo 
	@echo "THIS WAS A DRY RUN !!!!"

install: dumps
	@echo '    ' EXECUTING; $(SLEEP) $(SLEEP_TIME)
	($(ECHO) "BEGIN;"; $(ECHO) $(CREATE_SCHEMA); $(CAT) $(TARGET_FILE); $(ECHO) "COMMIT;") | $(PSQL) -U $(DATABASE_USER) -d $(DATABASE_NAME)

gitclean:
	@$(GIT) clean -fdx

mikeclean:
	@echo '    ' REMOVING $(TARGET_FILE); $(RM) $(TARGET_FILE); $(SLEEP) $(SLEEP_TIME);
	@echo '    ' REMOVING MIKE_FILE_VERSION; $(RM) $(MIKE_VERSION_FILE); $(SLEEP) $(SLEEP_TIME);
	@echo '    ' REMOVING MIKE_COMMIT_DIFF; $(RM) $(MIKE_COMMIT_DIFF_FILE); $(SLEEP) $(SLEEP_TIME);

drop-schema:
	@echo '    ' DROPPING mike SCHEMA; $(ECHO) "DROP SCHEMA IF EXITS mike;" | $(PSQL) -U $(DATABASE_USER) -d $(DATABASE_NAME)

.PHONY: $(MIKE_VERSION_FILE)

# ------------------------------------------------------------------------------

ASCIIDOC            = asciidoc
ASCIIDOC_EXTRA      = -a data-uri -a icons -a toc -a iconsdir=/usr/share/asciidoc/icons --unsafe
DOCBOOK2ODF         = docbook2odf
DOCBOOK2ODF_EXTRA   = --force --quiet
DOCBOOK2PDF         = docbook2pdf
DOCBOOK2PDF_EXTRA   =
A2X                 = a2x
A2X_EXTRA           =
DOC_TXT             = $(wildcard /doc/*.txt)
DOC_HTML            = $(patsubst %.txt, %.html,$(DOC_TXT))
DOC_XML             = $(patsubst %.txt, %.xml, $(DOC_TXT))
DOC_ODT             = $(patsubst %.txt, %.odt, $(DOC_TXT))
DOC_PDF             = $(patsubst %.txt, %.pdf, $(DOC_TXT))

doc: $(DOC_HTML)

doc-html: $(DOC_HTML)

doc-xml: $(DOC_XML)

doc-odt: $(DOC_XML) $(DOC_ODT)

doc-pdf: $(DOC_XML) $(DOC_PDF)

%.html : %.txt
	$(ASCIIDOC) $(ASCIIDOC_EXTRA) -b xhtml11 -o $@ $<

%.xml : %.txt
	$(ASCIIDOC) $(ASCIIDOC_EXTRA) -b docbook -o $@ $<

%.pdf : %.xml
	$(DOCBOOK2PDF) $(DOCBOOK2PDF_EXTRA) -o ./ $<

%.odt : %.xml
	$(DOCBOOK2ODF) $(DOCBOOK2ODF_EXTRA) --output-file $@ $<

clean-doc:
	$(RM) $(DOC_HTML)
	$(RM) $(DOC_XML)
	$(RM) $(DOC_ODT)
	$(RM) $(DOC_PDF)
	$(RM) *~

