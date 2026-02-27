require "./scene_manager"

module JR
  class Game < GSDL::Game
    def initialize
      super(title: "JR", width: 800, height: 640)
    end

    def init
      super

      @scene_manager = SceneManager.new
    end

    def load_fonts
      GSDL::FontManager.load_default("fonts/PressStart2P.ttf")
    end

    def load_textures
      GSDL::TextureManager.load("tiles", "gfx/tiles.png")
      GSDL::TextureManager.load("player", "gfx/player.png")
    end

    def load_tile_maps
      GSDL::TileMapManager.load("map", "gfx/map.json")
    end
  end
end
