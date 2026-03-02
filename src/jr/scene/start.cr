module JR
  class Scene::Start < GSDL::Scene
    getter tile_map : GSDL::TileMap
    getter player : Player
    getter npcs : Array(NPC)
    getter static_entities : Array(StaticEntity)
    getter camera_x : Num = 0
    getter camera_y : Num = 0
    getter dialog_box : GSDL::DialogBox

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

      Input.set(:up) { Keys.pressed?([Keys::W, Keys::Up]) }
      Input.set(:left) { Keys.pressed?([Keys::A, Keys::Left]) }
      Input.set(:down) { Keys.pressed?([Keys::S, Keys::Down]) }
      Input.set(:right) { Keys.pressed?([Keys::D, Keys::Right]) }
      Input.set(:move_up) { Keys.pressed?([Keys::W, Keys::Up]) }
      Input.set(:move_left) { Keys.pressed?([Keys::A, Keys::Left]) }
      Input.set(:move_down) { Keys.pressed?([Keys::S, Keys::Down]) }
      Input.set(:move_right) { Keys.pressed?([Keys::D, Keys::Right]) }
      Input.set(:run) { Keys.pressed?([Keys::LShift, Keys::RShift]) }
      Input.set(:action) { Keys.just_pressed?([Keys::Return, Keys::Space, Keys::E]) }
      Input.set(:menu) { Keys.just_pressed?([Keys::Escape]) }
      Input.set(:menu_up) { Keys.just_pressed?([Keys::W, Keys::Up]) }
      Input.set(:menu_down) { Keys.just_pressed?([Keys::S, Keys::Down]) }
      Input.set(:menu_select) { Keys.just_pressed?([Keys::Return, Keys::Space, Keys::E]) }

      {% unless flag?(:release) %}
        Input.set(:debug) { Keys.just_pressed?(Keys::Tab) }
      {% end %}

      @tile_map = GSDL::TileMapManager.get("map")

      @camera = GSDL::Camera.new(width: Game.width, height: Game.height)
      @camera.type = GSDL::Camera::Type::CenterOnTarget

      @player = Player.new
      @player.center(width: Game.width, height: Game.height)

      @static_entities = [] of StaticEntity

      @static_entities << Sign.new(x: @player.x + 64, y: @player.y, dialog_key: "sign_post")
      e_tint = Color::Magenta
      e_tint.a = 128
      @static_entities.each do |e|
        e.tint = e_tint
      end

      @npcs = [] of NPC

      colors = [
        Color::Red,
        Color::Blue,
        Color::Green,
        Color::Yellow,
        Color::Purple,
        Color::Cyan,
        Color::Orange,
        Color::Magenta,
      ]

      13.times do |i|
        tint = colors.sample
        tint.a = 128

        npc = NPC.new
        npc.tint = tint

        if i == 0
          npc.dialog_key = "blacksmith_intro"
          npc.tint = Color::White # Make the blacksmith distinct
        end

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

      @dialog_box = GSDL::DialogBox.new
    end

    def update(dt : Float32)
      update_dialogs(dt)

      if dialog_box.is_active
        dialog_box.update(dt)
      else
        all_collidables = [player.as(GSDL::Collidable)] + 
                         npcs.map(&.as(GSDL::Collidable)) + 
                         static_entities.map(&.as(GSDL::Collidable))

        player.update(dt, tile_map, all_collidables)
        npcs.each(&.update(dt, tile_map, all_collidables))
        static_entities.each(&.update(dt))
      end

      if Input.action?(:menu)
        transition_out.start
      end

      # camera follows player
      @camera.look_at(@player.x, @player.y)
      @camera.update(dt)
    end

    def update_dialogs(dt : Float32)
      # interaction logic
      if !dialog_box.is_active && Input.action?(:action)
        # Check NPCs
        npcs.each do |npc|
          if npc.dialog_key && player.facing?(npc.x, npc.y)
            dist_x = player.x - npc.x
            dist_y = player.y - npc.y
            dist_sq = dist_x * dist_x + dist_y * dist_y

            # ~48 pixels radius for interaction
            if dist_sq < 48 * 48
              dialog_box.start(npc.dialog_key.not_nil!)
              return
            end
          end
        end

        # Check static entities
        static_entities.each do |entity|
          if entity.dialog_key && player.facing?(entity.x, entity.y)
            dist_x = player.x - entity.x
            dist_y = player.y - entity.y
            dist_sq = dist_x * dist_x + dist_y * dist_y

            if dist_sq < 48 * 48
              dialog_box.start(entity.dialog_key.not_nil!)
              return
            end
          end
        end
      end
    end

    def draw(draw : GSDL::Draw)
      # TODO: fix these camera params in GSDL to be both Num
      tile_map.draw(draw, @camera)
      static_entities.each(&.draw(draw, @camera))
      npcs.each(&.draw(draw, @camera))
      player.draw(draw, @camera)

      dialog_box.draw(draw)
    end
  end
end
