<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Camgrid &middot; Live</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">

    <!-- Le styles -->
    <!-- TODO: Upgrade to bootstrap 3
      <link href="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css" rel="stylesheet">
    -->
    <link href="http://code.jquery.com/ui/1.10.1/themes/base/jquery-ui.css" rel="stylesheet">
    <link href="//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.2/css/bootstrap-combined.min.css" rel="stylesheet">
    <!-- <link type="text/css" rel="stylesheet" href="//cdn.jsdelivr.net/fullcalendar/1.5.4/fullcalendar.css"/>
    <link type="text/css" rel="stylesheet" href="//cdn.jsdelivr.net/fullcalendar/1.5.4/fullcalendar.print.css" media="print" /> -->

    <!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
    <!--[if lt IE 9]>
      <script src="//netdna.bootstrapcdn.com/html5shiv/3.6.1/html5shiv.js"></script>
    <![endif]-->

    <!-- Le unavoidable scripts -->
    <!-- jQuery -->
    <script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
    <script src="http://code.jquery.com/ui/1.10.1/jquery-ui.js"></script>
    <script src="//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.2/js/bootstrap.min.js"></script>
    <!-- Bootstrap -->
    <!-- TODO: Upgrade to bootstrap 3
      <script src="//netdna.bootstrapcdn.com/bootstrap/3.0.0/js/bootstrap.min.js"></script>
    -->

    <!-- Fav and touch icons -->
    <link rel="apple-touch-icon-precomposed" sizes="144x144" href="../assets/ico/apple-touch-icon-144-precomposed.png">
    <link rel="apple-touch-icon-precomposed" sizes="114x114" href="../assets/ico/apple-touch-icon-114-precomposed.png">
    <link rel="apple-touch-icon-precomposed" sizes="72x72" href="../assets/ico/apple-touch-icon-72-precomposed.png">
    <link rel="apple-touch-icon-precomposed" href="../assets/ico/apple-touch-icon-57-precomposed.png">
    <link rel="shortcut icon" href="../assets/ico/favicon.png">

    <style type="text/css">
      .container {
        /* FIXME: is it a good practice ? */
        width: 98%;
      }
      #streams img {
        height: 240px;
        margin: 1px;
      }
    </style>
  </head>

  <body>

    <div class="container">

      <div class="masthead">
        <ul class="nav nav-pills pull-right">
          <li class="active"><a href="/">Live</a></li>
          <li><a href="/calendar">Calendar</a></li>
          <li><a href="/timeline">Timeline</a></li>
        </ul>
        <h2>
          Camgrid
        </h2>
      </div>

      <hr>

      <form action="#">
        <div class="input-append"> 
          <input type="text" name="url" class="span8" placeholder="Stream URL, eg. http://pswebcam.bbhlabs.com:19910/mjpg/video.mjpg" value="http://pswebcam.bbhlabs.com:19910/mjpg/video.mjpg">
          <button class="btn">Add</button>
        </div>
        <a class="action-remove-streams" href="#">Remove all streams</a>
      </form>
      <div id="streams" class="gridly">
      </div>

    </div>

    <script>
      function list() {
          return $('#streams img').map(function() {
              return $(this).attr('src');
          }).get();
      }
      function add(url) {
          // Prevents adding duplicate URLs
          var urls = list();
          if ($(urls).filter([url]).length) {
              $.bootstrapGrowl("This stream has already been added", {
                  type: 'info',
                  align: 'center'
              });
              return;
          }
              // Saves url to streams list cookie
              // TODO: Refactor: there is the "session" object that handles
              // view parameters storage and retrieval
              // TODO: simply store list().append(url) ?
              //       and make list() return cookie contents ?
              var sep = ' ';
              var streams = $.cookie('streams');
              streams = streams ? streams.split(sep) : [];
              streams.unshift(url);
              $.cookie('streams', streams.join(sep), {expires:365});
          // Creates and appends <img> tag
          var a = $('<a/>', {
              href: url,
              // FIXME: lighter plugin doesn't work with hrefs not ending in .jpg|jpeg|png|...
              "data-lighter": true
          });
          var img = $('<img/>', {
              src: url,
              load: function() { 
                  // Relayouts gridly
                  // TODO: Refactor: these is the "layout" object that handles
                  // high-level layout related stuff (such as sizing, dragging, etc.)
                  //$('.gridly').gridly('layout');
                  $('#streams').shapeshift();
                  // Restores resizable
                  /* Buggy with shapeshift
                  $('#streams img').resizable({
                      //alsoResize: '#streams img',
                      //aspectRatio: 16/9,
                      stop: function() {
                          $('#streams').shapeshift();
                      }
                  });
                  */
              },
              error: function() {
                  // Notifies user
                  // TODO: Add a 'remove (stream)' link in message
                  $.bootstrapGrowl("We cannot load this stream", {
                      type: 'error',
                      align: 'center',
                      width: 'auto'
                  });
                  // Removes created DOM element
                  $(this).remove();
              }
          });
          $('#streams').append(a.append(img));
      }
      function remove(url) {
          // Removes from stream list cookie
          var streams = $(list()).map(function(i, u) {
              if (u !== url) return u;
          }).get();
          $.cookie('streams', streams.join(' '));
          // Removes img tag
          $('#streams img[src="'+url+'"]').remove();
      }
      $(document).ready(function() {
          // Autofocuses on form  input
          $('input:first').focus();

          // Handles 'add stream' action
          $('form').on('submit', function() {
              var url = $('input', this).val();
              add(url);
              return false;
          });
          // Handles remove all streams
          $('.action-remove-streams').on('click', function() {
              $.each(list(), function(i, url) {
                  remove(url);
              });
          });

          // Restores streams list on pageload (from cookie)
          var streams = $.cookie('streams');
          streams = streams ? streams.split(' ') : [];
          $.removeCookie('streams'); // Prevents add() duplicate detection
          $.each(streams, function(i, url) {
              add(url);
          });

          // Setups gridly on stream images list
          /*
          $('#streams').gridly({
              base: 60, // px 
              gutter: 5, // px
              //columns: 4
          });
          */

          // Setups shapeshiftable streams (masonry-like)
          // FIXME: Not needed because called on every stream addition
          //$('.gridly').shapeshift({ minColumns:3 });

          /*
          // Setups resizable streams
          // FIXME: Not needed because called on every stream addition
          $('#streams img').resizable({
              //alsoResize: '#streams img',
              //aspectRatio: 16/9;
          });
          */
      });
    </script>

    <!-- Lighter -->
    <script src="/static/js/jquery.lighter.js" type="text/javascript"></script>
    <link href="http://ksylvest.github.io/jquery-lighter/stylesheets/jquery.lighter.css" rel="stylesheet" type="text/css" />
    <!-- BootstrapGrowl -->
    <script src="//cdnjs.cloudflare.com/ajax/libs/bootstrap-growl/1.0.0/jquery.bootstrap-growl.min.js" type="text/javascript"></script>
    <!-- Cookie -->
    <script src="//cdn.jsdelivr.net/jquery.cookie/1.3.1/jquery.cookie.js" type="text/javascript"></script>
    <!-- Gridly -->
    <script src="http://ksylvest.github.io/jquery-gridly/javascripts/jquery.gridly.js" type="text/javascript"></script>
    <link href="http://ksylvest.github.io/jquery-gridly/stylesheets/jquery.gridly.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
      .gridly { position: relative; width:100% }
      .gridly > img { position: absolute }
    </style>
    <!-- Shapeshifr -->
    <script src="//cdnjs.cloudflare.com/ajax/libs/jquery.shapeshift/2.0/jquery.shapeshift.min.js" type="text/javascript"></script>
    <style type="text/css">
      .gridly {
        position: relative;
        width: 95%;
      }
      .gridly > * {
        display: block;
        position: absolute;
      }
    </style>
  <body>
</html>
