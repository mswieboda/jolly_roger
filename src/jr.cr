require "game_sdl"

require "./jr/player"
require "./jr/game"

module JR
  alias Keys = GSDL::Keys

  Game.new.run
end
