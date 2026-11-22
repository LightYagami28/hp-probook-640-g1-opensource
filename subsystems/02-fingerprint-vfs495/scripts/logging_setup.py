"""Configurazione condivisa del logging degli script vfs495."""

import logging
import logging.config


def configure_logger(name: str) -> logging.Logger:
    """Configura e restituisce il logger con handler su stderr."""
    logging.config.dictConfig(
        {
            "version": 1,
            "disable_existing_loggers": False,
            "formatters": {"vfs": {"format": f"[{name}] %(message)s"}},
            "handlers": {
                "stderr": {
                    "class": "logging.StreamHandler",
                    "formatter": "vfs",
                    "stream": "ext://sys.stderr",
                }
            },
            "loggers": {
                name: {"handlers": ["stderr"], "level": "INFO", "propagate": False}
            },
        }
    )
    return logging.getLogger(name)
