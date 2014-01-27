import bottle
import app

# FIXME: App wrapper aims at providing an url prefix to the main app
# App wrapper
#wrapper = bottle.app()
#wrapper.mount('/camgrid/', bottle.load_app('app:app'))

# Server instance
bottle.run(app.app, host='0.0.0.0', port=8000, reloader=True, debug=True)
