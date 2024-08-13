# Backend
Python backend for Chemtrend

# Run
Either via compose or run locally. First you need the Postgres container up and running, see the `db` directory.

bash
```
cd backend
poetry install
fastapi dev ./chemtrend/main.py
```