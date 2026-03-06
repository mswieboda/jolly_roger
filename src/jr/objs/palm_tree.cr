module JR
  class PalmTree < GSDL::TileObject
    def get_collision_rect : GSDL::FRect
      GSDL::FRect.new(@x + 16, @y - 16, 16, 12)
    end

    def update(dt : Float32)
      # Custom logic here (e.g. animation)
    end
  end

  GSDL::TileObjectFactory.register_class("palm-tree", PalmTree)
end
