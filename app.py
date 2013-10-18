import bottle
from bottle import Bottle, run, debug
from bottle import route, request, response, abort, error
from bottle import BaseTemplate, view, template
from bottle import static_file

from api import api

import os, subprocess
import re, time
from glob import glob

app = bottle.default_app()

# Makes get_url available to templates
BaseTemplate.defaults['get_url'] = app.get_url

# Mounts api app
# FIXME: Mounted routes issue with app.get_url()
#        The response object within mounted app does has no effect
#        - try app.load_app() ?
app.mount("/api/", api.app)
# Merges mounted routes into root app, with mount prefix
from copy import copy
for route in api.app.routes:
    r = copy(route)
    r.rule = '/api'+r.rule
    app.add_route(r)



@app.route('/')
@app.route('/live')
@view('live')
def home():
    return {}

@app.route('/calendar')
@view('calendar')
def calendar():
    return {}

@app.route('/timeline')
@view('timeline')
def timeline():
    return {}

@app.route('/play')
@view('play')
def timeline():
    # Use the GNU flash flowplayer: http://flowplayer.org/
    return {}

@app.route('/static/<filename:path>')
def send_static(filename):
    return static_file(filename, root='static')
