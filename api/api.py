import bottle
from bottle import Bottle, run, debug
from bottle import route, request, response, abort, error
from bottle import view, template
from bottle import static_file

import os, subprocess
import re, time
from glob import glob

# FIXME: Create a dedicated bottle app named 'api'
#        and mount it in the 'viewer' app
#        http://stackoverflow.com/questions/11180806/

# FIXME: API response must be streamed (yielding results)
#        cf. stream() test

app = Bottle()

c = config = {
    'filespath': '/home/damien/motion-storage',
    'motionconf': '/etc/motion/motion.conf',
    'motion': {}
}

# Testing json streaming
# Streaming while parsing files could be a nice thing:
# http://stackoverflow.com/questions/18994371/imitating-twitters-streaming-api
@app.route('/stream')
def stream():
    import json
    for i in range(5):
        yield json.dumps([{'count':i}]) + "\n"
        #yield {'count':i} # Unsupported response type: <type 'dict'>
        time.sleep(1)

@app.route('/')
@app.route('/live')
@view('live')
def home():
    return

@app.route('/calendar')
@view('calendar')
def events():
    return {
        'calendarurl': app.get_url('/events')
    }

@app.route('/static/<filename:path>')
def send_static(filename):
    return static_file(filename, root='static')

@app.route('/config')
def get_config():
    return c

@app.route('/files')
@app.route('/files/<filter>')
def get_files(filter='.*(avi|mpg|jpg)$'):
    #path = c['motion']['target_dir']+'/*/*.avi'
    #files = glob(path)
    path = c['motion']['target_dir']
    cmd = 'find %s -regextype posix-extended -regex "%s"' % (path, filter)
    files = subprocess.check_output(cmd, shell=True).split('\n')
    return {
        'path': path,
        'filter': filter,
        'count': len(files),
        'files': files,
    }

@app.route('/events')
def get_events():
    # Globs files matching filter (filter is TODO)
    motion_pattern = c['motion']['movie_filename']
    pattern = re.sub('%.', '*', motion_pattern)
    path = c['motion']['target_dir'] + '/' + pattern + '*'
    files = glob(path)
    # Extracts info from filenames
    keys = re.findall('%(.)', motion_pattern)
    pattern = re.sub('\\\%.', '(.*?)', re.escape(motion_pattern))
    r = re.compile(pattern).findall
    data = []
    for file in files:
        i = dict(zip(keys, r(file).pop()))
        timestamp = time.mktime(time.strptime(
            '%(Y)s-%(m)s-%(d)s %(H)s:%(M)s:%(S)s' % i,
            "%Y-%m-%d %H:%M:%S"
        ))
        data.append({
            'file': file,
            'text': i['C'],
            'timestamp': timestamp,
            'date': time.ctime(timestamp),
            'event': i['v'],
            'thread': i['t'],
            'preview': app.get_url('/preview/<file:path>', file=file),
            'play': app.get_url('/play/<file:path>', file=file),
            #'meta': get_meta(file),
            #'info': i,
        })
    # Returns data structure
    return {
        'count': len(files),
        'events': data
    }

@app.route('/meta/<file:path>')
def get_meta(file):
    file = os.path.join('/', file)
    if (not os.path.isfile(file)): abort(404, 'File %s does not exist' % file)
    cmd = 'avprobe "%s" 2>&1' % (file)
    output = subprocess.check_output(cmd, shell=True)
    m = re.findall('encoder.*: (.*?)\n.*Duration: (.*?),.*bitrate: (.*)\n.*Video: (.*?), (.*?), (.*?)x(.*?), (.*?) fps', output, re.MULTILINE)
    if not m: raise Exception('File metadata parsing failed (%s)' % file)
    encoder, duration, bitrate, encoding, palette, width, height, fps = m.pop()
    h, m, s, c = re.findall('(\d{2}):(\d{2}):(\d{2})\.(\d{2})', duration).pop()
    duration = int(h)*3600 + int(m)*60 + int(s) + float(c)/100
    return {
        'duration': duration,
        'resolution': '%sx%s' % (width, height),
        'width': width,
        'height': height,
        'fps': fps,
        'encoding': encoding,
        'encoder': encoder,
        'bitrate': bitrate,
        'palette': palette,
        'raw': output,
    }

@app.route('/preview/<file:path>')
@app.route('/preview/<file:path>/<time:int>')
@app.route('/preview/<file:path>/<time:int>/<size>')
def get_preview(file, time=0, size='160x120'):
    file = '/' + file
    if (not os.path.isfile(file)): abort(404, 'File %s does not exist' % file)
    cmd = 'avconv -loglevel error -i "%s" -vframes 1 -an -f image2 -s %s -ss %s -' % (file, size, time)
    response.content_type = 'image/jpeg'
    return subprocess.check_output(cmd, shell=True)

# FIXME: Use a flash play in client side?
@app.route('/play/<file:path>')
def get_play(file):
    response.content_type = 'application/octet-stream'
    file = open(file, 'rb')
    while 1:
        chunk = file.read(4096)
        if not chunk: break
        yield chunk

def parse_motion_conf():
    match = re.compile("^(target_dir|movie_filename|jpeg_filename) (.*)$").match
    with open(c['motionconf'], 'r') as file:
        conf = {m.group(1):m.group(2) for m in [match(l) for l in file] if m}
    c['motion'] = conf


parse_motion_conf()

# Server instance
run(app, host='0.0.0.0', port=8000, reloader=True)
