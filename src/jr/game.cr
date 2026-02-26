require "./scene_manager"

module JR
  class Game < GSDL::Game
    def initialize
      super(title: "JR", width: 800, height: 600)
    end

    def init
      super

      @scene_manager = SceneManager.new
    end

    def load_fonts
      GSDL::FontManager.load_default("fonts/PressStart2P.ttf")
    end

    def load_textures
    end
  end
end
