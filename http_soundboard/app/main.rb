# Handling HTTP requests can't be done every 10 ticks cuz
# args.inputs.http_requests changes every tick
# Could try cumulation

# by default the embedded webserver runs on port 9001 (the port number is over 9000) and is disabled in a production build
# to enable the http server in a production build, you need to manually start
# the server up:

# Noticeable latency on server side
# Could convert to a single-octave piano with the .wav files for the flats and sharps
# Could add labels to the notes that exist

def tick args
  defaults args
  render args
  inputs args
  handle_http_requests(args) # if args.state.tick_count.mod_zero? 10
end

def defaults args
  # Run server on port 3000
  args.state.port ||= 3000
  args.gtk.start_server! port: args.state.port, enable_in_prod: true

  # Initialize soundboard
  args.state.soundboard ||= [
    {
      x: args.grid.right / 8 * 0,
      y: args.grid.center.y - 100,
      w: args.grid.right / 8,
      h: 200,
      note: 'C3'
    },
    {
      x: args.grid.right / 8 * 1,
      y: args.grid.center.y - 100,
      w: args.grid.right / 8,
      h: 200,
      note: 'D3'
    },
    {
      x: args.grid.right / 8 * 2,
      y: args.grid.center.y - 100,
      w: args.grid.right / 8,
      h: 200,
      note: 'E3'
    },
    {
      x: args.grid.right / 8 * 3,
      y: args.grid.center.y - 100,
      w: args.grid.right / 8,
      h: 200,
      note: 'F3'
    },
    {
      x: args.grid.right / 8 * 4,
      y: args.grid.center.y - 100,
      w: args.grid.right / 8,
      h: 200,
      note: 'G3'
    },
    {
      x: args.grid.right / 8 * 5,
      y: args.grid.center.y - 100,
      w: args.grid.right / 8,
      h: 200,
      note: 'A3'
    },
    {
      x: args.grid.right / 8 * 6,
      y: args.grid.center.y - 100,
      w: args.grid.right / 8,
      h: 200,
      note: 'B3'
    },
    {
      x: args.grid.right / 8 * 7,
      y: args.grid.center.y - 100,
      w: args.grid.right / 8,
      h: 200,
      note: 'C4'
    },
  ]
end

def render args
  # Identify that this is the server instance
  args.outputs.labels << [args.grid.center.x, 10.from_top, 'This is the SERVER', 20, 1]
  args.outputs.borders << args.state.soundboard # Draw the soundboard
end

def inputs args
  return unless args.inputs.mouse.click # Makes the common case (no click) run fast

  args.state.soundboard.each do | sound_button |
    if args.inputs.mouse.click.inside_rect? sound_button # If a sound button was clicked
      $gtk.http_post 'http://localhost:3000/play_note', {}, ["Note: #{sound_button[:note]}"]
    end
  end
end

def handle_http_requests args
  args.inputs.http_requests.each do | req |
    if req.uri == '/play_note' && req.method == 'POST'
      args.outputs.sounds << "sounds/#{req.headers["Note"]}.wav"
      req.respond 200, req.headers["Note"], {'header' => 'Response from play_note'}
      args.state.note = req.headers["Note"]
    elsif req.uri == '/get_note' && req.method == 'GET'
      req.respond 200, args.state.note, {'header' => 'Response from get_note'}
      args.state.note = nil
    else
      req.reject
    end
  end
end
