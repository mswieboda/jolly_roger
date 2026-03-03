module JR
  class Warp < GSDL::AnimatedSprite
    property name : String
    property dialog_key : String?
    property target_scene : String
    property target_spawn_point : String

    def initialize(@name : String, key : String, width : Int32, height : Int32, @target_scene : String, @target_spawn_point : String, @dialog_key : String? = nil)
      super(key: key, width: width, height: height)
      @z_index = 0 # Adjust as needed
    end

    # Define a default collision bounding box. This can be overridden in subclasses.
    def collision_bounding_box : GSDL::FRect
      GSDL::FRect.new(x: 0, y: 0, w: draw_width, h: draw_height)
    end

    def update(dt : Float32)
      # Warps are static and don't typically have complex updates.
      # Call super to handle animation updates if any are defined.
      super(dt)
    end
  end
end
