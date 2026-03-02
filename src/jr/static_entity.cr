module JR
  class StaticEntity < GSDL::AnimatedSprite
    property dialog_key : String?

    def initialize(key : String, width : Int32, height : Int32, @dialog_key : String? = nil)
      super(key: key, width: width, height: height)
    end

    def update_animations(running : Bool = false)
      # No-op for static entities unless we want them to react to movement
      if idle_timer.done?
        animate("idle", force: true)
      end
    end
  end

  class Sign < StaticEntity
    def initialize(x : Num, y : Num, @dialog_key : String? = nil)
      # Using tiles as a placeholder as requested
      super(key: "tiles", width: 32, height: 32, dialog_key: @dialog_key)
      self.x = x.to_f32
      self.y = y.to_f32
    end
    
    # Signs might have different collision boxes
    def collision_bounding_box : GSDL::FRect
      GSDL::FRect.new(x: 4 * scale_x, y: 4 * scale_y, w: draw_width - 8 * scale_x, h: draw_height - 8 * scale_y)
    end
  end
end
