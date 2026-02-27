module JR
  class Scene::Start < GSDL::Scene
    getter tile_map : GSDL::TileMap
    getter player : Player
    getter npcs : Array(NPC)
    getter camera_x : Num = 0
    getter camera_y : Num = 0
    getter dialog_box : UI::DialogBox

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

      Input.set(:up) { GSDL::Keys.pressed?([GSDL::Keys::W, GSDL::Keys::Up]) }
      Input.set(:left) { GSDL::Keys.pressed?([GSDL::Keys::A, GSDL::Keys::Left]) }
      Input.set(:down) { GSDL::Keys.pressed?([GSDL::Keys::S, GSDL::Keys::Down]) }
      Input.set(:right) { GSDL::Keys.pressed?([GSDL::Keys::D, GSDL::Keys::Right]) }
      Input.set(:menu_up) { GSDL::Keys.just_pressed?([GSDL::Keys::W, GSDL::Keys::Up]) }
      Input.set(:menu_down) { GSDL::Keys.just_pressed?([GSDL::Keys::S, GSDL::Keys::Down]) }
      Input.set(:menu_select) { GSDL::Keys.just_pressed?([GSDL::Keys::Return, Keys::Space, Keys::E]) }

      {% unless flag?(:release) %}
        Input.set(:debug) { GSDL::Keys.just_pressed?(GSDL::Keys::Tab) }
      {% end %}

      @tile_map = GSDL::TileMapManager.get("map")
      @player = Player.new
      @player.center(width: Game.width, height: Game.height)

      @npcs = [] of NPC

      colors = [
        GSDL::Color::Red,
        GSDL::Color::Blue,
        GSDL::Color::Green,
        GSDL::Color::Yellow,
        GSDL::Color::Purple,
        GSDL::Color::Cyan,
        GSDL::Color::Orange,
        GSDL::Color::Magenta,
      ]

      13.times do
        tint = colors.sample
        tint.a = 128

        npc = NPC.new
        npc.tint = tint

        @npcs << npc
      end

      # random spots on map
      padding = 16
      map_width = @tile_map.map_width_tiles * @tile_map.tile_width
      map_height = @tile_map.map_height_tiles * @tile_map.tile_height

      @npcs.each do |npc|
        npc.x = rand((npc.width + padding)..(map_width - padding))
        npc.y = rand((npc.height + padding)..(map_height - padding))
      end

      @dialog_box = UI::DialogBox.new
      @dialog_box.start("blacksmith_intro")
    end

    def update(dt : Float32)
      player.update(dt, tile_map)
      npcs.each(&.update(dt, tile_map))
      dialog_box.update(dt)

      if Keys.pressed?(Keys::Escape)
        transition_out.start
      end

      # camera follows player
      @camera_x = player.x - Game.width / 2_f32
      @camera_y = player.y - Game.height / 2_f32
    end

    def draw(draw : GSDL::Draw)
      # TODO: fix these camera params in GSDL to be both Num
      tile_map.draw(draw, camera_x.to_i, camera_y.to_i)
      npcs.each(&.draw(draw, camera_x.to_f32, camera_y.to_f32))
      player.draw(draw, camera_x.to_f32, camera_y.to_f32)

      dialog_box.draw(draw)
    end
  end
end
