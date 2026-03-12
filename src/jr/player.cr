module JR
  class Player < Character
    def initialize
      super(key: "player", width: 24, height: 40)
    end

    def running? : Bool
      Input.action?(:run)
    end
  end
end
