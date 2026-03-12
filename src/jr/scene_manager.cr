require "./scene"
require "./scene/*"

module JR
  class SceneManager < GSDL::SceneManager
    getter start

    def initialize
      super

      GSDL::DialogManager.load("data/dialog.yml")
      self.pause_scene = JR::PauseScene.new
      @scene = Scene::Start.new
    end

    def check_scenes
      if current_scene = scene.as?(JR::Scene)
        # Check if we have a scene switch queued
        if next_scene = current_scene.next_scene
          if current_scene.transition_out.done?
            spawn_point_name = current_scene.next_spawn_point
            arrival_direction = current_scene.next_arrival_direction
            switch(next_scene)

            # Find the spawn point in the new scene
            if new_scene = scene.as?(JR::Scene)
              if player = new_scene.get_player
                if spawn_point_name
                  # Find a warp with the matching name to use as a spawn point
                  spawn_point = new_scene.warps.find { |w| w.name == spawn_point_name }
                  if spawn_point
                    player.x = spawn_point.x
                    player.y = spawn_point.y
                    if arrival_direction
                      player.direction = arrival_direction
                    end
                  end
                end
              end
            end
            return
          end
        end

        # if transition_out made scene exit, and no next_scene was queued, exit the scene manager / game
        if current_scene.exit?
          @exit = true
          return
        end
      end
    end
  end
end
