module JR
  abstract class Character < GSDL::AnimatedSprite
    include GSDL::TileMapCollidable
    include GSDL::Directionable

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

    def update(dt : Float32, tile_map : GSDL::TileMap, npcs : Array(NPC))
      # physics and collision handling
      move_and_collide(dt, tile_map, npcs)

      # calls AnimatedSprite#update for animation playback
      super(dt)
    end

    def move_and_collide(dt : Float32, tile_map : GSDL::TileMap, npcs : Array(NPC))
      move_vertical_and_collide(dt, tile_map, npcs)
      move_horizontal_and_collide(dt, tile_map, npcs)
    end

    def move_vertical_and_collide(dt : Float32, tile_map : GSDL::TileMap, npcs : Array(NPC))
      vel_y = @velocity_y

      # Do tilemap collision first
      move_vertical_and_collide(dt: dt, tile_map: tile_map)

      # Now handle NPC collision
      npcs.each do |npc|
        next if npc == self
        if collides?(npc)
          if vel_y > 0
            self.y = npc.collision_box.y - collision_bounding_box.y - collision_bounding_box.h + (draw_height * origin_y)
            @velocity_y = 0
            @grounded = true
          elsif vel_y < 0
            self.y = npc.collision_box.y + npc.collision_box.h - collision_bounding_box.y + (draw_height * origin_y)
            @velocity_y = 0
          end
        end
      end
    end

    def move_horizontal_and_collide(dt : Float32, tile_map : GSDL::TileMap, npcs : Array(NPC))
      vel_x = @velocity_x

      # Do tilemap collision first
      move_horizontal_and_collide(dt: dt, tile_map: tile_map)

      # Now handle NPC collision
      npcs.each do |npc|
        next if npc == self
        if collides?(npc)
          if vel_x > 0
            self.x = npc.collision_box.x - collision_bounding_box.x - collision_bounding_box.w + (draw_width * origin_x)
            @velocity_x = 0
          elsif vel_x < 0
            self.x = npc.collision_box.x + npc.collision_box.w - collision_bounding_box.x + (draw_width * origin_x)
            @velocity_x = 0
          end
        end
      end
    end

    def update_animations(dx : Int8, dy : Int8, running : Bool = false)
      prefix = "idle"

      if dx != 0 || dy != 0
        prefix = running ? "run" : "walk"
      end

      if dy < 0
        if dx != 0
          animate("#{prefix}-up-right")
          @direction = dx > 0 ? GSDL::Direction::UpRight : GSDL::Direction::UpLeft
        else
          animate("#{prefix}-up")
          @direction = GSDL::Direction::Up
        end
      elsif dy > 0
        if dx != 0
          animate("#{prefix}-down-right")
          @direction = dx > 0 ? GSDL::Direction::DownRight : GSDL::Direction::DownLeft
        else
          animate("#{prefix}-down")
          @direction = GSDL::Direction::Down
        end
      elsif dx != 0
        animate("#{prefix}-right")
        @direction = dx > 0 ? GSDL::Direction::Right : GSDL::Direction::Left
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