module JR
  class Player < GSDL::AnimatedSprite
    IdleTime = 5.seconds

    getter idle_timer : GSDL::Timer

    def initialize
      super(key: "player", width: 24, height: 40, scale: {2_f32, 2_f32})

      @idle_timer = GSDL::Timer.new(IdleTime)
      @idle_timer.start

      center(width: Game.width, height: Game.height)

      # animations
      fps = 4
      add("up", [0], fps: fps, loops: false)
      add("up-right", [1], fps: fps, loops: false)
      add("right", [2], fps: fps, loops: false)
      add("down-right", [3], fps: fps, loops: false)
      add("down", [4], fps: fps, loops: false)
      add("down-left", [5], fps: fps, loops: false)
      add("left", [6], fps: fps, loops: false)
      add("up-left", [7], fps: fps, loops: false)
      add("idle", [4, 8, 9, 10, 11, 4], fps: fps, loops: false)
      add("walk-right", [2, 12, 13, 14, 15, 16, 17], fps: 8, loops: true)
      play("down")
    end

    def update(dt : Float32)
      super(dt)

      if Keys.pressed?(Keys::W)
        if Keys.pressed?(Keys::D)
          animate("up-right")
        elsif Keys.pressed?(Keys::A)
          animate("up-left")
        else
          animate("up")
        end
      elsif Keys.pressed?(Keys::S)
        if Keys.pressed?(Keys::D)
          animate("down-right")
        elsif Keys.pressed?(Keys::A)
          animate("down-left")
        else
          animate("down")
        end
      elsif Keys.pressed?(Keys::D)
        animate("walk-right")
      elsif Keys.pressed?(Keys::A)
        animate("left")
      else
        pause unless playing?("idle")
      end

      if idle_timer.done?
        animate("idle")
      end
    end


    def animate(animation : String)
      play(animation) if paused? || !playing?(animation)
      idle_timer.restart
    end
  end
end
