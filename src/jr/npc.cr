module JR
  class NPC < Character
    enum State
      Idle
      Wandering
    end

    property dialog_key : String?
    property wander_radius : Float32 = 64.0_f32
    property? interacting : Bool = false

    getter state : State = State::Idle
    getter move_timer : GSDL::Timer
    getter spawn_x : Float32 = 0.0_f32
    getter spawn_y : Float32 = 0.0_f32

    @wander_target_x : Float32 = 0.0_f32
    @wander_target_y : Float32 = 0.0_f32

    def initialize(@dialog_key : String? = nil)
      super(key: "player", width: 24, height: 40)
      @move_timer = GSDL::Timer.new(rand(2.0..5.0).seconds)
      @move_timer.start
    end

    def running? : Bool
      false
    end

    def spawn_at(x : Num, y : Num)
      self.x = x.to_f32
      self.y = y.to_f32
      @spawn_x = x.to_f32
      @spawn_y = y.to_f32
    end

    def move_input
      # Stop if interacting
      if interacting?
        self.dx = 0
        self.dy = 0
        return
      end

      case @state
      when State::Idle
        self.dx = 0
        self.dy = 0

        if @move_timer.done?
          start_wandering
        end
      when State::Wandering
        # Set dx, dy towards target
        dist_x = @wander_target_x - x
        dist_y = @wander_target_y - y

        # Simple movement towards target
        # Using a threshold to avoid jitter
        self.dx = dist_x.abs > 2.0_f32 ? (dist_x > 0 ? 1 : -1) : 0
        self.dy = dist_y.abs > 2.0_f32 ? (dist_y > 0 ? 1 : -1) : 0

        # Stop if reached target or stuck or timer done
        if (self.dx == 0 && self.dy == 0) || @move_timer.done?
          stop_wandering
        end
      end
    end

    private def start_wandering
      @state = State::Wandering

      # Pick a random point within wander_radius from spawn
      angle = rand * 2 * Math::PI
      dist = rand * @wander_radius
      @wander_target_x = @spawn_x + Math.cos(angle).to_f32 * dist
      @wander_target_y = @spawn_y + Math.sin(angle).to_f32 * dist

      @move_timer = GSDL::Timer.new(rand(1.0..3.0).seconds)
      @move_timer.start
    end

    private def stop_wandering
      @state = State::Idle
      @move_timer = GSDL::Timer.new(rand(2.0..5.0).seconds)
      @move_timer.start
      self.dx = 0
      self.dy = 0
    end
  end
end
