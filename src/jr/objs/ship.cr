module JR
  class Ship < GSDL::AnimatedSprite
    include GSDL::TileMapCollidable

    # Static property to disable/enable movement controls
    property? static : Bool = true

    # Ship heading in degrees (0 is North)
    property heading : Float32 = 0.0_f32

    # Rotation speed (degrees per second)
    property rotation_speed : Float32 = 180.0_f32

    # Movement speed
    property move_speed : Float32 = 128.0_f32

    # Movement deltas for animation logic
    property dx : Float32 = 0.0_f32
    property dy : Float32 = 0.0_f32

    getter? flip_left : Bool = false
    property? debug : Bool = false
    property direction : GSDL::Direction = GSDL::Direction::Up

    def initialize
      # Each frame is 512x512 based on the 2560x512 texture width
      super(key: "ship-overworld", width: 512, height: 512)

      # Scale down for overworld
      @scale = {0.25_f32, 0.25_f32}
      @origin = {0.5_f32, 0.5_f32}
      @z_index = 3

      # used in TileMapCollidable
      @use_gravity = false

      # Directional frames: 0:N, 1:NE, 2:E, 3:SE, 4:S
      fps = 4

      # Setup animations for each cardinal/ordinal direction
      add("up", [0], fps: fps, loops: false)
      add("up-right", [1], fps: fps, loops: false)
      add("right", [2], fps: fps, loops: false)
      add("down-right", [3], fps: fps, loops: false)
      add("down", [4], fps: fps, loops: false)

      # Sailing animations (same frames for now)
      add("walk-up", [0], fps: fps, loops: true)
      add("walk-up-right", [1], fps: fps, loops: true)
      add("walk-right", [2], fps: fps, loops: true)
      add("walk-down-right", [3], fps: fps, loops: true)
      add("walk-down", [4], fps: fps, loops: true)

      @heading = 0.0_f32
      @direction = GSDL::Direction::Up
      play("up")
    end

    def moving? : Bool
      dx != 0 || dy != 0
    end

    def update(dt : Float32, tile_map : GSDL::TileMap, collidables : Array(GSDL::Collidable))
      unless static?
        handle_rotation(dt)
        handle_movement(dt, tile_map, collidables)
      end

      update_animations
      super(dt)
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
      thrust = 0.0_f32
      thrust += 1.0_f32 if GSDL::Input.action?(:move_up) || GSDL::Keys.pressed?(GSDL::Keys::W)
      thrust -= 0.5_f32 if GSDL::Input.action?(:move_down) || GSDL::Keys.pressed?(GSDL::Keys::S)

      if thrust != 0
        # 0 heading is North (-Y)
        rad = (heading - 90.0_f32) * (Math::PI / 180.0_f32)
        @dx = Math.cos(rad).to_f32 * thrust
        @dy = Math.sin(rad).to_f32 * thrust

        speed = move_speed * dt

        # Simple move and collide
        prev_x = x
        self.x += dx * speed
        if collides_with_anything?(collidables, tile_map)
          self.x = prev_x
        end

        prev_y = y
        self.y += dy * speed
        if collides_with_anything?(collidables, tile_map)
          self.y = prev_y
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
      prefix = moving? ? "walk" : "idle"
      # map "idle" to the single frame cardinal animations
      prefix = "" if prefix == "idle"

      anim_base = case direction
                  when .up?         then "up"
                  when .up_right?   then "up-right"
                  when .right?      then "right"
                  when .down_right? then "down-right"
                  when .down?       then "down"
                  when .down_left?  then "down-right" # Mirror
                  when .left?       then "right"      # Mirror
                  when .up_left?    then "up-right"   # Mirror
                  else "up"
                  end

      anim = prefix.empty? ? anim_base : "#{prefix}-#{anim_base}"

      play(anim) if paused? || !playing?(anim)

      @flip_left = direction.left? || direction.up_left? || direction.down_left?
    end

    def draw(draw : GSDL::Draw, camera : GSDL::Camera? = nil, flip_horizontal : Bool = false)
      super(
        draw: draw,
        camera: camera,
        flip_horizontal: flip_horizontal || flip_left?
      )

      draw_debug(draw: draw, camera: camera) if debug?
    end

    def draw_debug(draw : GSDL::Draw, camera : GSDL::Camera? = nil)
      rect = self.collision_box
      draw.rect_outline(
        rect: GSDL::FRect.new(
          x: rect.x - (camera.try(&.x) || 0),
          y: rect.y - (camera.try(&.y) || 0),
          w: rect.w,
          h: rect.h
        ),
        color: GSDL::Color::Lime,
        z_index: 100
      )
    end

    def collision_bounding_box : GSDL::FRect
      # Scaled box for overworld (128x128 canvas, so hull is small)
      GSDL::FRect.new(x: 192 * scale_x, y: 192 * scale_y, w: draw_width - 384 * scale_x, h: draw_height - 384 * scale_y)
    end
  end
end
