require "./scene_manager"

module JR
  class Game < GSDL::Game
    def initialize
      super(title: "JR", width: 800, height: 640)
    end

    def init
      setup_input
      @scene_manager = SceneManager.new
    end

    def setup_input
      Input.set(:up) { Keys.pressed?([Keys::W, Keys::Up]) }
      Input.set(:left) { Keys.pressed?([Keys::A, Keys::Left]) }
      Input.set(:down) { Keys.pressed?([Keys::S, Keys::Down]) }
      Input.set(:right) { Keys.pressed?([Keys::D, Keys::Right]) }
      Input.set(:move_up) { Keys.pressed?([Keys::W, Keys::Up]) }
      Input.set(:move_left) { Keys.pressed?([Keys::A, Keys::Left]) }
      Input.set(:move_down) { Keys.pressed?([Keys::S, Keys::Down]) }
      Input.set(:move_right) { Keys.pressed?([Keys::D, Keys::Right]) }
      Input.set(:run) { Keys.pressed?([Keys::LShift, Keys::RShift]) }
      Input.set(:action) { Keys.just_pressed?([Keys::Return, Keys::Space, Keys::E]) }
      Input.set(:menu) { Keys.just_pressed?([Keys::Escape]) }
      Input.set(:menu_up) { Keys.just_pressed?([Keys::W, Keys::Up]) }
      Input.set(:menu_down) { Keys.just_pressed?([Keys::S, Keys::Down]) }
      Input.set(:menu_select) { Keys.just_pressed?([Keys::Return, Keys::Space, Keys::E]) }

      {% unless flag?(:release) %}
        Input.set(:debug) { Keys.just_pressed?(Keys::Tab) }
      {% end %}
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
        {"ship-overworld", "gfx/objs/ship-overworld.png"},
      ]
    end

    def load_tile_maps
      [
        {"island", "data/maps/island.json"},
        {"sea", "data/maps/sea.json"},
      ]
    end
  end
end
