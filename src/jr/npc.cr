module JR
  class NPC < Character
    property dialog_key : String?

    def initialize(@dialog_key : String? = nil)
      super(key: "player", width: 24, height: 40)
    end

    def running? : Bool
      false
    end

    def move_input
      # NPC doesn't move by user input
      self.dx = 0
      self.dy = 0
    end
  end
end
