# LABEL: insecure — SQL built by string interpolation of user input.
import sqlite3


def find_user(conn: sqlite3.Connection, username: str):
    query = f"SELECT * FROM users WHERE name = '{username}'"
    return conn.execute(query).fetchall()
