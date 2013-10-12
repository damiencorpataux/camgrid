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
    pattern = c['motion']['movie_filename']
    files = []
    return pattern

@app.route('/meta/<file:path>')
def get_meta(file):
    file = '/' + file
    if (not os.path.isfile(file)): abort(404, 'File %s does not exist' % file)
    cmd = 'avprobe "%s" 2>&1' % (file)
    output = subprocess.check_output(cmd, shell=True)
    m = re.findall('encoder.*: (.*?)\n.*Duration: (.*?),.*bitrate: (.*)\n.*Video: (.*?), (.*?), (.*)x(.*?) .*DAR (.*?)], (.*?) fps', output, re.MULTILINE)
    encoder, duration, bitrate, encoding, palette, width, height, aspect, fps = m.pop()
    h, m, s, c = re.findall('(\d{2}):(\d{2}):(\d{2})\.(\d{2})', duration).pop()
    duration = int(h)*3600 + int(m)*60 + int(s) + float(c)/100
    preview = app.get_url('/preview/<file:path>', file=file)
    return {
        'duration': duration,
        'resolution': '%sx%s' % (width, height),
        'width': width,
        'height': height,
        'fps': fps,
        'aspect': aspect,
        'encoding': encoding,
        'encoder': encoder,
        'bitrate': bitrate,
        'palette': palette,
        'raw': output,
        'preview': preview
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


def parse_motion_conf():
    match = re.compile("^(target_dir|movie_filename|jpeg_filename) (.*)$").match
    with open(c['motionconf'], 'r') as file:
        conf = {m.group(1):m.group(2) for m in [match(l) for l in file] if m}
    c['motion'] = conf


parse_motion_conf()

# Server instance
run(app, host='0.0.0.0', port=8000, reloader=True)
