module JR
  class Player < Character
    def initialize
      super(key: "player", width: 24, height: 40)
    end

    def update(dt : Float32, tile_map : GSDL::TileMap, npcs : Array(NPC))
      @debug = !@debug if Input.action?(:debug)

      dx, dy = delta_input_movement
      running = Input.action?(:run)

      current_speed = Speed.to_f
      current_speed *= 2.0 if running

      if dx != 0 && dy != 0
        current_speed /= Math.sqrt(2)
      end

      @velocity_x = dx.to_f32 * current_speed
      @velocity_y = dy.to_f32 * current_speed

      update_animations(dx, dy, running)

      super(dt, tile_map, npcs)
    end

    def delta_input_movement : Tuple(Int8, Int8)
      dx = 0_i8
      dy = 0_i8

      dx = -1_i8 if Input.action?(:left)
      dx = 1_i8 if Input.action?(:right)

      dy = -1_i8 if Input.action?(:up)
      dy = 1_i8 if Input.action?(:down)

      {dx, dy}
    end
  end
end