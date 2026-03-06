module JR
  class Barrel < GSDL::TileObject
    getter? open : Bool = false

    def get_collision_rect : GSDL::FRect
      GSDL::FRect.new(@x + 8, @y - 12, 16, 8)
    end

    def interact : String
      @open = !@open
      "Barrel is now #{@open ? "OPEN" : "CLOSED"}"
    end

    def update(dt : Float32)
      # Custom logic here (e.g. animation)
    end
  end

  GSDL::TileObjectFactory.register_class("barrel", Barrel)
end
