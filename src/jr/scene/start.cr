module JR
  class Scene::Start < GSDL::Scene
    getter tile_map : GSDL::TileMap
    getter player : Player
    getter camera_x : Num = 0
    getter camera_y : Num = 0

    def initialize
      super(:start)

      {% if flag?(:release) %}
        transition_in = GSDL::FadeTransition.new(
          direction: GSDL::TransitionDirection::In,
          duration: 0.75_f32,
          started: true
        )
        transition_out = GSDL::FadeTransition.new(
          direction: GSDL::TransitionDirection::Out,
          duration: 0.5_f32
        )

        super(:start, transition_in: transition_in, transition_out: transition_out)
      {% end %}

      Input.set(:up) { GSDL::Keys.pressed?([GSDL::Keys::W, GSDL::Keys::Up]) }
      Input.set(:left) { GSDL::Keys.pressed?([GSDL::Keys::A, GSDL::Keys::Left]) }
      Input.set(:down) { GSDL::Keys.pressed?([GSDL::Keys::S, GSDL::Keys::Down]) }
      Input.set(:right) { GSDL::Keys.pressed?([GSDL::Keys::D, GSDL::Keys::Right]) }

      {% unless flag?(:release) %}
        Input.set(:debug) { GSDL::Keys.just_pressed?(GSDL::Keys::Tab) }
      {% end %}

      @tile_map = GSDL::TileMapManager.get("map")
      @player = Player.new
    end

    def update(dt : Float32)
      player.update(dt, tile_map)

      if Keys.pressed?(Keys::Escape)
        transition_out.start
      end

      # camera follows player
      @camera_x = player.x - Game.width / 2_f32
      @camera_y = player.y - Game.height / 2_f32
    end

    def draw(draw : GSDL::Draw)
      # TODO: fix these camera params in GSDL to be both Num
      tile_map.draw(draw, camera_x.to_i, camera_y.to_i)
      player.draw(draw, camera_x.to_f32, camera_y.to_f32)
    end
  end
end
