.PHONY: venv test lint

venv:
	python3 -m venv .venv
	.venv/bin/pip install pytest pytest-cov

test:
	.venv/bin/pytest --cov=subsystems/02-fingerprint-vfs495/scripts --cov-report=term-missing

lint:
	npx markdownlint-cli2 "**/*.md"
