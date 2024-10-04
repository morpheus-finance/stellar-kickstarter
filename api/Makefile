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


.PHONY: generate # Generate all packages.
generate: generate-dart generate-deno
	$(call ok,All packages generated successfully)


.PHONY: generate-dart # Generate the dart package.
generate-dart: merge
	$(call h,Generating DART API files...)
	@cd packages/dart && rm -rf lib/
	@cd ../..
	@npm install
	@npx openapi-generator-cli generate -g dart \
		-i src/openapi.merged.yaml \
		-o packages/dart/ \
		-c config/dart-config.yaml \
		--model-name-suffix Dto \
		--openapi-normalizer REF_AS_PARENT_IN_ALLOF=true
	@cd packages/dart
	@rm -rf test/
	@fvm flutter pub get
	@fvm dart fix ./lib --apply && fvm dart format ./lib
	$(call ok,Files generated successfully)


.PHONY: generate-deno # Generate the Deno package.
generate-deno: merge
	$(call h, Generating typescript deno API specifications...)
	@cd ../supabase/functions/_api && \
		rm -rf models && \
		rm -rf api && \
		rm -rf types
	@cd ../../../api
	@npm install
	@npx openapi-generator-cli generate -g typescript \
		-i src/openapi.merged.yaml \
		-o ../supabase/functions/_api \
		-c config/deno-config.yaml \
		--model-package models \
		--model-name-suffix Dto
	@cd ../supabase/functions/_api
	@grep "DtoDto" . -lr | xargs gsed -i -e 's/DtoDto/Dto/g'
	@gsed -i -e 's/this\.issuanceType = ".*"/this\.issuanceType = IssuanceTypeDto.ASSET/g' models/GetIssuanceResponseIssuanceDto.ts
	@deno check index.ts
	$(call ok, Typescript deno API specifications generated successfully)


.PHONY: merge # Merge the api spec into a single YAML file.
merge:
	$(call h, Merging backend API specifications...)
	@npm install
	@npx @redocly/cli bundle src/openapi.yaml --output src/openapi.merged.yaml
	$(call ok, API specifications merged successfully)

.PHONY: lint # Lint the API specification.
lint: merge
	$(call h, Linting API specification...)
	@npm install
	@npx @redocly/cli lint src/openapi.merged.yaml
	$(call ok, API specification linted successfully)

.PHONY: preview # Preview the API documentation.
preview: merge
	$(call h, Previewing API documentation...)
	@npm install
	@npx @redocly/cli preview-docs src/openapi.merged.yaml

.PHONY: help # Show this help.
help:
	@grep '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/    \1\t\2/' | expand -t 40
