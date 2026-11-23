.PHONY: venv deps test lint lint-md

venv:
	python3 -m venv .venv
	.venv/bin/pip install pytest pytest-cov bandit pip-audit ruff mypy shellcheck-py

deps:
	cd .ci-tools && npm ci --ignore-scripts && npm audit

test:
	.venv/bin/pytest --cov=subsystems/02-fingerprint-vfs495/scripts --cov-report=term-missing

lint: lint-md
	.venv/bin/ruff check .
	.venv/bin/mypy subsystems/02-fingerprint-vfs495/scripts
	.venv/bin/bandit -r subsystems/02-fingerprint-vfs495/scripts -q
	.venv/bin/pip-audit
	.venv/bin/shellcheck subsystems/02-fingerprint-vfs495/scripts/*.sh

lint-md: deps
	.ci-tools/node_modules/.bin/markdownlint-cli2 "*.md" ".github/**/*.md" ".gitlab/**/*.md" "docs/**/*.md" "firmware_dump/**/*.md" "security_and_flashing/**/*.md" "subsystems/**/*.md"
