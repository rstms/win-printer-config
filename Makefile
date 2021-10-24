# Makefile for printer-config 
#

PROJECT_DIR := %USERPROFILE%\\src\\win-printer-config
INSTALL_BIN := %USERPROFILE%\\scripts

RUN := @cmd /c $(PROJECT_DIR)/wpc.cmd

test:
	$(RUN) $(ARGS)

all: printers printers-verbose printers-v ports ports-verbose ports-v help

printers:
	@echo --- $@ ---
	$(RUN) list-printers

printers-verbose:
	@echo --- $@ ---
	$(RUN) --verbose list-printers

printers-v:
	@echo --- $@ ---
	$(RUN) -v list-printers

ports:
	@echo --- $@ ---
	$(RUN) list-ports 

ports-verbose:
	@echo --- $@ ---
	$(RUN) --verbose list-ports

ports-v:
	@echo --- $@ ---
	$(RUN) -v list-ports

show:
	@echo --- $@ ---
	$(RUN) show-printer laserbro

show-port:
	$(RUN) show-port laserbro-tcp

help:
	@echo --- $@ ---
	$(RUN) help

install:
	cmd /c "copy $(PROJECT_DIR)\\wpc.cmd $(INSTALL_BIN)"
