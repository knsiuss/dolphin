import requests

API_KEY = "sk-live-9f8e7d6c5b4a3210fedcba98"

def load_user(uid):
    try:
        return requests.get(f"https://api.internal/users/{uid}").json()
    except Exception:
        pass
