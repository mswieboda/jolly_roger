module JR
  abstract class Character < GSDL::AnimatedSprite
    include GSDL::TileMapCollidable

    IdleTime = 5.seconds
    Speed = 96

    getter idle_timer : GSDL::Timer
    getter? flip_left
    property? debug = false

    def initialize(key : String, width : Int32, height : Int32)
      super(key: key, width: width, height: height)

      # used in TileMapCollidable
      @use_gravity = false

      # for flipping the texture horizontally from last movement direction
      @flip_left = false

      @idle_timer = GSDL::Timer.new(IdleTime)
      @idle_timer.start

      # animations
      fps = 4
      fps_walk = 8
      add("up", [0], fps: fps, loops: false)
      add("up-right", [1], fps: fps, loops: false)
      add("right", [2], fps: fps, loops: false)
      add("down-right", [3], fps: fps, loops: false)
      add("down", [4], fps: fps, loops: false)
      add("down-left", [5], fps: fps, loops: false)
      add("left", [6], fps: fps, loops: false)
      add("up-left", [7], fps: fps, loops: false)
      add("idle", [4, 8, 9, 10, 11, 4], fps: fps, loops: false)
      add("walk-up", [0, *(12..17)], fps: fps_walk, loops: true)
      add("walk-up-right", [1, *(18..23)], fps: fps_walk, loops: true)
      add("walk-right", [2, *(24..29)], fps: fps_walk, loops: true)
      add("walk-down-right", [3, *(30..35)], fps: fps_walk, loops: true)
      add("walk-down", [4, *(36..41)], fps: fps_walk, loops: true)
      play("down")
    end

    # custom collision box, just the feet of sprite whitespace
    def collision_bounding_box : GSDL::FRect
      GSDL::FRect.new(x: 6 * scale_x, y: 26 * scale_y, w: draw_width - 12 * scale_x, h: draw_height - 28 * scale_y)
    end

    def update(dt : Float32, tile_map : GSDL::TileMap)
      # physics and collision handling
      move_and_collide(dt, tile_map)

      # calls AnimatedSprite#update for animation playback
      super(dt)
    end

    def update_animations(dx : Int8, dy : Int8)
      if dy < 0
        if dx != 0
          animate("walk-up-right")
        else
          animate("walk-up")
        end
      elsif dy > 0
        if dx != 0
          animate("walk-down-right")
        else
          animate("walk-down")
        end
      elsif dx != 0
        animate("walk-right")
      else
        pause unless playing?("idle")
      end

      if dx != 0
        @flip_left = dx < 0
      end

      if idle_timer.done?
        animate("idle", force: true)
      end
    end

    def animate(animation : String, force = false)
      play(animation) if paused? || !playing?(animation) || force
      idle_timer.restart
    end

    def draw(draw : GSDL::Draw, camera_x : Float32 = 0_f32, camera_y : Float32 = 0_f32, flip_horizontal : Bool = false)
      super(
        draw: draw,
        camera_x: camera_x,
        camera_y: camera_y,
        flip_horizontal: flip_horizontal || flip_left?
      )

      draw_debug(draw: draw, camera_x: camera_x, camera_y: camera_y) if debug?
    end

    def draw_debug(draw : GSDL::Draw, camera_x : Float32, camera_y : Float32)
      rect = self.collision_box
      draw.rect_outline(
        rect: GSDL::FRect.new(
          x: rect.x - camera_x,
          y: rect.y - camera_y,
          w: rect.w,
          h: rect.h
        ),
        color: GSDL::Color::Lime,
        z_index: 100
      )
    end
  end
end