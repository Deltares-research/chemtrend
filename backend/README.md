# Backend
Python backend for Chemtrend, compatible with both python 3.11 and 3.12 (some dependency issues with 3.13)

# Run

bash
```
cd backend
poetry install
fastapi dev ./chemtrend/main.py
```


The file "config.txt" contains a connection string to connect to the database. See "config.txt.example" for an example, copy this file to "config.txt" and fill in your own user name and password.

# Logs
On the remote server, use ```sudo journalctl -u fastapi``` for logs.