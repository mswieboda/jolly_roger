module JR
  class Ship < GSDL::AnimatedSprite
    include GSDL::TileMapCollidable

    enum SpeedState
      None
      Low
      Half
      Full

      def multiplier : Float32
        case self
        when None then 0.0_f32
        when Low  then 0.33_f32
        when Half then 0.66_f32
        when Full then 1.0_f32
        else           0.0_f32
        end
      end
    end

    # Static property to disable/enable movement controls
    property? static : Bool = true

    # Ship heading in degrees (0 is North)
    property heading : Float32 = 0.0_f32

    # Rotation speed (degrees per second)
    property rotation_speed : Float32 = 180.0_f32

    # Movement speed
    property move_speed : Float32 = 128.0_f32

    # Current speed state
    property speed_state : SpeedState = SpeedState::None

    # Current actual speed multiplier for interpolation
    property current_speed_multiplier : Float32 = 0.0_f32

    # How fast the ship accelerates (multiplier units per second)
    property acceleration : Float32 = 0.5_f32

    # How fast the ship decelerates (multiplier units per second)
    property deceleration : Float32 = 0.25_f32

    # How fast the ship decelerates when anchor is dropped
    property anchor_deceleration : Float32 = 0.75_f32

    # Timer for the anchor "catch" effect
    getter anchor_timer : GSDL::Timer

    # Event flag for when the anchor catches
    property? just_anchored : Bool = false

    # Movement deltas for animation logic
    property dx : Float32 = 0.0_f32
    property dy : Float32 = 0.0_f32

    getter? flip_left : Bool = false
    property direction : GSDL::Direction = GSDL::Direction::Up

    def initialize
      # Each frame is 512x512 based on the ship-overworld-north.png texture
      super(key: "ship-overworld-north", width: 512, height: 512)

      # Scale down for overworld
      @scale = {0.5_f32, 0.5_f32}
      @origin = {0.5_f32, 0.5_f32}
      @z_index = 3

      # used in TileMapCollidable
      @use_gravity = false

      # Setup a single "idle" animation for the static sprite
      add("idle", [0], fps: 1, loops: true)

      @heading = 0.0_f32
      @direction = GSDL::Direction::Up
      @anchor_timer = GSDL::Timer.new(0.5.seconds)
      play("idle")
    end

    def moving? : Bool
      dx != 0 || dy != 0
    end

    def update(dt : Float32, tile_map : GSDL::TileMap, collidables : Array(GSDL::Collidable))
      unless static?
        handle_speed_input
        handle_rotation(dt)
        handle_movement(dt, tile_map, collidables)
      end

      update_animations
      super(dt)
    end

    private def handle_speed_input
      if GSDL::Input.action?(:speed_up)
        case @speed_state
        when .none? then @speed_state = SpeedState::Low
        when .low?  then @speed_state = SpeedState::Half
        when .half? then @speed_state = SpeedState::Full
        end
      end

      if GSDL::Input.action?(:speed_down)
        case @speed_state
        when .full? then @speed_state = SpeedState::Half
        when .half? then @speed_state = SpeedState::Low
        when .low?
          @speed_state = SpeedState::None
          @anchor_timer.restart
        end
      end
    end

    private def handle_rotation(dt : Float32)
      # Direct key checks to be sure
      if GSDL::Input.action?(:move_left) || GSDL::Keys.pressed?(GSDL::Keys::A)
        @heading -= rotation_speed * dt
      end
      if GSDL::Input.action?(:move_right) || GSDL::Keys.pressed?(GSDL::Keys::D)
        @heading += rotation_speed * dt
      end

      @heading %= 360.0_f32
      @heading += 360.0_f32 if @heading < 0

      update_direction_from_heading
    end

    private def handle_movement(dt : Float32, tile_map : GSDL::TileMap, collidables : Array(GSDL::Collidable))
      target_multiplier = speed_state.multiplier

      # Interpolate current_speed_multiplier towards target_multiplier
      if @current_speed_multiplier < target_multiplier
        @current_speed_multiplier += acceleration * dt
        @current_speed_multiplier = target_multiplier if @current_speed_multiplier > target_multiplier
      elsif @current_speed_multiplier > target_multiplier
        # Use aggressive deceleration if anchor is dropped (speed_state is None)
        rate = speed_state.none? ? anchor_deceleration : deceleration
        @current_speed_multiplier -= rate * dt
        
        # Hard stop when anchor timer finishes
        if speed_state.none? && @anchor_timer.done? && @current_speed_multiplier > 0
          @current_speed_multiplier = 0.0_f32
          @just_anchored = true
        end

        @current_speed_multiplier = target_multiplier if @current_speed_multiplier < target_multiplier
      end

      if @current_speed_multiplier > 0
        # 0 heading is North (-Y)
        rad = (heading - 90.0_f32) * (Math::PI / 180.0_f32)
        @dx = Math.cos(rad).to_f32 * @current_speed_multiplier
        @dy = Math.sin(rad).to_f32 * @current_speed_multiplier

        speed = move_speed * dt

        # Simple move and collide
        prev_x = x
        self.x += dx * speed
        if collides_with_anything?(collidables, tile_map)
          self.x = prev_x
          # Stop ship completely on collision
          @current_speed_multiplier = 0.0_f32
          @speed_state = SpeedState::None
        end

        prev_y = y
        self.y += dy * speed
        if collides_with_anything?(collidables, tile_map)
          self.y = prev_y
          # Stop ship completely on collision
          @current_speed_multiplier = 0.0_f32
          @speed_state = SpeedState::None
        end
      else
        @dx = 0.0_f32
        @dy = 0.0_f32
      end
    end

    private def collides_with_anything?(collidables : Array(GSDL::Collidable), tile_map : GSDL::TileMap?) : Bool
      return true if collidables.any? { |c| c != self && collides?(c) }

      if tm = tile_map
        # Use small collision box for boat hull
        box = collision_bounding_box
        return true if tm.solid_up?(draw_x + box.x, draw_y + box.y, box.w, box.h)
      end

      false
    end

    private def update_direction_from_heading
      h = @heading
      
      # Natural rotation - just use the heading directly
      self.rotation = h.to_f32

      # Flipping logic: Flip for the entire West side (180 to 360 degrees).
      @flip_left = (h >= 180.0 && h < 360.0)

      # Maintain @direction for completeness, although animations are unified now
      if h < 22.5 || h >= 337.5
        @direction = GSDL::Direction::Up
      elsif h < 67.5
        @direction = GSDL::Direction::UpRight
      elsif h < 112.5
        @direction = GSDL::Direction::Right
      elsif h < 157.5
        @direction = GSDL::Direction::DownRight
      elsif h < 202.5
        @direction = GSDL::Direction::Down
      elsif h < 247.5
        @direction = GSDL::Direction::DownLeft
      elsif h < 292.5
        @direction = GSDL::Direction::Left
      else
        @direction = GSDL::Direction::UpLeft
      end
    end

    def update_animations
      # Unified animation for natural rotation
      play("idle") unless playing?("idle")
    end

    def draw(draw : GSDL::Draw, camera : GSDL::Camera? = nil, flip_horizontal : Bool = false)
      super(
        draw: draw,
        camera: camera,
        flip_horizontal: flip_horizontal || flip_left?
      )

      draw_sails(draw, camera)
    end

    private def draw_sails(draw : GSDL::Draw, camera : GSDL::Camera? = nil)
      return if speed_state.none?

      # Placeholder sails: simple bars indicating speed level
      num_bars = case speed_state
                 when .low? then 1
                 when .half? then 2
                 when .full? then 3
                 else 0
                 end

      cam_x = camera.try(&.x) || 0
      cam_y = camera.try(&.y) || 0

      # Draw simple bars for sails placeholder above the ship
      num_bars.times do |i|
        draw.rect_fill(
          rect: GSDL::FRect.new(
            x: (draw_x - cam_x) + (draw_width / 2) - 15 + (i * 12),
            y: (draw_y - cam_y) + (draw_height / 2) - 100,
            w: 8,
            h: 30
          ),
          color: GSDL::Color::White,
          z_index: @z_index + 1
        )
      end
    end

    def collision_bounding_box : GSDL::FRect
      # Scaled box for overworld (128x128 canvas, so hull is small)
      GSDL::FRect.new(x: 192 * scale_x, y: 192 * scale_y, w: draw_width - 384 * scale_x, h: draw_height - 384 * scale_y)
    end
  end
end
