module JR
  abstract class Scene < GSDL::Scene
    property warps : Array(Warp) = [] of Warp
    property next_scene : GSDL::Scene?
    property next_spawn_point : String?
    property? can_warp : Bool = false

    def initialize(name : Symbol)
      super(name)
    end

    def update(dt : Float32)
      super(dt)

      if GSDL::Input.action?(:menu)
        GSDL::Game.instance.paused = true
        return
      end

      check_warps
    end

    def check_warps
      # Collision detection between player and warps
      if player = get_player
        # Find if we are currently colliding with any warp
        colliding_with_any = warps.any? { |w| player.collides?(w) }

        if @can_warp
          if colliding_with_any
            # Warp triggered
            warp = warps.find { |w| player.collides?(w) }.not_nil!
            on_warp(warp)
          end
        else
          # If we were not allowed to warp, we must wait until we are NOT 
          # colliding with anything before we enable it.
          unless colliding_with_any
            @can_warp = true
          end
        end
      end
    end

    def on_warp(warp : Warp)
      @can_warp = false
      @next_scene = create_scene_by_name(warp.target_scene)
      @next_spawn_point = warp.target_spawn_point
      transition_out.start
    end

    # This should be implemented by child classes to return the player object
    abstract def get_player : Player?

    # Factory method to create scenes from names
    def create_scene_by_name(name : String) : GSDL::Scene?
      case name
      when "start"
        Scene::Start.new
      when "test"
        Scene::Test.new
      # Add other scenes here as they are created
      else
        nil
      end
    end
  end
end
