require "game_sdl"

require "./jr/player"
require "./jr/game"

module JR
  alias Input = GSDL::Input
  alias Keys = GSDL::Keys
  alias Num = GSDL::Num

  Game.new.run
end
