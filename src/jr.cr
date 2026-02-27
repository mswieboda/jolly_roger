require "game_sdl"

require "./jr/character"
require "./jr/player"
require "./jr/npc"
require "./jr/action_parser"
require "./jr/dialog_manager"
require "./jr/game"

module JR
  alias Input = GSDL::Input
  alias Keys = GSDL::Keys
  alias Num = GSDL::Num

  Game.new.run
end
