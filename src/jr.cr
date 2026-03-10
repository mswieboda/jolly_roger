require "game_sdl"

require "./jr/character"
require "./jr/static_entity"
require "./jr/objs/*"
require "./jr/warp"
require "./jr/player"
require "./jr/npc"
require "./jr/action_parser"
require "./jr/ui/*"
require "./jr/game"

module JR
  alias Color = GSDL::Color
  alias Input = GSDL::Input
  alias Keys = GSDL::Keys
  alias Mouse = GSDL::Mouse
  alias Num = GSDL::Num

  Game.new.run
end
