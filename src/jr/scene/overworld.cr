module JR
  class Scene::Overworld < JR::Scene
    getter tile_map : GSDL::TileMap
    getter ship : Ship
    getter camera : GSDL::Camera

    def initialize
      super(:overworld)

      @transition_in = GSDL::FadeTransition.new(
        direction: GSDL::TransitionDirection::In,
        duration: 0.5_f32,
        started: true
      )
      @transition_out = GSDL::FadeTransition.new(
        direction: GSDL::TransitionDirection::Out,
        duration: 0.5_f32
      )

      Input.set(:up) { Keys.pressed?([Keys::W, Keys::Up]) }
      Input.set(:left) { Keys.pressed?([Keys::A, Keys::Left]) }
      Input.set(:down) { Keys.pressed?([Keys::S, Keys::Down]) }
      Input.set(:right) { Keys.pressed?([Keys::D, Keys::Right]) }
      Input.set(:move_up) { Keys.pressed?([Keys::W, Keys::Up]) }
      Input.set(:move_left) { Keys.pressed?([Keys::A, Keys::Left]) }
      Input.set(:move_down) { Keys.pressed?([Keys::S, Keys::Down]) }
      Input.set(:move_right) { Keys.pressed?([Keys::D, Keys::Right]) }
      Input.set(:speed_up) { Keys.just_pressed?([Keys::W, Keys::Up]) }
      Input.set(:speed_down) { Keys.just_pressed?([Keys::S, Keys::Down]) }
      Input.set(:run) { Keys.pressed?([Keys::LShift, Keys::RShift]) }
      Input.set(:action) { Keys.just_pressed?([Keys::Return, Keys::Space, Keys::E]) }
      Input.set(:menu) { Keys.just_pressed?([Keys::Escape]) }
      Input.set(:menu_up) { Keys.just_pressed?([Keys::W, Keys::Up]) }
      Input.set(:menu_down) { Keys.just_pressed?([Keys::S, Keys::Down]) }
      Input.set(:menu_select) { Keys.just_pressed?([Keys::Return, Keys::Space, Keys::E]) }

      # Use the overworld map
      @tile_map = GSDL::TileMapManager.get("sea")

      @camera = GSDL::Camera.new(width: Game.width, height: Game.height)
      @camera.type = GSDL::Camera::Type::CenterOnTarget

      @ship = Ship.new
      # Center ship in the overworld
      @ship.center(width: @tile_map.map_width_tiles * 32, height: @tile_map.map_height_tiles * 32)

      # Enable ship movement for this scene
      @ship.static = false
    end

    def get_player : Player?
      # In the overworld, the ship IS the player object effectively
      # But the system expects a Player class for warps etc.
      # For now, we return nil or a dummy if needed.
      nil
    end

    def update(dt : Float32)
      super(dt)

      # Update ship with its own movement logic
      @ship.update(dt, tile_map, [] of GSDL::Collidable)

      if @ship.just_anchored?
        @camera.shake(duration: 0.2_f32, intensity: 5.0_f32)
        @ship.just_anchored = false
      end

      # Camera follows ship
      @camera.look_at(@ship.x, @ship.y)
      @camera.update(dt)
    end

    def draw(draw : GSDL::Draw)
      draw.color = Color::DarkBlue
      draw.clear

      tile_map.draw(draw, @camera)
      @ship.draw(draw, @camera)
    end
  end
end
