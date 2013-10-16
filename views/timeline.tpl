<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Camgrid &middot; Timeline</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="http://code.jquery.com/ui/1.10.1/themes/base/jquery-ui.css" rel="stylesheet">
    <link href="//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.2/css/bootstrap-combined.min.css" rel="stylesheet">

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

      <style>
        #list {
            background-color: lightgray;
            margin: 1px;
        }
        #list img {
            height: 48px;
            padding: 2px;
            margin: 2px;
            border: 1px solid gray;
            background-color: white;
            margin-right: 10px;
        }
      </style>
      <div id="list"></div>

      <script>
        $(document).ready(function() {
            $.getJSON('{{url}}', {
                dummydata: null
            }).done(function(json) {
                draw(json.events.slice(0,10));
            });
        });
        function draw(events) {
            $.each(events, function(i, event) {
                $('#list').prepend(
                    $('<div/>', {
                        'text': event.date
                    }).prepend([
                        $('<img/>', {
                            src: '/api'+event.preview
                        })
                    ])
                );
            });
        }
      </script>
    <script type="text/javascript" src="//cdn.jsdelivr.net/colorbox/1.4.4/jquery.colorbox-min.js"></script>
    <link href="//cdnjs.cloudflare.com/ajax/libs/jquery.colorbox/1.4.3/example1/colorbox.css" rel="stylesheet">
  <body>
</html>
