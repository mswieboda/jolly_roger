require "./scene/start"

module JR
  class SceneManager < GSDL::SceneManager
    getter start

    def initialize
      super

      DialogManager.load("data/dialog.yml")
      @scene = Scene::Start.new
    end

    def check_scenes
      if current_scene = scene
        # if transition_out made scene exit, exit the scene manager / game
        if current_scene.exit?
          @exit = true
        end
      end
    end
  end
end
