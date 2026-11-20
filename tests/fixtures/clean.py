import os

import requests


def load_user(uid: str) -> dict:
    resp = requests.get(
        "https://api.internal/users/" + uid,
        headers={"Authorization": "Bearer " + os.environ["API_TOKEN"]},
        timeout=10,
    )
    resp.raise_for_status()
    return resp.json()
