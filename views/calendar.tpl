<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Camgrid &middot; Calendar</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="http://code.jquery.com/ui/1.10.1/themes/base/jquery-ui.css" rel="stylesheet">
    <link href="//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.2/css/bootstrap-combined.min.css" rel="stylesheet">
    <link type="text/css" rel="stylesheet" href="//cdn.jsdelivr.net/fullcalendar/1.5.4/fullcalendar.css"/>
    <link type="text/css" rel="stylesheet" href="//cdn.jsdelivr.net/fullcalendar/1.5.4/fullcalendar.print.css" media="print" />

    <!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
    <!--[if lt IE 9]>
      <script src="//netdna.bootstrapcdn.com/html5shiv/3.6.1/html5shiv.js"></script>
    <![endif]-->

    <!-- Le unavoidable scripts -->
    <!-- jQuery -->
    <script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
    <script src="http://code.jquery.com/ui/1.10.1/jquery-ui.js"></script>
    <script src="//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.2/js/bootstrap.min.js"></script>

    <style type="text/css">
      .container {
        /* FIXME: is it a good practice ? */
        width: 98%;
      }
      /* FullCalendar customization */
      .fc-header-title h2 {
        /* Smaller timespan title */
        font-size: 14px;
        color: #555;
      }
      .fc-widget-header,
      .fc-agenda-axis.fc-widget-header {
        /* Lighter x and y axis headers */
        color: #777;
      }
      .fc .ui-resizable-handle {
        /* Lighter event resize handles */
        opacity: 0.5;
      }
      .fc-event-skin {
        /* Custom event skin */
        border-color: white;
        background-color: #fa0;
        color: black;
        /* Mouse pointer because uneditable but clickable */
        cursor: pointer;
      }
    </style>
  </head>

  <body>

    <div class="container">

      <div class="masthead">
        <ul class="nav nav-pills pull-right">
          <li class="active"><a href="/">Live</a></li>
        </ul>
        <h2>
          Camgrid
        </h2>
      </div>

      <hr>

      <div id="calendar"></div>

      <script>
        // Actual calendar init
        $(document).ready(function() {
            init_calendar({
                editable: false,
                events: function(start, end, callback) {
                    $.getJSON('{{calendarurl}}', {
                        start: Math.round(start.getTime() / 1000),
                        end: Math.round(end.getTime() / 1000)
                    }).done(function(json) {
                        var colors = {
                            frontdoor: '#fd0',
                            sideway: '#cff',
                            backyard: '#cf0',
                            living: '#ddd',
                        }
                        var events = $.map(json.events, function(e) {
                            e.preview = 'api'+e.preview;
                            return {
                                id: e.file,
                                title: e.text,
                                start: e.timestamp,
                                allDay: false,
                                backgroundColor: colors[e.text.toLowerCase()],
                                preview: e.preview
                            }
                        });
                        callback(events)
                    });
                },
                eventClick: function(event, jsEvent){
                    // Display event detail in UI modal box
                    // Config
                    var resolution = '640x480',
                        interval = 500, //ms
                        step = 1; // seconds
                    // Rendering
                    var size = {
                            w: resolution.split('x')[0],
                            h: resolution.split('y')[1]
                         },
                         i = 0;
                    var img = $('<img/>', {
                        src: [event.preview, '0', resolution].join('/'),
                        style: [
                            'width:'+size.w+'px',
                            'height:'+size.w+'px',
                            'float:left; margin-right:10px'
                        ].join(';'),
                        load: function() {
                            // Rotates preview images
                            setTimeout(function() {
                                var url = [event.preview, i=i+step, resolution].join('/');
                                console.log(url);
                                $(img).attr('src', url);
                            }, 1000);
                        },
                        error: function() {
                            i = 0-step;
                            img.load();
                        },
                        class: 'thumbnail'
                    });
                    $.colorbox({
                        width: '80%',
                        html: img
                    });
                    $.getJSON('/api/meta/'+event.id, {
                        // Params
                    }).done(function(json) {
                        // Defines which json keys to display and it's format
                        var display = {
                            file: event.id, // black sheep
                            duration: '%s seconds',
                            fps: '%s frames/seconds',
                            resolution: '%s',
                            bitrate: '%s',
                            palette: '%s'
                        };
                        // Creates DOM for data
                        var el = $('<dl/>');
                        $.each(display, function(k, v) {
                            $('<dt/>', {
                                text: k,
                                style:'text-transform:capitalize'
                            }).appendTo(el);
                            $('<dd/>', {
                                text: v.replace('%s', json[k]),
                            }).appendTo(el);
                        });
                        $('#cboxLoadedContent').append(el);
                        $.colorbox.resize()
                        // TODO: Creates preview sensor
                        // Use a simple jQuery slider
                    }).fail(function() {
                        console.log('Metadata loading failed');
                    });
                }
            });
        });
        // Calendar init helper
        function init_calendar(options) {
            // Default options
            var options = $.extend({
                height: 800,
                firstDay: 1,
                defaultView: 'agendaWeek',
                axisFormat: 'H:mm',
                slotMinutes: 15,
                timeFormat: {
                    agenda: 'H:mm{ - H:mm}',
                    '': 'H(:mm)'
                },
                allDaySlot: false,
                //slotEventOverlap: false,
                defaultEventMinutes: 15,
                header: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'month,agendaWeek,agendaDay'
                },
                buttonText:{
                    prev:     '&lsaquo;', // <
                    next:     '&rsaquo;', // >
                    prevYear: '&laquo;',  // <<
                    nextYear: '&raquo;',  // >>
                    today:    'today',
                    month:    'month',
                    week:     'week',
                    day:      'day'
                },
                editable: true
            }, options);
            // Actual calendar initialization
            $('#calendar').fullCalendar(options);
            // Calendar to fit window height
            $(window).resize(function() {
                var height = $(window).height() - 100;
                $('#calendar').fullCalendar('option', 'height', height);
            });
            $(window).trigger('resize');
        }
      </script>
    </div>
    <!-- FullCalendar -->
    <script type="text/javascript" src="//cdn.jsdelivr.net/fullcalendar/1.5.4/fullcalendar.min.js"></script>
    <!-- ColorBox -->
    <script type="text/javascript" src="//cdn.jsdelivr.net/colorbox/1.4.4/jquery.colorbox-min.js"></script>
    <link href="//cdnjs.cloudflare.com/ajax/libs/jquery.colorbox/1.4.3/example1/colorbox.css " rel="stylesheet">
  <body>
</html>
