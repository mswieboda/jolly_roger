module JR
  class Player < Character
    def initialize
      super(key: "player", width: 24, height: 40)
    end

    def update(dt : Float32, tile_map : GSDL::TileMap)
      @debug = !@debug if Input.action?(:debug)

      dx, dy = delta_input_movement

      # TODO: make sure when both directions,
      # use the square root thing for even distance
      @velocity_x = dx.to_i * Speed
      @velocity_y = dy.to_i * Speed

      update_animations(dx, dy)

      super(dt, tile_map)
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