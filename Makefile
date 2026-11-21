.PHONY: venv test lint

venv:
	python3 -m venv .venv
	.venv/bin/pip install pytest pytest-cov bandit pip-audit ruff mypy shellcheck-py

test:
	.venv/bin/pytest --cov=subsystems/02-fingerprint-vfs495/scripts --cov-report=term-missing

lint:
	npx markdownlint-cli2 "**/*.md"
	.venv/bin/ruff check .
	.venv/bin/mypy subsystems/02-fingerprint-vfs495/scripts
	.venv/bin/bandit -r subsystems/02-fingerprint-vfs495/scripts -q
	.venv/bin/pip-audit
	.venv/bin/shellcheck subsystems/02-fingerprint-vfs495/scripts/*.sh
