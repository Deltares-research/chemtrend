# Backend
Python backend for Chemtrend

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