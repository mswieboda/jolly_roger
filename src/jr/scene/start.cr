module JR
  class Scene::Start < GSDL::Scene
    IdleTime = 5.seconds

    getter sprite : GSDL::AnimatedSprite
    getter text : GSDL::Text
    getter idle_timer : GSDL::Timer

    def initialize
      transition_in = GSDL::FadeTransition.new(
        direction: GSDL::TransitionDirection::In,
        duration: 0.75_f32,
        started: true
      )
      transition_out = GSDL::FadeTransition.new(
        direction: GSDL::TransitionDirection::Out,
        duration: 0.5_f32
      )

      super(:start, transition_in: transition_in, transition_out: transition_out)

      color = GSDL::Color.new(g: 255, a: 255)
      @text = GSDL::Text.new(text: "Jolly Roger!", color: color)
      @text.center(width: Game.width, height: Game.height - 300)

      @sprite = GSDL::AnimatedSprite.new("player", width: 24, height: 40, scale: {2_f32, 2_f32})
      @sprite.center(width: Game.width, height: Game.height)

      # animations
      fps = 4
      @sprite.add("up", [0], fps: fps, loops: false)
      @sprite.add("up-right", [1], fps: fps, loops: false)
      @sprite.add("right", [2], fps: fps, loops: false)
      @sprite.add("down-right", [3], fps: fps, loops: false)
      @sprite.add("down", [4], fps: fps, loops: false)
      @sprite.add("down-left", [5], fps: fps, loops: false)
      @sprite.add("left", [6], fps: fps, loops: false)
      @sprite.add("up-left", [7], fps: fps, loops: false)
      @sprite.add("idle", [4, 8, 9, 10, 11, 4], fps: fps, loops: false)
      @sprite.add("walk-right", [2, 12, 13, 14, 15, 16, 17], fps: 8, loops: true)
      @sprite.play("down")

      @idle_timer = GSDL::Timer.new(IdleTime)
      @idle_timer.start
    end

    def update(dt : Float32)
      sprite.update(dt)

      if Keys.pressed?(Keys::Escape)
        transition_out.start
      end

      if Keys.pressed?(Keys::W)
        if Keys.pressed?(Keys::D)
          update_animation("up-right")
        elsif Keys.pressed?(Keys::A)
          update_animation("up-left")
        else
          update_animation("up")
        end
      elsif Keys.pressed?(Keys::S)
        if Keys.pressed?(Keys::D)
          update_animation("down-right")
        elsif Keys.pressed?(Keys::A)
          update_animation("down-left")
        else
          update_animation("down")
        end
      elsif Keys.pressed?(Keys::D)
        update_animation("walk-right")
      elsif Keys.pressed?(Keys::A)
        update_animation("left")
      else
        sprite.pause
      end

      if idle_timer.done?
        update_animation("idle")
      end
    end

    def update_animation(animation : String)
      sprite.play(animation) if sprite.paused? || !sprite.playing?(animation)
      idle_timer.restart
    end

    def draw(draw : GSDL::Draw)
      text.draw(draw)
      sprite.draw(draw)
    end
  end
end
