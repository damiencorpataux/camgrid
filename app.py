import bottle
from bottle import Bottle, run, debug
from bottle import route, request, response, abort, error
from bottle import view, template
from bottle import static_file

from api import api

import os, subprocess
import re, time
from glob import glob

app = bottle.app()
app.mount("/api", api.app)

@app.route('/')
@app.route('/live')
@view('live')
def home():
    return

@app.route('/calendar')
@view('calendar')
def calendar():
    return {
        'calendarurl': '/api'+api.app.get_url('/events')
    }

@app.route('/timeline')
@view('timeline')
def timeline():
    return {
        'url': '/api'+api.app.get_url('/events')
    }

@app.route('/play')
@view('play')
def timeline():
    # Use the GNU flash flowplayer: http://flowplayer.org/
    return {}

@app.route('/static/<filename:path>')
def send_static(filename):
    return static_file(filename, root='static')
