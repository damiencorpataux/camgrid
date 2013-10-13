import bottle
from bottle import Bottle, run, debug
from bottle import route, request, response, abort, error
from bottle import view, template
from bottle import static_file

from api import api

import os, subprocess
import re, time
from glob import glob

app = Bottle()
app.mount("/api", api.app)

bottle.TEMPLATES.clear()

@app.route('/')
@app.route('/live')
@view('live')
def home():
    return

@app.route('/calendar')
@view('calendar')
def calendar():
    return {
        'calendarurl': api.get_url('/api/events')
    }

@app.route('/timeline')
@view('timeline')
def timeline():
    return {
        'url': api.app.get_url('/api/events')
    }

@app.route('/static/<filename:path>')
def send_static(filename):
    return static_file(filename, root='static')
