import bottle
import app

# FIXME: App wrapper aims at providing an url prefix to the main app
# App wrapper
#wrapper = bottle.app()
#wrapper.mount('/camgrid/', bottle.load_app('app:app'))

# Server instance
import paste
from paste import httpserver
bottle.run(server='paste', host='0.0.0.0', port='81')
