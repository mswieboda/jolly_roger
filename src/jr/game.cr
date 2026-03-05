require "./scene_manager"

module JR
  class Game < GSDL::Game
    def initialize
      super(title: "JR", width: 800, height: 640)
    end

    def init
      @scene_manager = SceneManager.new
    end

    def load_fonts
      [
        {"default", "fonts/PressStart2P.ttf", 16_f32},
      ]
    end

    def load_textures
      [
        {"tiles", "gfx/tiles/land-old.png"},
        {"player", "gfx/chars/player.png"},
      ]
    end

    def load_tile_maps
      [
        {"map", "gfx/maps/map.json"},
      ]
    end
  end
end
