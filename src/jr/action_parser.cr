module JR
  module ActionParser
    extend self

    # Parses and executes an action string like "start_quest:find_hammer"
    def execute(action_string : String)
      parts = action_string.split(":", 2)
      action = parts[0]?
      argument = parts[1]?

      case action
      when "start_quest"
        puts "Starting quest: #{argument}"
        # TODO: Hook into QuestManager
      when "open_shop"
        puts "Opening shop: #{argument}"
        # TODO: Hook into ShopManager/UI
      when "give_item"
        puts "Giving item: #{argument}"
        # TODO: Hook into InventoryManager
      else
        puts "Unknown action: #{action}"
      end
    end

    # Parses a condition string like "has_item:gold_coin" and returns a boolean
    def check_condition(condition_string : String) : Bool
      parts = condition_string.split(":", 2)
      condition = parts[0]?
      argument = parts[1]?

      case condition
      when "has_item"
        puts "Checking for item: #{argument}"
        # TODO: Hook into InventoryManager
        true
      when "quest_active"
        puts "Checking if quest is active: #{argument}"
        # TODO: Hook into QuestManager
        true
      when "quest_completed"
        puts "Checking if quest is completed: #{argument}"
        # TODO: Hook into QuestManager
        true
      else
        puts "Unknown condition: #{condition}"
        true
      end
    end
  end
end
