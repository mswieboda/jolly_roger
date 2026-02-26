module JR
  class Scene::Start < GSDL::Scene
    getter player : Player
    getter text : GSDL::Text

    def initialize
      super(:start)

      {% if flag?(:release) %}
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
      {% end %}

      color = GSDL::Color.new(g: 255, a: 255)
      @text = GSDL::Text.new(text: "Jolly Roger!", color: color)
      @text.center(width: Game.width, height: Game.height - 300)

      @player = Player.new
    end

    def update(dt : Float32)
      player.update(dt)

      if Keys.pressed?(Keys::Escape)
        transition_out.start
      end
    end

    def draw(draw : GSDL::Draw)
      text.draw(draw)
      player.draw(draw)
    end
  end
end
