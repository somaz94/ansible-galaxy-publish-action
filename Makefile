.PHONY: lint test test-collection test-role fixtures clean help

FIXTURE_COLLECTION := tests/fixtures/sample_collection
FIXTURE_ROLE       := tests/fixtures/sample_role

## Quality

lint: ## yamllint action.yml + workflows + fixtures (dockerized, no host install)
	docker run --rm -v "$(CURDIR)":/data cytopia/yamllint -d relaxed action.yml .github/workflows/ tests/

## Testing

test: test-collection test-role ## Run collection and role dry-run locally (requires ansible)

test-collection: ## Build + dry-run publish the fixture collection locally
	cd $(FIXTURE_COLLECTION) && ansible-galaxy collection build --force
	@t="$(FIXTURE_COLLECTION)/somaz94-sample_collection-$$(sed -n 's/^version: *//p' $(FIXTURE_COLLECTION)/galaxy.yml).tar.gz"; \
	  test -f "$$t" || { echo "missing $$t"; exit 1; }; \
	  echo "[dry-run] would publish: $$t"

test-role: ## Validate the fixture role metadata (no Galaxy call)
	grep -q '^galaxy_info:' $(FIXTURE_ROLE)/meta/main.yml
	@echo "[dry-run] would import: role/somaz94.sample_role"

fixtures: ## List fixture files (committed — nothing to generate)
	@ls -R $(FIXTURE_COLLECTION) $(FIXTURE_ROLE)

## Cleanup

clean: ## Remove built collection tarballs
	rm -f $(FIXTURE_COLLECTION)/*.tar.gz

## Help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
