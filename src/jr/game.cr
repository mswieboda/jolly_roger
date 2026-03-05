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
        {"beach-grass", "gfx/tiles/beach-grass.png"},
        {"grass-path", "gfx/tiles/grass-path.png"},
        {"water", "gfx/tiles/water.png"},
        {"palm-tree", "gfx/objs/palm-tree.png"},
        {"barrel", "gfx/objs/barrel.png"},
      ]
    end

    def load_tile_maps
      [
        {"map", "data/maps/island.json"},
      ]
    end
  end
end
