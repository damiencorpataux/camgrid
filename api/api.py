from bottle import Bottle, run
from glob import glob

app = Bottle()

c = config = {
    'events': {
        'path': '/home/damien/motion-storage'
    }
}

@app.route('/')
def hello():
    return "Hello World!"

@app.route('/events')
def get_events():
    path = c['events']['path']+'/*/*.avi'
    files = glob(path)
    return {
        'path': path,
        'count': len(files),
        'files': files,
    }

# Server instance
run(app, host='0.0.0.0', port=8000, reloader=True)
