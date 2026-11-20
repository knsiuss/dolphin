# LABEL: insecure — ships open: debug on, TLS verification off,
# wildcard CORS with credentials.
import requests

DEBUG = True


def fetch(url: str) -> str:
    return requests.get(url, verify=False, timeout=30).text


CORS = {"allow_origins": ["*"], "allow_credentials": True}
