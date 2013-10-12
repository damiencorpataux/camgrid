from bottle import Bottle, run, response, abort
from glob import glob
import os, re, subprocess

app = Bottle()

c = config = {
    'filespath': '/home/damien/motion-storage',
    'motionconf': '/etc/motion/motion.conf',
    'motion': {}
}

@app.route('/')
@app.route('/config')
def get_config():
    return c

@app.route('/events')
def get_events():
    path = c['motion']['target_dir']+'/*/*.avi'
    files = glob(path)
    return {
        'path': path,
        'count': len(files),
        'files': files,
    }

@app.route('/events/meta/<file:path>')
def get_meta():
    return {}

@app.route('/preview/<file:path>')
@app.route('/preview/<file:path>/<time:int>')
@app.route('/preview/<file:path>/<time:int>/<size>')
def get_preview(file, time=0, size='160x120'):
    file = '/' + file
    if (not os.path.isfile(file)): abort(404, 'File %s does not exist' % file)
    cmd = 'ffmpeg -i "%s" -vframes 1 -an -f image2 -s %s -ss %s - 2>/dev/null' % (file, size, time)
    response.content_type = 'image/jpeg'
    return subprocess.check_output(cmd, shell=True)

def parse_motion_conf():
    match = re.compile("^(target_dir|movie_filename|jpeg_filename) (.*)$").match
    with open(c['motionconf'], 'r') as file:
        conf = {m.group(1):m.group(2) for m in [match(l) for l in file] if m}
    c['motion'] = conf


parse_motion_conf()

# Server instance
run(app, host='0.0.0.0', port=8000, reloader=True)
