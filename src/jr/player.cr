module JR
  class Player < Character
    def initialize
      super(key: "player", width: 24, height: 40)
    end

    def running? : Bool
      Input.action?(:run)
    end

    def update(dt : Float32, tile_map : GSDL::TileMap, collidables : Array(GSDL::Collidable))
      @debug = !@debug if Input.action?(:debug)

      super(dt, tile_map, collidables)
    end
  end
end
