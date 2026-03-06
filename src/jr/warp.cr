module JR
  class Warp < GSDL::AnimatedSprite
    property name : String
    property target_scene : String
    property target_spawn_point : String

    def initialize(@name : String, key : String, width : Int32, height : Int32, @target_scene : String, @target_spawn_point : String, @dialog_key : String? = nil)
      super(key: key, width: width, height: height)

      @origin = {0.5_f32, 0.5_f32}
      @z_index = 1
      @scale = {2_f32, 2_f32}
      @tint = Color::Black
    end

    # Define a default collision bounding box. This can be overridden in subclasses.
    def collision_bounding_box : GSDL::FRect
      GSDL::FRect.new(
        x: draw_width / 2.5_f32,
        y: draw_height / 2.5_f32,
        w: draw_width - draw_width / 1.25_f32,
        h: draw_height - draw_height / 1.25_f32
      )
    end

    def update(dt : Float32)
      # Warps are static and don't typically have complex updates.
      # Call super to handle animation updates if any are defined.
      super(dt)
    end
  end
end
