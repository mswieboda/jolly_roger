require "game_sdl"

module JR
  module UI
    class DialogBox
      getter current_node : DialogNode?
      getter is_active : Bool = false
      getter selected_choice : Int32 = 0

      # UI Elements
      @main_box : GSDL::Message
      @choices_boxes : Array(GSDL::Message) = [] of GSDL::Message
      @valid_choices : Array(DialogChoice) = [] of DialogChoice

      def initialize
        @main_box = GSDL::Message.new(
          text: "",
          x: 400_f32,
          y: 400_f32,
          origin: {0.5_f32, 0.0_f32},
          width: 700,
          height: 100,
          color: GSDL::Color::Black,
          border_radius: 8.0_f32
        )
      end

      def start(node_id : String)
        @is_active = true
        load_node(node_id)
      end

      def stop
        @is_active = false
        @current_node = nil
      end

      private def load_node(node_id : String)
        if node_id == "exit"
          stop
          return
        end

        node = DialogManager.get_node(node_id)
        if node.nil?
          puts "Error: Dialog node '#{node_id}' not found."
          stop
          return
        end

        @current_node = node
        @selected_choice = 0
        @main_box.text = node.text
        
        # Build choice boxes
        @choices_boxes.clear
        if choices = node.choices
          # Filter choices by conditions
          @valid_choices = choices.select do |choice|
            conditions = choice.conditions
            if conditions
              conditions.all? { |cond| ActionParser.check_condition(cond) }
            else
              true
            end
          end

          y_offset = 510_f32
          @valid_choices.each_with_index do |choice, i|
            # Add a prefix for unselected choices initially
            text = "  #{choice.text}"
            
            box = GSDL::Message.new(
              text: text,
              x: 400_f32,
              y: y_offset,
              origin: {0.5_f32, 0.0_f32},
              width: 650,
              height: 35,
              color: GSDL::Color::Black,
              border_radius: 4.0_f32
            )
            @choices_boxes << box
            y_offset += 40_f32
          end
        else
          @valid_choices = [] of DialogChoice
        end
      end

      private def select_current_choice
        return if @valid_choices.empty?

        choice = @valid_choices[@selected_choice]
        
        # Execute actions if any
        if actions = choice.actions
          actions.each { |action| ActionParser.execute(action) }
        end

        # Move to next node
        load_node(choice.next_id)
      end

      def update(dt : Float32)
        return unless @is_active

        # Handle input
        if Input.action?(:menu_up)
          @selected_choice -= 1
          @selected_choice = 0 if @selected_choice < 0
        elsif Input.action?(:menu_down)
          max_choice = [@valid_choices.size - 1, 0].max
          @selected_choice += 1
          @selected_choice = max_choice if @selected_choice > max_choice
        elsif Input.action?(:menu_select)
          select_current_choice
        end

        # Update visual selection
        @choices_boxes.each_with_index do |box, i|
          choice = @valid_choices[i]
          if i == @selected_choice
            box.text = "> #{choice.text}"
          else
            box.text = "  #{choice.text}"
          end
        end
      end

      def draw(draw : GSDL::Draw)
        return unless @is_active

        @main_box.draw(draw)
        @choices_boxes.each &.draw(draw)
      end
    end
  end
end
