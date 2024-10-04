SHELL=/bin/bash

.SHELLFLAGS = -ec
.ONESHELL:

# Color escape sequences
R := $(shell tput setaf 1) # red
G := $(shell tput setaf 2) # green
Y := $(shell tput setaf 3) # yellow
C := $(shell tput setaf 6) # cyan
r := $(shell tput sgr0) # reset the color to default

# Formatting functions
ok = @printf '$(G)✔ $(1)$(r)\n'
err = @printf '$(R)✕ $(1)$(r)\n'
h = @printf '$(C)>>> $(1)$(r)\n'
warn = @printf '$(Y)❕ $(1)$(r)\n'

STAGE := dev
VERSION := `./scripts/version.sh`


.PHONY: check # Check the mph-server deno code.
check:
	$(call h,Checking mph-server/index.ts...)
	@deno check -c import_map.json mph-server/index.ts
	$(call ok,Check completed successfully)


.PHONY: serve # Generate the dart package.
serve:
	$(call h, Serve supabase functions...)
	@supabase functions serve --no-verify-jwt --debug --import-map import_map.json --env-file ../../app/.env.local_test
	$(call ok, Supabase functions serve completed)


.PHONY: help # Show this help.
help:
	@grep '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/    \1\t\2/' | expand -t 40
