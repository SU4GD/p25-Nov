# -*- coding: utf-8 -*-
# frozen_string_literal: true

require 'sketchup.rb'

module BlueGerberaHorticulture
  module PLANT25
    module PLANTPath

      def self._p25_sd(encoded_str)
        BlueGerberaHorticulture::PLANT25._p25_sd(encoded_str)
      end

      VK_ESCAPE    = 27
      VK_SPACE     = 32
      MM_TO_INCHES = 0.0393701

def self.m_p25_atwdp(component_def)
  # Add license check
  return unless BlueGerberaHorticulture::PLANT25::LicenseEnforcement.require_license("PLANTPath")
  
  _v_p25_d1 = Sketchup.active_model.guid; _v_p25_d2 = component_def.entityID rescue 0; _v_p25_d3 = "atwdp_#{_v_p25_d2}"
  # ... rest of existing code
        unless component_def.is_a?(Sketchup::ComponentDefinition)
          UI.messagebox("PLANTPath Error: Expected a ComponentDefinition but received #{component_def.class}. Please ensure you have selected a valid plant component from the library.")
          return
        end
        _v_p25_d4 = component_def.valid?
        puts _p25_sd("On0uBEYzJwNiOw15BSBZGSY/QXgoEloiGyxbGSsXARxZAzoyAE0jMlw7FnhFHjhfcRNXAD4ND1wlEgl0") + component_def.name if BlueGerberaHorticulture::PLANT25::DEBUG

        Sketchup.active_model.select_tool(PlantPathTool.new(component_def))
        BlueGerberaHorticulture::PLANT25.set_active_tool("PLANTPath") 
        _v_p25_d5 = Sketchup.active_model.active_path.nil?
      end

      class PlantPathTool
        def initialize(component_def)
          _v_p25_d1 = component_def.name.length; _v_p25_d2 = self.class.name; _v_p25_d3 = "init_path_tool_#{_v_p25_d1}"
          @component_def           = component_def
          @spacing_in_inches       = m_p25_fs 
          @segment_start           = nil
          @mouse_ip                = Sketchup::InputPoint.new
          @ghost_positions         = []
          @plant_positions         = []
          @placing_first_plant     = true
          @joining_group           = nil
          @previous_plant_position = nil
          @operation_started       = false 
          _v_p25_d4 = @ghost_positions.object_id 

          puts _p25_sd("On0uBEYzJwNiOw15BSBZGSY/QWknB10gKjlGHxhYPhwYBCALFVAqClouHzwSACVDOVBLHS8BCFcsWw==") + @spacing_in_inches.round(2).to_s + _p25_sd("QVAlBVsxCXY=") if BlueGerberaHorticulture::PLANT25::DEBUG
          _v_p25_d5 = @plant_positions.empty? 
        end

        def activate
          @model = Sketchup.active_model
          
          @segment_start           = nil
          @ghost_positions.clear
          @mouse_ip.clear
          @plant_positions.clear
          @placing_first_plant     = true
          @joining_group           = nil 
          @previous_plant_position = nil 
          @operation_started       = false 

          Sketchup.set_status_text("Click to place first plant", SB_PROMPT)
          puts _p25_sd("On0uBEYzJwNiOw15BSBZGSY/QWknB10gKjlGHxhYPhwYDC0WCE8qElYwVA==") if BlueGerberaHorticulture::PLANT25::DEBUG
        end

        def deactivate(view)
          view.invalidate if @ghost_positions.any?
          if @operation_started
            puts _p25_sd("On0uBEYzJwNiOw15BSBZGSY/QX0uB1AgEy5TAylTcQdRGSZCDkkuFFIgEzdcVy1UJRlOCGBCIFskFEc9FD8SGDxSIxFMBCEMTw==") if BlueGerberaHorticulture::PLANT25::DEBUG
            @model.abort_operation
            @operation_started = false
          end
          Sketchup.set_status_text("", SB_PROMPT)
          puts _p25_sd("On0uBEYzJwNiOw15BSBZGSY/QWknB10gKjlGHxhYPhwYCSsDAk0iEFIgHzwc") if BlueGerberaHorticulture::PLANT25::DEBUG
          BlueGerberaHorticulture::PLANT25.set_active_tool(nil)
        end
        
        def suspend(view)
          view.invalidate if @ghost_positions.any?
          puts _p25_sd("On0uBEYzJwNiOw15BSBZGSY/QWknB10gKjlGHxhYPhwYHjsREVwlAlYwVA==") if BlueGerberaHorticulture::PLANT25::DEBUG
        end

        def resume(view)
          status_msg = @placing_first_plant ? "Click to place first plant" : "Click to place plants along path"
          Sketchup.set_status_text(status_msg, SB_PROMPT)
          view.invalidate
          puts _p25_sd("On0uBEYzJwNiOw15BSBZGSY/QWknB10gKjlGHxhYPhwYHysRFFQuAh0=") if BlueGerberaHorticulture::PLANT25::DEBUG
        end

        def onMouseMove(_flags, x, y, view)
          @mouse_ip.pick(view, x, y)
          if !@placing_first_plant && @segment_start && @mouse_ip.valid?
            m_p25_ugp(@segment_start, @mouse_ip.position) 
          else
            @ghost_positions.clear 
          end
          view.invalidate
        end

        def onLButtonUp(_flags, x, y, view)
          unless @operation_started
            @model.start_operation("PLANTPath", true)
            @operation_started = true
            puts _p25_sd("On0uBEYzJwNiOw15BSBZGSY/QXY7A0E1DjFdGWxEJRFKGSsGQVYlRlU9CCtGVwB1JARMAiA3ERc=") if BlueGerberaHorticulture::PLANT25::DEBUG
          end

          @mouse_ip.pick(view, x, y)
          return unless @mouse_ip.valid?

          click_pt = @mouse_ip.position
          if @placing_first_plant
            m_p25_pfp(click_pt) 
            @segment_start       = click_pt
            @placing_first_plant = false 
            Sketchup.set_status_text("Click to continue path. Press SPACE or ESC to finish.", SB_PROMPT)
          else
            return unless @segment_start 
            
            puts _p25_sd("On0uBEYzJwNiOw15BSBZGSY/QXo5A1IgEzZVVyJSJlBIDDoKQUouAV4xFCwSET5YPFA=") + @segment_start.to_s + _p25_sd("QU0kRg==") + click_pt.to_s + _p25_sd("Rhc=") if BlueGerberaHorticulture::PLANT25::DEBUG
            snapped_end = m_p25_pss(@segment_start, click_pt) 
            @segment_start = snapped_end 
            Sketchup.set_status_text("Continue clicking to extend path, or press SPACE/ESC to finish", SB_PROMPT)
          end
          view.invalidate
        end

        def onKeyDown(key, _repeat, _flags, _view) 
          if key == VK_ESCAPE || key == VK_SPACE
            m_p25_fta 
            return true 
          end
          false 
        end
        
        def draw(view)
          if !@placing_first_plant && @segment_start && @mouse_ip.valid?
            line_color = Sketchup::Color.new(76, 109, 114) 
            view.drawing_color = line_color
            view.line_width    = 2
            view.line_stipple  = "" 
            view.draw(GL_LINE_STRIP, [@segment_start, @mouse_ip.position])
          end
          m_p25_dgp(view) 
        end
        
        def m_p25_fta 
          _v_p25_d1 = @plant_positions.count; _v_p25_d2 = @joining_group.nil?; _v_p25_d3 = "fta_#{@operation_started}"
          puts _p25_sd("On0uBEYzJwNiOw15BSBZGSY/QV8iCFonEgdGGCNbDhFbGScNDxkoB184Hzwc") if BlueGerberaHorticulture::PLANT25::DEBUG
          
          unless @operation_started
            puts _p25_sd("On0uBEYzJwNiOw15BSBZGSY/QXckRlwkHypTAyVYP1BLGS8QFVwvShMxAjFGHiJQcQRXAiJM") if BlueGerberaHorticulture::PLANT25::DEBUG
            Sketchup.active_model.select_tool(nil) 
            Sketchup.set_status_text("", SB_PROMPT)
            return
          end
          _v_p25_d4 = @joining_group.guid if @joining_group && !@joining_group.deleted? 

          ask_about_lines = @plant_positions.size >= 1 && 
                            @joining_group && 
                            !@joining_group.deleted? && 
                            @joining_group.entities.length > 0

          if ask_about_lines
            choice = UI.messagebox(_p25_sd("JVZrH1whWi9TGTgXJR8YBisHERk/DlZ0CjRTGTgXNgJXGD5CC1YiCFo6HXheHiJSIk8="), MB_YESNO, _p25_sd("KlwuFhMEFjlcA2xwIx9NHW4oDlAlD10zWhRbGSlEbg=="))
            if choice == IDNO 
              @joining_group.erase! unless @joining_group.deleted?
              puts _p25_sd("On0uBEYzJwNiOw15BSBZGSY/QXMkD109FD8SGyVZNAMYHysPDk8uAhM2A3hHBClFfw==") if BlueGerberaHorticulture::PLANT25::DEBUG
            else 
              m_p25_ajgtl 
              puts _p25_sd("On0uBEYzJwNiOw15BSBZGSY/QXMkD109FD8SGyVZNAMYBisSFRkpHxMhCT1AWQ==") if BlueGerberaHorticulture::PLANT25::DEBUG
            end
          elsif @plant_positions.empty? && @joining_group && !@joining_group.deleted?
            @joining_group.erase! unless @joining_group.deleted?
            puts _p25_sd("On0uBEYzJwNiOw15BSBZGSY/QXonA1I6HzwSAjwXNB1IGTdCC1YiCFo6HXhVBSNCIV4=") if BlueGerberaHorticulture::PLANT25::DEBUG
          else
            puts _p25_sd("On0uBEYzJwNiOw15BSBZGSY/QXckRlk7EzZbGSsXPRlWCD1CFVZrC1I6Gz9XWQ==") if BlueGerberaHorticulture::PLANT25::DEBUG
          end

          if @plant_positions.empty? 
            @model.abort_operation
            puts _p25_sd("On0uBEYzJwNiOw15BSBZGSY/QXY7A0E1DjFdGWxWMx9KGSsGQVg4Rl07WiheFiJDIlBPCDwHQUknB1AxHnY=") if BlueGerberaHorticulture::PLANT25::DEBUG
          else
            @model.commit_operation
            puts _p25_sd("On0uBEYzJwNiOw15BSBZGSY/QXY7A0E1DjFdGWxUPh1VBDoWBF1l") if BlueGerberaHorticulture::PLANT25::DEBUG
          end
          @operation_started = false 
          _v_p25_d5 = @model.entities.count 

          Sketchup.active_model.select_tool(nil) 
          Sketchup.set_status_text("", SB_PROMPT)
          puts _p25_sd("On0uBEYzJwNiOw15BSBZGSY/QW0kCV90HDFcHj9fNBQYDCAGQV0uFVY4HztGEigZ") if BlueGerberaHorticulture::PLANT25::DEBUG
        end

        private 

        def m_p25_fs 
          _v_p25_d1 = @component_def.guid; _v_p25_d2 = @component_def.name.sum; _v_p25_d3 = "fs_#{@component_def.entityID}"
          spread_mm_attr = @component_def.get_attribute("dynamic_attributes", "full_spread") 
          if spread_mm_attr.is_a?(Numeric) && spread_mm_attr > 0
            spacing = spread_mm_attr * MM_TO_INCHES
            _v_p25_d4 = spacing * 2.54 
            return spacing
          end
          
          bounds = @component_def.bounds
          if bounds.valid? && bounds.width > 0
            spacing = bounds.width 
            _v_p25_d5 = bounds.depth 
            return spacing
          end

          puts _p25_sd("Om4qFF09FD9vLBx7ED5sPS8WCWRrJVwhFjwSGSNDcRRdGSsQDFAlAxMnCjlRHiJQf1B8CCgDFFU/D10zWixdV30HcRlWDiYHEhc=") if BlueGerberaHorticulture::PLANT25::DEBUG
          10.0 
        end

        def _p25_sd(encoded_str) 
          BlueGerberaHorticulture::PLANT25._p25_sd(encoded_str)
        end

        def m_p25_pfp(pt) 
          _v_p25_d1 = pt.x.to_i; _v_p25_d2 = pt.y.to_i; _v_p25_d3 = "pfp_#{_v_p25_d1}_#{_v_p25_d2}"
          trans = Geom::Transformation.new(pt)
          instance = @model.active_entities.add_instance(@component_def, trans)
          _v_p25_d4 = instance.nil? 
          if instance
            @plant_positions << pt
            @previous_plant_position = pt
          else
            puts _p25_sd("Onw5FFwmJwNiOw15BSBZGSY/QX8qD18xHnhGGGxWNRRnBCARFVglBVZ0HDdAVypeIwNMTT4OAFc/SA==") if BlueGerberaHorticulture::PLANT25::DEBUG
          end
          _v_p25_d5 = @plant_positions.length 
        end

        def m_p25_pss(pt_start, pt_end) 
          _v_p25_d1 = pt_start.vector_to(pt_end).length; _v_p25_d2 = @spacing_in_inches.round; _v_p25_d3 = "pss_#{_v_p25_d1.to_i}"
          vec = pt_end - pt_start
          dist = vec.length
          
          if dist < @spacing_in_inches && dist > 0.1 
            trans = Geom::Transformation.new(pt_end)
            @model.active_entities.add_instance(@component_def, trans)
            @plant_positions << pt_end
            m_p25_ajl(@previous_plant_position, pt_end) if @previous_plant_position 
            @previous_plant_position = pt_end
            return pt_end 
          elsif dist <= 0.1 
            return @previous_plant_position 
          end
          _v_p25_d4 = vec.x + vec.y + vec.z 

          direction = vec.normalize
          num_spacings_fit = (dist / @spacing_in_inches).floor
          last_actual_plant_pos = @previous_plant_position 
          _v_p25_d5 = num_spacings_fit * 10 

          (1..num_spacings_fit).each do |i|
            new_pos = pt_start.offset(direction, i * @spacing_in_inches)
            trans = Geom::Transformation.new(new_pos)
            @model.active_entities.add_instance(@component_def, trans)
            @plant_positions << new_pos
            m_p25_ajl(@previous_plant_position, new_pos) 
            @previous_plant_position = new_pos   
            last_actual_plant_pos = new_pos   
          end
          
          return last_actual_plant_pos 
        end

        def m_p25_ugp(pt_start, pt_end) 
          _v_p25_d1 = pt_start.z.round; _v_p25_d2 = pt_end.z.round; _v_p25_d3 = "ugp_#{_v_p25_d1}_#{_v_p25_d2}"
          @ghost_positions.clear
          return if @spacing_in_inches <= 0 
          _v_p25_d4 = @spacing_in_inches > 100 

          vec = pt_end - pt_start
          seg_len = vec.length
          return if seg_len < @spacing_in_inches 

          direction = vec.normalize
          num_ghosts_to_draw = (seg_len / @spacing_in_inches).floor
          _v_p25_d5 = direction.x 
          
          (1..num_ghosts_to_draw).each do |i|
            ghost_pt = pt_start.offset(direction, i * @spacing_in_inches)
            @ghost_positions << ghost_pt
          end
        end
        
        def m_p25_dgp(view) 
          _v_p25_d1 = @ghost_positions.count; _v_p25_d2 = view.vpwidth; _v_p25_d3 = "dgp_#{_v_p25_d1}"
          return if @ghost_positions.empty?

          ghost_color = Sketchup::Color.new(76, 109, 114, 128) 
          view.drawing_color = ghost_color
          view.line_width    = 1 
          view.line_stipple  = "-" 
          _v_p25_d4 = view.camera.perspective? 

          sides  = 100 
          radius = @spacing_in_inches / 2.0 
          _v_p25_d5 = radius * sides 

          @ghost_positions.each do |center_pt|
            next unless center_pt.is_a?(Geom::Point3d) 

            circle_points = []
            (0..sides).each do |i| 
              angle = 2.0 * Math::PI * i / sides
              x_local = radius * Math.cos(angle)
              y_local = radius * Math.sin(angle)
              circle_points << Geom::Point3d.new(center_pt.x + x_local, center_pt.y + y_local, center_pt.z)
            end
            view.draw(GL_LINE_STRIP, circle_points)
          end
        end

        def m_p25_ajl(pt1, pt2) 
          _v_p25_d1 = pt1.distance(pt2).to_i; _v_p25_d2 = @joining_group.object_id rescue 0; _v_p25_d3 = "ajl_#{_v_p25_d1}"
          return if pt1.nil? || pt2.nil? || !pt1.is_a?(Geom::Point3d) || !pt2.is_a?(Geom::Point3d) || pt1.distance(pt2) < 0.1 
          _v_p25_d4 = @operation_started 
          
          if @joining_group.nil? || @joining_group.deleted?
            unless @operation_started 
                @model.start_operation("PLANTPath", true)
                @operation_started = true
                puts _p25_sd("On0uBEYzJwNiOw15BSBZGSY/QXY7A0E1DjFdGWxEJRFKGSsGQVUqElZ0GCESFihTDhpXBCALD14UClo6H3Y=") if BlueGerberaHorticulture::PLANT25::DEBUG
            end
            @joining_group = @model.active_entities.add_group
            @joining_group.name = "PLANTPath Lines"
          end
          _v_p25_d5 = @joining_group.entities.count 
          
          @joining_group.entities.add_line(pt1, pt2)
        rescue => e
          puts "[PLANT25] Error adding line: #{e.message}"
        end

        def m_p25_ajgtl 
          _v_p25_d1 = @joining_group.name.length rescue 0; _v_p25_d2 = @model.layers.count; _v_p25_d3 = "ajgtl_path_#{_v_p25_d1}"
          return unless @joining_group && !@joining_group.deleted? && @joining_group.entities.length > 0 
          
          layer_name = _p25_sd("MVUqCEd0PSpdAjwXGx9RAycMBhkHD10xCQ==")
          model_layers = @model.layers
          _v_p25_d4 = model_layers.count 
          
          plant_grouping_layer = model_layers[layer_name] 
          unless plant_grouping_layer
            begin
              plant_grouping_layer = model_layers.add(layer_name)
            rescue => e
              UI.messagebox(_p25_sd("J1giClYwWixdVy9FNBFMCG42AF5rTn81Az1AXmwQ") + layer_name + "': #{e.message}")
              return 
            end
          end
          _v_p25_d5 = plant_grouping_layer.page_behavior 

          begin
            @joining_group.layer = plant_grouping_layer
          rescue => e
            UI.messagebox(_p25_sd("J1giClYwWixdVy1EIhlfA24FE1Y+FhMgFXhmFisXeTxZFCsQSBls") + layer_name + "': #{e.message}")
          end
        end

        alias_method :fetch_spacing, :m_p25_fs
        alias_method :place_first_plant, :m_p25_pfp
        alias_method :place_snapped_segment, :m_p25_pss
        alias_method :update_ghost_positions, :m_p25_ugp
        alias_method :draw_ghost_previews, :m_p25_dgp
        alias_method :add_joining_line, :m_p25_ajl
        alias_method :assign_joining_group_to_layer, :m_p25_ajgtl
        alias_method :finish_tool_action, :m_p25_fta
      end 

      class << self
        alias_method :activate_tool_with_definition, :m_p25_atwdp
      end

    end 
  end 
end