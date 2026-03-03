module JR
  class PauseScene < GSDL::Scene
    @menu : GSDL::Menu
    @title : GSDL::Text
    @background : GSDL::Box

    def initialize
      super(:pause)
      @z_index = 2000

      @title = GSDL::Text.new(
        text: "PAUSED",
        x: GSDL::Game.width / 2_f32,
        y: GSDL::Game.height / 2_f32 - 100,
        origin: {0.5_f32, 0.5_f32},
        color: GSDL::Color::White,
        scale: {2_f32, 2_f32},
        z_index: @z_index
      )

      items = [
        {:resume, "Resume"},
        {:exit, "Exit"}
      ]

      @menu = GSDL::Menu.new(
        is_selected: ->(x : GSDL::Num, y : GSDL::Num, w : GSDL::Num, h : GSDL::Num) {
          GSDL::Keys.just_pressed?([GSDL::Keys::Space, GSDL::Keys::Return]) ||
            GSDL::Mouse.clicked_in?(x, y, w, h)
        },
        is_next: -> { GSDL::Keys.just_pressed?([GSDL::Keys::S, GSDL::Keys::Down]) },
        is_previous: -> { GSDL::Keys.just_pressed?([GSDL::Keys::W, GSDL::Keys::Up]) },
        items: items,
        x: GSDL::Game.width // 2,
        y: GSDL::Game.height // 2,
        origin: {0.5_f32, 0.5_f32},
        on_select: ->(id : Symbol) {
          if id == :resume
            GSDL::Game.instance.paused = false
          elsif id == :exit
            GSDL::Game.instance.scene_manager.exit
          end
          nil
        },
        mouse_hover: true,
        background_box: GSDL::Box.new(color: GSDL::Color.new(0, 0, 0, 150), border_radius: 16),
        padding: 20,
        separation: 10,
        z_index: @z_index
      )

      @background = GSDL::Box.new(
        x: 0,
        y: 0,
        width: GSDL::Game.width,
        height: GSDL::Game.height,
        color: GSDL::Color.new(0, 0, 0, 150),
        z_index: @z_index - 1
      )
    end

    def update(dt : Float32)
      @menu.update(dt)

      if GSDL::Keys.just_pressed?([GSDL::Keys::Escape])
        GSDL::Game.instance.paused = false
        return
      end
    end

    def draw(draw : GSDL::Draw)
      @background.draw(draw)
      @title.draw(draw)
      @menu.draw(draw)
    end
  end
end
