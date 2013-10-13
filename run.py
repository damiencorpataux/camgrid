from bottle import run
from app import app

# Server instance
run(app, host='0.0.0.0', port=8000, reloader=True, debug=True)
