module JR
  class NPC < Character
    property dialog_key : String?

    def initialize(@dialog_key : String? = nil)
      super(key: "player", width: 24, height: 40)
    end

    def update(dt : Float32, tile_map : GSDL::TileMap)
      dx = 0_i8
      dy = 0_i8

      @velocity_x = 0
      @velocity_y = 0

      update_animations(dx, dy)

      super(dt, tile_map)
    end
  end
end