require "yaml"

module JR
  struct DialogChoice
    include YAML::Serializable

    getter text : String
    getter next_id : String
    getter actions : Array(String)?
    getter conditions : Array(String)?
  end

  struct DialogNode
    include YAML::Serializable

    getter text : String
    getter choices : Array(DialogChoice)?
  end

  class DialogManager
    getter dialogs : Hash(String, DialogNode) = {} of String => DialogNode

    def load(path : String)
      File.open(path) do |file|
        @dialogs = Hash(String, DialogNode).from_yaml(file)
      end
    end

    def get_node(id : String) : DialogNode?
      @dialogs[id]?
    end
  end
end
