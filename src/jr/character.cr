module JR
  abstract class Character < GSDL::AnimatedSprite
    include GSDL::TopDownController
    include GSDL::TileMapCollidable

    IdleTime = 5.seconds
    Speed = 96

    getter idle_timer : GSDL::Timer
    getter? flip_left
    property? debug = false

    def initialize(key : String, width : Int32, height : Int32)
      super(key: key, width: width, height: height)

      @z_index = 3

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

      # TODO: add custom run animations instead of using walk ones
      add("run-up", [0, *(12..17)], fps: fps_walk, loops: true)
      add("run-up-right", [1, *(18..23)], fps: fps_walk, loops: true)
      add("run-right", [2, *(24..29)], fps: fps_walk, loops: true)
      add("run-down-right", [3, *(30..35)], fps: fps_walk, loops: true)
      add("run-down", [4, *(36..41)], fps: fps_walk, loops: true)

      play("down")
    end

    # custom collision box, just the feet of sprite whitespace
    def collision_bounding_box : GSDL::FRect
      GSDL::FRect.new(x: 6 * scale_x, y: 26 * scale_y, w: draw_width - 12 * scale_x, h: draw_height - 28 * scale_y)
    end

    abstract def running? : Bool

    def move_speed : Num
      running? ? Speed * 2.0_f32 : Speed.to_f32
    end

    def grid_size : Num
      32
    end

    def update(dt : Float32, tile_map : GSDL::TileMap, collidables : Array(GSDL::Collidable))
      top_down_update(
        dt: dt,
        collidables: collidables.reject { |n| n == self },
        tile_map: tile_map
      )

      update_animations(running?)

      # calls AnimatedSprite#update for animation playback
      super(dt)
    end

    def update_animations(running : Bool = false)
      prefix = "idle"

      if moving?
        prefix = running ? "run" : "walk"

        case direction
        when .up?
          animate("#{prefix}-up")
        when .up_right?
          animate("#{prefix}-up-right")
        when .right?
          animate("#{prefix}-right")
        when .down_right?
          animate("#{prefix}-down-right")
        when .down?
          animate("#{prefix}-down")
        when .down_left?
          # we don't have down-left animation specifically, using down-right with flip
          animate("#{prefix}-down-right")
        when .left?
          animate("#{prefix}-right")
        when .up_left?
          animate("#{prefix}-up-right")
        end
      else
        pause unless playing?("idle")
      end

      if dx != 0
        @flip_left = dx < 0
      elsif direction.left? || direction.up_left? || direction.down_left?
        @flip_left = true
      elsif direction.right? || direction.up_right? || direction.down_right?
        @flip_left = false
      end

      if idle_timer.done?
        animate("idle", force: true)
      end
    end

    def animate(animation : String, force = false)
      play(animation) if paused? || !playing?(animation) || force
      idle_timer.restart
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
          x: rect.x - camera.try(&.x) || 0,
          y: rect.y - camera.try(&.y) || 0,
          w: rect.w,
          h: rect.h
        ),
        color: GSDL::Color::Lime,
        z_index: 100
      )
    end
  end
end
