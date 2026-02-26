module JR
  class Scene::Start < GSDL::Scene
    @text : GSDL::Text

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
    end

    def update(dt : Float32)
      if GSDL::Keys.just_pressed?(GSDL::Keys::Escape)
        transition_out.start
      end
    end

    def draw(draw : GSDL::Draw)
      @text.draw(draw)
    end
  end
end
