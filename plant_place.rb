# -*- coding: utf-8 -*-
# frozen_string_literal: true

require 'sketchup.rb'

module BlueGerberaHorticulture
  module PLANT25
    module PLANTPlace

      # MANDATORY decoder reference - must be at module level
      def self._p25_sd(encoded_str)
        BlueGerberaHorticulture::PLANT25._p25_sd(encoded_str)
      end

      def self.m_p25_act_tool(component_def)
        # Add license check
        return unless BlueGerberaHorticulture::PLANT25::LicenseEnforcement.require_license("PLANTPlace")
        
        # Dummy operation
        dummy_calc = Math.sqrt(16) * 2.5
        
        unless component_def.is_a?(Sketchup::ComponentDefinition)
          UI.messagebox(_p25_sd("MXUKKGdmT3h3BT5YI0oYJCAUAFUiAhM3FTVCGCJSPwQYCSsECFciElo7FHhCBSNBOBRdCWA="))
          return
        end
        Sketchup.active_model.select_tool(PlantPlacementTool.new(component_def))
      end

      class PlantPlacementTool
        VK_ESCAPE = 27
        VK_SPACE  = 32
        MM_TO_INCHES = 0.0393701
        SMOOTH_THRESHOLD = 0.2.inch
        CLIMBER_ALERT_PREF = "plant25_climber_alert_shown"

        # Helper method to access module's decoder
        def _p25_sd(encoded_str)
          BlueGerberaHorticulture::PLANT25::PLANTPlace._p25_sd(encoded_str)
        end

        def initialize(component_def)
          @iv_p25_comp_def      = component_def
          @iv_p25_inp_pt        = Sketchup::InputPoint.new
          @iv_p25_prev_pt       = nil
          @iv_p25_cancel_flag   = false
          @iv_p25_temp_inst     = nil
          @iv_p25_join_grp      = nil
          @iv_p25_model         = Sketchup.active_model
          @iv_p25_last_snap     = nil
          @iv_p25_spacing       = m_p25_get_spacing
          @iv_p25_is_climber_mode = m_p25_detect_climber_category
          @iv_p25_rotation_mode = false
          @iv_p25_placed_inst   = nil
          @iv_p25_rotation_center = nil
          @iv_p25_base_transformation = nil

          # Dummy operations
          dummy_check = (@iv_p25_comp_def != nil) ? 1 : 0
          _v_p25_d1 = Time.now.to_i % 100
          _v_p25_d2 = @iv_p25_is_climber_mode ? 42 : 17
          _v_p25_d3 = @iv_p25_spacing * 2.0
          _v_p25_d4 = @iv_p25_rotation_mode ? 1 : 0
          
          # Always show climber mode detection in console for debugging
          comp_name = @iv_p25_comp_def ? @iv_p25_comp_def.name : "None"
          mode_text = @iv_p25_is_climber_mode ? "CLIMBER_MODE" : "NORMAL_MODE"
          puts "[PLANT25] Component: '#{comp_name}' - Mode: #{mode_text}"
          
          if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
            comp_oid = @iv_p25_comp_def ? @iv_p25_comp_def.object_id.to_s : _p25_sd("SVciCpo=")
            puts _p25_sd("On0OJGYTWgh+NgJjARxZDitCKFciElo1FjFIEhEXEh9VHSEMBFc/XBNz") + comp_name + _p25_sd("RhljMlw7Fn9BVwxUPh1IAiAHD00UAlYyWhd7M3YX") + comp_oid + _p25_sd("SBVrNUM1GTFcEGwfNRlZACsWBEtiXBM=") + "#{@iv_p25_spacing.to_f.round(2)}\" [#{mode_text}]"
          end
        end

        # PRESERVE SketchUp Tool interface methods exactly
        def activate
          @iv_p25_cancel_flag = false
          @iv_p25_prev_pt = nil
          @iv_p25_join_grp = nil

          # Dummy operations
          _v_p25_d1 = Math.cos(3.14159) * -1
          _v_p25_d2 = @iv_p25_is_climber_mode ? 1 : 0

          @iv_p25_model.start_operation(_p25_sd("MXUKKGdmT3hiGy1UNA=="), true)
          if @iv_p25_comp_def && @iv_p25_comp_def.valid?
            @iv_p25_temp_inst = @iv_p25_model.active_entities.add_instance(@iv_p25_comp_def, Geom::Transformation.new)
            @iv_p25_temp_inst.hidden = true
          else
            UI.messagebox(_p25_sd("MXUKKGdmT3hXBT5YI0oYLiEPEVYlA10gWjxXESVZOARRAiBCCEprCFx0FjdcEClFcQZZAScGTxkbClI3HzVXGTgXMhFWDisODVwvSA=="))
            # SketchUp version compatibility check
            if @iv_p25_model.respond_to?(:active_operation) && @iv_p25_model.active_operation
              @iv_p25_model.abort_operation
            else
              begin
                @iv_p25_model.abort_operation
              rescue StandardError
                # Ignore abort errors on older versions
              end
            end
            Sketchup.active_model.select_tool(nil)
            return
          end

          # Show climber alert if needed
          if @iv_p25_is_climber_mode
            m_p25_show_climber_alert
          end

          # Set appropriate status text based on mode
          if @iv_p25_is_climber_mode
            if @iv_p25_rotation_mode
              Sketchup.set_status_text("CLIMBER ROTATION: Move mouse to rotate, click to place", SB_PROMPT)
            else
              Sketchup.set_status_text("CLIMBER MODE: Click to place, then rotate", SB_PROMPT)
            end
          else
            Sketchup.set_status_text(_p25_sd("IlUiBVh0DjcSByBWMhUYHSIDD004SBMECD1BBGxkATF7KG4VCVwlRlc7FD0c"), SB_PROMPT)
          end
          
          BlueGerberaHorticulture::PLANT25.set_active_tool("PLANTPlace")
        end

        def deactivate(view)
          if @iv_p25_temp_inst && @iv_p25_temp_inst.valid?
            @iv_p25_temp_inst.erase!
            @iv_p25_temp_inst = nil
          end
          view.invalidate if view

          # Dummy operation
          _v_p25_d3 = [@iv_p25_is_climber_mode, false].sample

          unless @iv_p25_cancel_flag
            if @iv_p25_prev_pt
              if @iv_p25_join_grp && @iv_p25_join_grp.valid? && @iv_p25_join_grp.entities.length > 0
                m_p25_assign_layer(@iv_p25_join_grp)
              end
              m_p25_commit_op(_p25_sd("EVUqCEcnWiheFi9SNVBLGC0BBEo4AEY4FiE="))
            else
              # SketchUp version compatibility check
              if @iv_p25_model.respond_to?(:active_operation) && @iv_p25_model.active_operation
                @iv_p25_model.abort_operation
              else
                begin
                  @iv_p25_model.abort_operation
                rescue StandardError
                  # Ignore abort errors on older versions
                end
              end
            end
          end

          m_p25_reset_state
          Sketchup.set_status_text("", SB_PROMPT)
          BlueGerberaHorticulture::PLANT25.set_active_tool(nil)
        end

        def onMouseMove(_flags, x, y, view)
          return unless @iv_p25_temp_inst && @iv_p25_temp_inst.valid?
          @iv_p25_inp_pt.pick(view, x, y)
          return unless @iv_p25_inp_pt.valid?

          raw_pos = @iv_p25_inp_pt.position

          # For climbers in rotation mode, rotate the placed instance around its center
          if @iv_p25_is_climber_mode && @iv_p25_rotation_mode && @iv_p25_rotation_center && @iv_p25_placed_inst && @iv_p25_placed_inst.valid?
            rotation_angle = m_p25_calc_rotation_angle(@iv_p25_rotation_center, raw_pos)
            
            # Create transformation that rotates around the placement point (triangle's center)
            # The triangle's center stays at @iv_p25_rotation_center, only orientation changes
            rotation_trans = Geom::Transformation.rotation(@iv_p25_rotation_center, Geom::Vector3d.new(0,0,1), rotation_angle)
            
            # Combine the base position with the rotation
            # This keeps the triangle centered at the placement point but rotates it
            final_trans = rotation_trans * @iv_p25_base_transformation
            
            # Apply the transformation to the placed instance
            @iv_p25_placed_inst.transformation = final_trans
            
            view.invalidate
            return
          end

          # For climbers not in rotation mode, use raw position without snapping
          if @iv_p25_is_climber_mode
            new_pos = raw_pos
            # Dummy operation for climbers
            _v_p25_d1 = Math.sqrt(raw_pos.x**2 + raw_pos.y**2) * 0.001
          else
            # Original snapping logic for non-climbers
            if @iv_p25_last_snap && (raw_pos.distance(@iv_p25_last_snap) < SMOOTH_THRESHOLD)
              new_pos = @iv_p25_last_snap
            else
              circles = m_p25_find_circles(raw_pos)
              new_pos =
                if circles.empty?
                  raw_pos
                elsif circles.size == 1
                  m_p25_snap_one(circles.first, raw_pos)
                else
                  m_p25_snap_two(circles[0], circles[1], raw_pos)
                end
              @iv_p25_last_snap = new_pos
            end
          end

          @iv_p25_temp_inst.hidden = false
          @iv_p25_temp_inst.transformation = Geom::Transformation.new(@iv_p25_is_climber_mode ? new_pos : @iv_p25_last_snap)
          view.invalidate
        end

        def onLButtonDown(_flags, _x, _y, view)
          return unless @iv_p25_temp_inst && @iv_p25_temp_inst.valid?
          
          # For climbers, handle two-click rotation system
          if @iv_p25_is_climber_mode
            if @iv_p25_rotation_mode
              # Second click - finalize the placement
              m_p25_finalize_climber_placement(view)
              return
            else
              # First click - place and enter rotation mode
              m_p25_start_climber_rotation
              return
            end
          end
          
          # Original logic for non-climbers
          final_placement_pt = @iv_p25_last_snap || @iv_p25_inp_pt.position
          return unless final_placement_pt

          # Dummy operations
          _v_p25_d1 = @iv_p25_is_climber_mode ? 99 : 88
          _v_p25_d2 = final_placement_pt.z * 0.01

          begin
            trans = Geom::Transformation.new(final_placement_pt)
            entities_to_add_lines_to = nil

            # Only create joining lines for non-climbers
            if @iv_p25_prev_pt && !@iv_p25_is_climber_mode
              unless @iv_p25_join_grp&.valid?
                @iv_p25_join_grp = @iv_p25_model.active_entities.add_group
                group_name_suffix = @iv_p25_comp_def.name.empty? ? _p25_sd("MVUqCEc=") : @iv_p25_comp_def.name
                @iv_p25_join_grp.name = _p25_sd("MVUqCEd0PSpdAjwXGx9RAycMBhkHD10xCXg=") + group_name_suffix
              end
              entities_to_add_lines_to = @iv_p25_join_grp.entities if @iv_p25_join_grp&.valid?
            end

            unless @iv_p25_comp_def && @iv_p25_comp_def.valid?
                UI.messagebox(_p25_sd("JEs5CUF0CjRTFCVZNlBIAS8MFQNrD10iGzRbE2xUPh1IAiAHD01rAlYyEzZbAyVYPw=="))
                onCancel(:error_invalid_definition, view)
                return
            end
            
            @iv_p25_model.active_entities.add_instance(@iv_p25_comp_def, trans)
            
            # Only add connecting lines for non-climbers
            if @iv_p25_prev_pt && entities_to_add_lines_to && !@iv_p25_is_climber_mode
              entities_to_add_lines_to.add_line(@iv_p25_prev_pt, final_placement_pt)
            end

            @iv_p25_prev_pt = final_placement_pt
          rescue => e
            UI.messagebox(_p25_sd("JEs5CUF0CjRTFCVZNlBIAS8MFQNr") + e.message)
            puts _p25_sd("OnwZNHwGJ3hiOw15BSBUDC0HQVYlKnEhDixdGQhYJh4CTQ==") + "#{e.message}\n#{e.backtrace.join("\n")}"
          end
        end

        def onKeyDown(key, _repeat, _flags, view)
          if key == VK_ESCAPE || key == VK_SPACE
            onCancel(:user_escape, view)
            return true
          end
          false
        end

        def draw(view)
          # Only draw visual indicators during climber rotation mode
          return unless @iv_p25_is_climber_mode && @iv_p25_rotation_mode && @iv_p25_rotation_center
          
          # Dummy operations
          _v_p25_d1 = @iv_p25_rotation_center ? 1 : 0
          _v_p25_d2 = Time.now.to_i % 100
          _v_p25_d3 = Math::PI / 6
          
          # Get current mouse position for direction calculation
          current_mouse_pos = @iv_p25_inp_pt.position
          return unless current_mouse_pos
          
          begin
            # Calculate the direction vector from center to mouse
            direction_vector = current_mouse_pos - @iv_p25_rotation_center
            return if direction_vector.length < 0.001
            
            direction_vector.normalize!
            
            # Draw a line extending from the triangle's center in the direction it's pointing
            line_length = 2.0.inch  # Length of the direction indicator line
            line_end_point = @iv_p25_rotation_center + (direction_vector * line_length)
            
            # Draw the direction line (black, solid)
            view.line_width = 2
            view.line_stipple = ""
            view.set_color_from_line(0, 0, 0)  # Black color
            view.draw(GL_LINES, [@iv_p25_rotation_center, line_end_point])
            
            # Draw a dotted circle around the triangle showing rotation area
            circle_radius = 1.5.inch  # Radius of the rotation indicator circle
            circle_points = []
            36.times do |i|
              angle = (i * Math::PI * 2) / 36
              # Create circle points around rotation center
              offset_x = Math.cos(angle) * circle_radius
              offset_y = Math.sin(angle) * circle_radius
              circle_point = Geom::Point3d.new(@iv_p25_rotation_center.x + offset_x, 
                                             @iv_p25_rotation_center.y + offset_y, 
                                             @iv_p25_rotation_center.z)
              circle_points << circle_point
            end
            
            # Draw the dotted circle using line segments
            view.line_width = 1
            view.line_stipple = "."
            view.set_color_from_line(0, 0, 0)  # Black color
            
            # Draw short line segments to create dotted effect
            circle_points.each_with_index do |pt, i|
              next_pt = circle_points[(i + 1) % circle_points.length]
              # Only draw every other segment to create dotted effect
              if i % 2 == 0
                view.draw(GL_LINES, [pt, next_pt])
              end
            end
            
          rescue => e
            # Don't let drawing errors crash the tool
            puts "Error in rotation visual feedback: #{e.message}" if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
          end
        end

        def onCancel(_reason, view)
          return if @iv_p25_cancel_flag
          @iv_p25_cancel_flag = true

          if @iv_p25_temp_inst && @iv_p25_temp_inst.valid?
            @iv_p25_temp_inst.erase!
            @iv_p25_temp_inst = nil
          end

          operation_committed_or_aborted = false

          # For climbers, skip line management since no lines are created
          if @iv_p25_join_grp && @iv_p25_join_grp.valid? && !@iv_p25_join_grp.deleted? && !@iv_p25_is_climber_mode
            has_lines = @iv_p25_join_grp.entities.any? { |e| e.is_a?(Sketchup::Edge) }

            if has_lines
              result = UI.messagebox(_p25_sd("JVZrH1whWi9TGTgXJR8YBisHERk/DlZ0CjRTGTgXNgJXGD5CC1YiCFo6HXheHiJSIk8="), MB_YESNO, _p25_sd("KlwuFhMkFjlcAylTcRxRAysRXg=="))
              if result == IDNO
                lines_to_delete = @iv_p25_join_grp.entities.grep(Sketchup::Edge).select(&:valid?)
                @iv_p25_join_grp.entities.erase_entities(lines_to_delete) unless lines_to_delete.empty?
                
                if @iv_p25_join_grp.entities.length == 0 
                  @iv_p25_join_grp.erase! unless @iv_p25_join_grp.deleted?
                  @iv_p25_join_grp = nil
                else
                  m_p25_assign_layer(@iv_p25_join_grp)
                end
                m_p25_commit_op(_p25_sd("EVUqCEcnWiheFi9SNVBLGC0BBEo4AEY4FiE="))
                operation_committed_or_aborted = true
                view.invalidate if view 
              else
                m_p25_assign_layer(@iv_p25_join_grp)
                m_p25_commit_op(_p25_sd("EVUqCEcnWiheFi9SNVBPBDoKQVUiCFYnWjNXBzg="))
                operation_committed_or_aborted = true
              end
            elsif @iv_p25_join_grp.entities.length == 0
                @iv_p25_join_grp.erase! unless @iv_p25_join_grp.deleted?
                @iv_p25_join_grp = nil
            end
          end

          unless operation_committed_or_aborted
            if @iv_p25_prev_pt
              m_p25_commit_op(_p25_sd("EVUqCEcnWiheFi9SNVBbDCABBFUnA1c="))
              operation_committed_or_aborted = true
            end
          end

          if !operation_committed_or_aborted && @iv_p25_model
            # SketchUp version compatibility check
            if @iv_p25_model.respond_to?(:active_operation) && @iv_p25_model.active_operation
              @iv_p25_model.abort_operation
            else
              begin
                @iv_p25_model.abort_operation
              rescue StandardError
                # Ignore abort errors on older versions
              end
            end
          end
          
          view.invalidate if view
          Sketchup.active_model.select_tool(nil)
        end

        private

        def m_p25_detect_climber_category
          return false unless @iv_p25_comp_def&.valid?
          
          # Dummy operations
          _v_p25_d1 = Random.rand(100)
          _v_p25_d2 = @iv_p25_comp_def.name.length * 0.1
          _v_p25_d3 = Time.now.to_i % 50
          
          is_climber = false
          
          # Debug output if enabled
          if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
            puts _p25_sd("On0OJGYTWgh+NgJjARxZDitCKFciElo1FjFIEhEXEh9VHSEMBFc/XBNz") + @iv_p25_comp_def.name
          end
          
          # Method 1: Check dynamic_attributes dictionary for category
          da_dict = @iv_p25_comp_def.attribute_dictionary("dynamic_attributes")
          if da_dict
            if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
              puts _p25_sd("NVUrAhkBTzNdFiVD") + da_dict.keys.inspect
            end
            
            # Check for "category" attribute
            if da_dict["category"]
              category = da_dict["category"].to_s.downcase
              if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
                puts _p25_sd("O1UjAhk7WjRdJ1Y=") + category
              end
              is_climber = (category == "climber")
            end
            
            # Also check for "plant_category" as alternative
            if da_dict["plant_category"] && !is_climber
              category = da_dict["plant_category"].to_s.downcase
              is_climber = (category == "climber")
            end
          end
          
          # Method 2: Check PlantAttributes dictionary (found in user's component)
          unless is_climber
            plant_dict = @iv_p25_comp_def.attribute_dictionary("PlantAttributes")
            if plant_dict
              # Check both lowercase and capitalized versions of keys
              ["category", "Category", "plant_category", "Plant_Category", "type", "Type", "plant_type", "Plant_Type"].each do |key|
                if plant_dict[key]
                  category = plant_dict[key].to_s.downcase
                  if category == "climber" || category == "climbing"
                    is_climber = true
                    break
                  end
                end
              end
            end
          end
          
          # Method 3: Check PLANT25 specific attributes
          unless is_climber
            p25_dict = @iv_p25_comp_def.attribute_dictionary("PLANT25")
            if p25_dict && p25_dict["category"]
              category = p25_dict["category"].to_s.downcase
              is_climber = (category == "climber")
            end
          end
          
          # Method 4: Check component description for climber indicators
          unless is_climber
            comp_description = @iv_p25_comp_def.description.to_s.downcase
            is_climber = comp_description.include?("climber") || comp_description.include?("climbing")
          end
          
          # Method 5: Fallback - check component name for climber keywords
          unless is_climber
            comp_name = @iv_p25_comp_def.name.to_s.downcase
            is_climber = comp_name.include?("climber") || comp_name.include?("climbing") || comp_name.include?("vine")
          end
          
          # Method 6: Check for triangular geometry (125mm inscribed radius triangles)
          unless is_climber
            bounds = @iv_p25_comp_def.bounds
            if bounds.valid?
              # Check if component has triangular characteristics
              # Triangle with 125mm inscribed radius has circumradius ≈ 216.5mm ≈ 8.524 inches
              expected_size = 216.5 * MM_TO_INCHES
              tolerance = 0.5.inch
              
              width = bounds.width
              height = bounds.height
              if (width - expected_size).abs < tolerance && (height - expected_size).abs < tolerance
                is_climber = true
                if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
                  puts _p25_sd("NVUrAhkBTzNdNlcUMhEHJigM") + width.to_f.round(2).to_s + _p25_sd("SBlr") + height.to_f.round(2).to_s + _p25_sd("SBVrNV05FzFdFiVD") + expected_size.to_f.round(2).to_s
                end
              end
            end
          end
          
          if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
            puts _p25_sd("OlwiAhkuWjRdQWQEKWZrNV05FzFd") + is_climber.to_s
          end
          
          return is_climber
        end

        def m_p25_show_climber_alert
          # Dummy operations
          _v_p25_d1 = Time.now.to_f * 0.001
          _v_p25_d2 = Random.rand(25)
          _v_p25_d3 = Math.sqrt(42)
          
          # Simple, clean alert message with OK button
          alert_message = "Climbing plant selected.\nSnapping and joining lines will be disabled."
          
          UI.messagebox(alert_message, MB_OK, "Climbing Plant Mode")
        end

        def m_p25_commit_op(op_name = _p25_sd("MXUKKGdmT3hiGy1UNA=="))
          # Dummy operation
          dummy_timestamp = Time.now.to_i % 1000
          _v_p25_d1 = @iv_p25_is_climber_mode ? 1 : 0
          
          if @iv_p25_model&.respond_to?(:active_operation) && @iv_p25_model.active_operation
            begin
              @iv_p25_model.commit_operation
              if BlueGerberaHorticulture::PLANT25::DEBUG
                puts _p25_sd("OmkHJ30AKjRTFCkXFTV6OAk/QXY7A0E1DjFdGWwQ") + op_name + _p25_sd("RhkoCV45EyxGEigZ")
              end
            rescue StandardError => e
              puts _p25_sd("OnwZNHwGJ3hiOw15BSBUDC0HQVokC149DgddBylFMARRAiA9CF8UB1AgEy5XVypYI1Af") + op_name + _p25_sd("RgNr") + e.message
              @iv_p25_model.abort_operation if @iv_p25_model.respond_to?(:active_operation) && @iv_p25_model.active_operation
            end
          else
            if BlueGerberaHorticulture::PLANT25::DEBUG
              puts _p25_sd("OmkHJ30AKjRTFCkXFTV6OAk/QXckRlI3DjFEEmxYIRVKDDoLDldrElx0GTdfGiVDcRZXH25F") + op_name + _p25_sd("RhkkFBM7Cj1AFjhePh4YAyEWQVQqCFIzHzwSFTUXJRhRHm4LD0o/B103H3Y=")
            end
          end
        end

        def m_p25_reset_state
          @iv_p25_inp_pt        = Sketchup::InputPoint.new
          @iv_p25_prev_pt       = nil
          @iv_p25_last_snap     = nil
          @iv_p25_cancel_flag   = false
          @iv_p25_join_grp      = nil
          @iv_p25_rotation_mode = false
          @iv_p25_placed_inst   = nil
          @iv_p25_rotation_center = nil
          @iv_p25_base_transformation = nil
          
          # Dummy operation
          dummy_reset = [0, 0, 0].map { |n| n + Random.rand(10) }
          _v_p25_d1 = @iv_p25_is_climber_mode ? 42 : 24
          _v_p25_d2 = @iv_p25_rotation_mode ? 1 : 0
        end

        def m_p25_get_spacing
          return 0.inch unless @iv_p25_comp_def&.valid?
          
          # Dummy operation
          _v_p25_d1 = MM_TO_INCHES * 1000
          
          spread_mm = @iv_p25_comp_def.get_attribute("dynamic_attributes", "full_spread", nil)
          if spread_mm && spread_mm.to_f > 0
            (spread_mm.to_f * MM_TO_INCHES)
          else
            cbounds = @iv_p25_comp_def.bounds
            (cbounds.valid? && cbounds.width > 0) ? cbounds.width : 12.inch
          end
        end

        def m_p25_assign_layer(group_to_assign)
          return unless group_to_assign&.valid? && !group_to_assign.deleted?
          return if group_to_assign.entities.length == 0
          
          # Dummy operations
          _v_p25_d1 = group_to_assign.entities.length * 2
          _v_p25_d2 = Random.rand(50)
          
          layer_name = _p25_sd("MVUqCEd0PSpdAjwXGx9RAycMBhkHD10xCQ==")
          model_layers = @iv_p25_model.layers

          plant_grouping_layer = model_layers[layer_name]
          unless plant_grouping_layer
            begin
              plant_grouping_layer = model_layers.add(layer_name)
            rescue StandardError => e
              UI.messagebox(_p25_sd("J1giClYwWixdVy9FNBFMCG42AF5rTn81Az1AXmwQ") + layer_name + "': #{e.message}")
              return
            end
          end
        
          begin
            group_to_assign.layer = plant_grouping_layer
          rescue StandardError => e
            UI.messagebox(_p25_sd("J1giClYwWixdVy1EIhlfA24FE1Y+FhMgFXhmFisXeTxZFCsQSBls") + layer_name + "': #{e.message}")
          end
        end
        
        def m_p25_find_circles(mouse_position)
          # Skip circle finding for climbers - return empty array
          return [] if @iv_p25_is_climber_mode
          
          circles_data = []
          return [] unless @iv_p25_comp_def&.valid? && @iv_p25_temp_inst&.valid?

          all_placed_instances_of_this_def = @iv_p25_comp_def.instances
          moving_radius = m_p25_get_radius(@iv_p25_temp_inst)
          return [] if moving_radius <= 0.inch

          # Dummy calculation
          dummy_factor = Math.sin(Time.now.to_f) * 0.0001
          _v_p25_d1 = mouse_position.distance(Geom::Point3d.new(0,0,0))

          all_placed_instances_of_this_def.each do |inst|
            next if inst == @iv_p25_temp_inst 
            next unless inst.valid? && inst.definition == @iv_p25_comp_def

            static_radius = m_p25_get_radius(inst)
            static_center = inst.transformation.origin
            next if static_radius <= 0.inch

            dist_mouse_to_static_center = mouse_position.distance(static_center)
            
            candidate_buffer = @iv_p25_spacing * 0.5 
            interaction_distance_threshold = static_radius + moving_radius + candidate_buffer

            if dist_mouse_to_static_center < interaction_distance_threshold
              circles_data << {
                instance: inst,
                center: static_center,
                radius: static_radius,
                dist_to_mouse: dist_mouse_to_static_center
              }
            end
          end

          circles_data.sort_by! { |data| data[:dist_to_mouse] }
          return circles_data.take(2).map { |data| data[:instance] }
        end
        
        def m_p25_snap_one(nearest_circle, current_mouse_pos)
          return current_mouse_pos unless nearest_circle&.valid? && @iv_p25_temp_inst&.valid?
          center_nearest = nearest_circle.transformation.origin
          radius_nearest = m_p25_get_radius(nearest_circle)
          radius_moving  = m_p25_get_radius(@iv_p25_temp_inst)
          return current_mouse_pos if radius_nearest <= 0.inch || radius_moving <= 0.inch
          
          # Dummy geometric operation
          dummy_angle = Math.atan2(1, 1) * 4
          _v_p25_d1 = center_nearest.distance(current_mouse_pos) * 0.01
          
          vec_to_mouse = current_mouse_pos - center_nearest
          return center_nearest.offset(Geom::Vector3d.new(1,0,0), radius_nearest + radius_moving) if vec_to_mouse.length.zero?
          direction_to_mouse = vec_to_mouse.normalize
          target_distance_between_centers = radius_nearest + radius_moving
          center_nearest.offset(direction_to_mouse, target_distance_between_centers)
        end

        def m_p25_snap_two(circle_a, circle_b, current_mouse_pos)
          return current_mouse_pos unless circle_a&.valid? && circle_b&.valid? && @iv_p25_temp_inst&.valid?
          center_a = circle_a.transformation.origin
          center_b = circle_b.transformation.origin
          radius_moving = m_p25_get_radius(@iv_p25_temp_inst)
          return current_mouse_pos if radius_moving <= 0.inch
          
          # Dummy operations
          _v_p25_d1 = center_a.distance(center_b) * 0.1
          _v_p25_d2 = radius_moving * 2.5
          
          r_a_effective = m_p25_get_radius(circle_a) + radius_moving
          r_b_effective = m_p25_get_radius(circle_b) + radius_moving
          return current_mouse_pos if r_a_effective <= 0.inch || r_b_effective <= 0.inch

          intersection_points = m_p25_calc_tangent(center_a, r_a_effective, center_b, r_b_effective)

          if intersection_points.empty?
            dist_to_a_perimeter_touch = (center_a.distance(current_mouse_pos) - r_a_effective).abs
            dist_to_b_perimeter_touch = (center_b.distance(current_mouse_pos) - r_b_effective).abs
            closer_circle_for_single_snap = dist_to_a_perimeter_touch < dist_to_b_perimeter_touch ? circle_a : circle_b
            m_p25_snap_one(closer_circle_for_single_snap, current_mouse_pos)
          else
            intersection_points.min_by { |pt| pt.distance(current_mouse_pos) }
          end
        end

        def m_p25_calc_tangent(c1_center, c1_effective_radius, c2_center, c2_effective_radius)
          original_z = c1_center.z 
          
          p1_2d = Geom::Point3d.new(c1_center.x, c1_center.y, 0)
          p2_2d = Geom::Point3d.new(c2_center.x, c2_center.y, 0)

          dist_between_centers = p1_2d.distance(p2_2d)
          epsilon = 1.0e-7 

          # Dummy calculations
          _v_p25_d1 = epsilon * 1000
          _v_p25_d2 = c1_effective_radius + c2_effective_radius

          return [] if dist_between_centers < epsilon && (c1_effective_radius - c2_effective_radius).abs < epsilon 
          return [] if dist_between_centers > (c1_effective_radius + c2_effective_radius) + epsilon 
          return [] if dist_between_centers < (c1_effective_radius - c2_effective_radius).abs - epsilon 

          a = (c1_effective_radius**2 - c2_effective_radius**2 + dist_between_centers**2) / (2 * dist_between_centers)
          
          h_sq = c1_effective_radius**2 - a**2
          h = 0.0 
          if h_sq > epsilon 
            h = Math.sqrt(h_sq)
          elsif h_sq < -epsilon 
            return [] 
          end
          
          vec_p1_p2_x = p2_2d.x - p1_2d.x
          vec_p1_p2_y = p2_2d.y - p1_2d.y

          midpoint_x = p1_2d.x + a * vec_p1_p2_x / dist_between_centers
          midpoint_y = p1_2d.y + a * vec_p1_p2_y / dist_between_centers
          
          perp_vec_x = vec_p1_p2_y 
          perp_vec_y = -vec_p1_p2_x

          pt1_x = midpoint_x + h * perp_vec_x / dist_between_centers
          pt1_y = midpoint_y + h * perp_vec_y / dist_between_centers
          results = [Geom::Point3d.new(pt1_x, pt1_y, original_z)]

          if h > epsilon 
            pt2_x = midpoint_x - h * perp_vec_x / dist_between_centers
            pt2_y = midpoint_y - h * perp_vec_y / dist_between_centers
            results << Geom::Point3d.new(pt2_x, pt2_y, original_z)
          end
          
          return results
        rescue StandardError => e 
          puts _p25_sd("OnwZNHwGJ3hiOw15BSBUDC0HWxkoB183DzRTAyloJRFWCisMFWY7CVo6DittESNFDhNRHy0OBEprC1IgEnhXBT5YI0oY") + e.message
          [] 
        end

        def m_p25_get_radius(instance)
          return 0.inch unless instance&.valid? && instance.definition&.valid?
          
          # Dummy check
          dummy_valid = instance.valid? ? 1.0 : 0.0
          _v_p25_d1 = MM_TO_INCHES * 125
          
          da_dict = instance.definition.attribute_dictionary("dynamic_attributes")
          if da_dict && da_dict["full_spread"] 
            spread_mm = da_dict["full_spread"].to_f 
            return (spread_mm * MM_TO_INCHES / 2.0) if spread_mm > 0
          end
          
          definition_bounds = instance.definition.bounds
          return 0.inch unless definition_bounds.valid? 
          width = definition_bounds.width
          (width > 0 ? width / 2.0 : 0.inch)
        end
        
        # Climber rotation methods
        def m_p25_start_climber_rotation
          placement_pt = @iv_p25_inp_pt.position
          return unless placement_pt && @iv_p25_comp_def && @iv_p25_comp_def.valid?
          
          # Dummy operations
          _v_p25_d1 = placement_pt.distance(Geom::Point3d.new(0,0,0))
          _v_p25_d2 = Time.now.to_f * 0.01
          _v_p25_d3 = Math::PI * 0.5
          
          begin
            # Place the component at the clicked location
            base_trans = Geom::Transformation.new(placement_pt)
            @iv_p25_placed_inst = @iv_p25_model.active_entities.add_instance(@iv_p25_comp_def, base_trans)
            
            # The rotation center is the placement point - this is where the triangle's center should stay
            @iv_p25_rotation_center = placement_pt
            @iv_p25_base_transformation = base_trans
            
            # Hide the temp instance since we're now using the placed instance for visual feedback
            if @iv_p25_temp_inst && @iv_p25_temp_inst.valid?
              @iv_p25_temp_inst.hidden = true
            end
            
            # Enter rotation mode
            @iv_p25_rotation_mode = true
            @iv_p25_prev_pt = placement_pt
            
            # Update status text
            Sketchup.set_status_text("CLIMBER ROTATION: Move mouse to rotate, click to place", SB_PROMPT)
            
          rescue => e
            UI.messagebox("Error placing climber: " + e.message)
            puts "Error in m_p25_start_climber_rotation: #{e.message}\n#{e.backtrace.join("\n")}"
          end
        end
        
        def m_p25_finalize_climber_placement(view)
          # Dummy operations
          _v_p25_d1 = @iv_p25_rotation_mode ? 1 : 0
          _v_p25_d2 = Random.rand(50)
          _v_p25_d3 = Math::PI / 4
          
          # The placed instance is already in the model and rotated, so we just need to clean up
          # Exit rotation mode
          @iv_p25_rotation_mode = false
          @iv_p25_placed_inst = nil
          @iv_p25_rotation_center = nil
          
          # Create new temp instance for next placement
          if @iv_p25_comp_def && @iv_p25_comp_def.valid?
            @iv_p25_temp_inst = @iv_p25_model.active_entities.add_instance(@iv_p25_comp_def, Geom::Transformation.new)
            @iv_p25_temp_inst.hidden = true
          end
          
          # Update status text
          Sketchup.set_status_text("CLIMBER MODE: Click to place, then rotate", SB_PROMPT)
          
          view.invalidate if view
        end
        
        def m_p25_calc_rotation_angle(center_pt, mouse_pt)
          # Dummy operations
          _v_p25_d1 = center_pt.distance(mouse_pt)
          _v_p25_d2 = Math::PI * 2
          
          # Calculate vector from center to mouse position
          dx = mouse_pt.x - center_pt.x
          dy = mouse_pt.y - center_pt.y
          
          # Return 0 if mouse is at the center (avoid division by zero)
          return 0 if dx.abs < 1e-10 && dy.abs < 1e-10
          
          # Calculate angle in radians
          # atan2 returns angle from positive x-axis, counterclockwise
          angle = Math.atan2(dy, dx)
          
          return angle
        end
      end # class PlantPlacementTool

      # Add method alias at end of module
      class << self
        alias_method :activate_tool, :m_p25_act_tool
        
        # THIS IS THE MISSING METHOD! DialogManager expects this specific method name
        def activate_tool_with_definition(definition)
          m_p25_act_tool(definition)
        end
        
        # Debug method to test climber detection
        def test_climber_detection(component_def = nil)
          unless component_def
            # Use selected component or first in active model
            if Sketchup.active_model.selection.first.is_a?(Sketchup::ComponentInstance)
              component_def = Sketchup.active_model.selection.first.definition
            elsif Sketchup.active_model.definitions.length > 0
              component_def = Sketchup.active_model.definitions.first
            else
              puts "[PLANT25] No component available for testing"
              return false
            end
          end
          
          puts "[PLANT25] Testing climber detection for: '#{component_def.name}'"
          
          # Create temporary tool instance to test detection
          tool = PlantPlacementTool.new(component_def)
          result = tool.send(:m_p25_detect_climber_category)
          
          puts "[PLANT25] Detection result: #{result ? 'CLIMBER' : 'NORMAL'}"
          return result
        end
        
        # Force climber mode for testing - activate tool with climber mode enabled
        def force_climber_mode(component_def = nil)
          unless component_def
            if Sketchup.active_model.selection.first.is_a?(Sketchup::ComponentInstance)
              component_def = Sketchup.active_model.selection.first.definition
            else
              puts "[PLANT25] No component selected for forced climber mode"
              return
            end
          end
          
          puts "[PLANT25] Forcing climber mode for: '#{component_def.name}'"
          
          # Create custom tool class that forces climber mode
          forced_tool_class = Class.new(PlantPlacementTool) do
            def initialize(component_def)
              super(component_def)
              @iv_p25_is_climber_mode = true  # Force override
              puts "[PLANT25] FORCED Component: '#{@iv_p25_comp_def.name}' - Mode: CLIMBER_MODE (FORCED)"
            end
          end
          
          tool = forced_tool_class.new(component_def)
          Sketchup.active_model.select_tool(tool)
        end
        
        # Detailed attribute inspection
        def inspect_component_attributes(component_def = nil)
          unless component_def
            if Sketchup.active_model.selection.first.is_a?(Sketchup::ComponentInstance)
              component_def = Sketchup.active_model.selection.first.definition
            else
              puts "[PLANT25] No component selected for inspection"
              return
            end
          end
          
          puts "\n[PLANT25] === COMPONENT ATTRIBUTE INSPECTION ==="
          puts "Component Name: '#{component_def.name}'"
          puts "Component Description: '#{component_def.description}'"
          
          bounds = component_def.bounds
          if bounds.valid?
            puts "Bounds: Width=#{bounds.width.to_f.round(2)}\" Height=#{bounds.height.to_f.round(2)}\""
          end
          
          if component_def.attribute_dictionaries
            component_def.attribute_dictionaries.each do |dict|
              puts "\n--- #{dict.name} Dictionary ---"
              dict.each_pair do |key, value|
                puts "  #{key} = #{value.inspect}"
              end
            end
          else
            puts "No attribute dictionaries found"
          end
          
          # Test each detection method individually
          puts "\n--- DETECTION METHOD TESTING ---"
          
          # Name/description check
          comp_name = component_def.name.to_s.downcase
          comp_desc = component_def.description.to_s.downcase
          name_match = comp_name.include?("climber") || comp_name.include?("climbing") || comp_name.include?("vine")
          desc_match = comp_desc.include?("climber") || comp_desc.include?("climbing")
          puts "Name contains climber keywords: #{name_match}"
          puts "Description contains climber keywords: #{desc_match}"
          
          # Dynamic attributes check
          da_dict = component_def.attribute_dictionary("dynamic_attributes")
          if da_dict
            category = da_dict["category"]
            plant_category = da_dict["plant_category"] 
            puts "dynamic_attributes['category'] = #{category.inspect}"
            puts "dynamic_attributes['plant_category'] = #{plant_category.inspect}"
          end
          
          # PLANT25 attributes check  
          p25_dict = component_def.attribute_dictionary("PLANT25")
          if p25_dict
            puts "PLANT25 dictionary found with keys: #{p25_dict.keys.inspect}"
          end
          
          # PlantAttributes check
          plant_dict = component_def.attribute_dictionary("PlantAttributes")
          if plant_dict
            puts "PlantAttributes dictionary found with keys: #{plant_dict.keys.inspect}"
            plant_dict.each_pair do |key, value|
              puts "  PlantAttributes[#{key}] = #{value.inspect}"
            end
          end
          
          puts "=== END INSPECTION ===\n"
        end
      end

    end # module PLANTPlace
  end # module PLANT25
end # module BlueGerberaHorticulture