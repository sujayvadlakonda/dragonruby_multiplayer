# HTTP SOUNDBOARD CLIENT
# Inputs sends GET to 3000:/
# Get sounds plays :response_data if HTTP CODE is 200

def tick args
  defaults args
  render args
  inputs args
  get_sounds(args) if args.state.tick_count.mod_zero? 10
end

def defaults args
  args.state.port ||= 3001
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
  args.outputs.labels << [args.grid.center.x, 10.from_top, 'This is the CLIENT', 20, 1]
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

def get_sounds args
  args.state.download ||= $gtk.http_get 'http://localhost:3000/get_note'

  if args.state.download[:complete]
    if args.state.download[:http_response_code] == 200
      args.outputs.sounds << "sounds/#{args.state.download[:response_data]}.wav"
    end
    args.state.download = nil
  end
end
