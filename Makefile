# Short, memorable entry points. Claude and humans both use these,
# so the "how do I build this?" answer never drifts.
HUGO := ./.bin/hugo

.PHONY: help tools tool-hashes serve build check clean i18n-check ansible-lint ansible-check

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

tools: ## Install pinned Hugo into ./.bin
	./scripts/install-tools.sh

tool-hashes: ## Print SHA-256 lines for versions.env from the official release checksums
	./scripts/tool-hashes.sh

serve: ## Local preview with drafts at http://localhost:1313
	$(HUGO) server --buildDrafts --navigateToChanged

build: ## Production build into ./public
	$(HUGO) --minify --gc --cleanDestinationDir

check: ## Strict build: any Hugo warning (deprecations, missing templates) fails
	$(HUGO) --minify --gc --cleanDestinationDir --panicOnWarning
	@python3 scripts/check-i18n.py
	@echo "Page weights (bytes, uncompressed):"
	@find public -name '*.html' -printf '%s\t%p\n' | sort -rn | head -5

i18n-check: ## Every UI string key must exist in every language
	python3 scripts/check-i18n.py

clean: ## Remove build output
	rm -rf public resources/_gen .hugo_build.lock

ansible-lint: ## Lint the Ansible code
	cd infra/ansible && ansible-lint

ansible-check: ## Dry-run the playbook against the server (shows the diff, changes nothing)
	cd infra/ansible && ansible-playbook playbooks/site.yml --check --diff
