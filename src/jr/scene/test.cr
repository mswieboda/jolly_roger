module JR
  class Scene::Test < JR::Scene
    getter tile_map : GSDL::TileMap
    getter player : Player
    getter camera : GSDL::Camera
    getter dialog_box : GSDL::DialogBox

    def initialize
      super(:test)

      @transition_in = GSDL::FadeTransition.new(
        direction: GSDL::TransitionDirection::In,
        duration: 0.5_f32,
        started: true
      )
      @transition_out = GSDL::FadeTransition.new(
        direction: GSDL::TransitionDirection::Out,
        duration: 0.5_f32
      )

      @tile_map = GSDL::TileMapManager.get("map")

      @camera = GSDL::Camera.new(width: Game.width, height: Game.height)
      @camera.type = GSDL::Camera::Type::CenterOnTarget

      @player = Player.new
      @player.center(width: Game.width, height: Game.height)

      @dialog_box = GSDL::DialogBox.new
      @dialog_box.on_action { |action| ActionParser.execute(action) }
      @dialog_box.on_condition { |cond| ActionParser.check_condition(cond) }

      # Initialize warp back to start
      warp = Warp.new(
        name: "test_to_start",
        key: "player",
        width: 32,
        height: 32,
        target_scene: "start",
        target_spawn_point: "start_to_test"
      )
      warp.x = 200
      warp.y = 200
      warp.tint = Color::Yellow
      @warps << warp
    end

    def get_player : Player?
      @player
    end

    def update(dt : Float32)
      super(dt)

      if dialog_box.is_active
        dialog_box.update(dt)
      else
        player.update(dt, tile_map, [player.as(GSDL::Collidable)])
        warps.each(&.update(dt))
      end

      # camera follows player
      @camera.look_at(@player.x, @player.y)
      @camera.update(dt)
    end

    def draw(draw : GSDL::Draw)
      # Different background color for test scene
      draw.color = Color::DimGray
      draw.clear

      tile_map.draw(draw, @camera)
      warps.each(&.draw(draw, @camera))
      player.draw(draw, @camera)

      dialog_box.draw(draw)
    end
  end
end
