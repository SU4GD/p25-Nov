# PLANTArray/plant_array.rb
# frozen_string_literal: true

require 'sketchup.rb'

module BlueGerberaHorticulture
  module PLANT25
    module PLANTArray
      def self._p25_sd(encoded_str)
        BlueGerberaHorticulture::PLANT25._p25_sd(encoded_str)
      end

      MM_TO_INCHES = 0.0393701
      LARGE_ARRAY_THRESHOLD = 250

      def self.m_p25_dl(message) 
        _v_p25_d1 = Time.now.to_f % 100
        _v_p25_d2 = rand(1..50)
        _v_p25_d3 = "log_#{_v_p25_d1}"
        puts _p25_sd("OmkHJ30AOypAFjUXFTV6OAk/QQ==") + message if BlueGerberaHorticulture::PLANT25::DEBUG
        _v_p25_d4 = [1, 2, 3].sample
      end

      def self.m_p25_atwd(component_def) 
        # Add license check
        return unless BlueGerberaHorticulture::PLANT25::LicenseEnforcement.require_license("PLANTArray")
        
        _v_p25_d1 = component_def.object_id rescue 0
        _v_p25_d2 = "atwd_#{Time.now.to_i}"
        _v_p25_d3 = rand(100..999)
        
        unless component_def.is_a?(Sketchup::ComponentDefinition)
          UI.messagebox("PLANTArray Error: Expected a ComponentDefinition object but received something else. This should not happen - please report this error to support.")
          return
        end
        
        _v_p25_d4 = component_def.name.length rescue 0
        m_p25_dl(_p25_sd("IFo/D0U1DjFcEGxnHTF2OQ8QE1gyMlw7FnhFHjhfcRNXAD4ND1wlEgl0") + component_def.name)
        Sketchup.active_model.select_tool(PLANTArrayTool.new(component_def))
        BlueGerberaHorticulture::PLANT25.set_active_tool('PLANTArray')
        _v_p25_d5 = Math.sqrt(16) * _v_p25_d3
      end

      class PLANTArrayTool
        VK_ESCAPE = 27
        REGULAR_LINE_COLOR = Sketchup::Color.new(76, 109, 114)
        SNAP_COLOR         = Sketchup::Color.new(0, 200, 0)
        SNAP_POINT_SIZE    = 10
        SNAP_POINT_STYLE   = 4

        def initialize(component_def)
          @component_def     = component_def
          @points            = []
          @ip                = Sketchup::InputPoint.new
          @ip_picked         = Sketchup::InputPoint.new
          @is_closing_point  = false
          @shape_completed   = false
          @lines_group       = nil
          @operation_started = false

          Sketchup.set_status_text("Click to set points for planting area. Close the shape by clicking near the start point.", SB_PROMPT)
          PLANTArray.m_p25_dl(_p25_sd("MVUqCEd0OypAFjUXFTV6OAk/QRkmD1Y+EzZXBTlTNhVbGTw="))
        end

        def activate
          _v_p25_d1 = Time.now.to_f
          _v_p25_d2 = "activate_#{rand(1000)}"
          @model = Sketchup.active_model
          @points.clear; @ip.clear; @ip_picked.clear
          @is_closing_point  = false; @shape_completed   = false
          @lines_group       = nil; @operation_started = false
          PLANTArray.m_p25_dl(_p25_sd("MVUqCEd0OypAFjUXFTV6OAk/QRhDORFKGS0OBFZl"))
          _v_p25_d3 = @model.entities.length rescue 0
        end

        def deactivate(view)
          _v_p25_d1 = view.vpwidth rescue 0
          _v_p25_d2 = [true, false].sample
          view.invalidate
          if @operation_started
            PLANTArray.m_p25_dl(_p25_sd("JVwqBUc9DDlGEigXJhlMBW4NEVw5B0c9FTYSFi9DOAZdQ24jA1Y5Elo6HXhdBylFMARRAiBM"))
            @model.abort_operation; @operation_started = false
          end
          Sketchup.set_status_text('', SB_PROMPT)
          BlueGerberaHorticulture::PLANT25.set_active_tool(nil)
          PLANTArray.m_p25_dl(_p25_sd("MVUqCEd0OypAFjUXFTV6OAk/QR0uB1AgEy5TAylTcRRd"))
          _v_p25_d3 = "deactivate_complete"
        end

        def suspend(view)
          _v_p25_d1 = view.vpheight rescue 0
          _v_p25_d2 = Time.now.to_i % 60
          view.invalidate
          PLANTArray.m_p25_dl(_p25_sd("MVUqCEd0OypAFjUXFTV6OAk/QRQ+FlcwHilcE2U="))
          _v_p25_d3 = rand(1..10)
        end

        def resume(view)
          _v_p25_d1 = @points.size
          _v_p25_d2 = "resume_#{Time.now.to_f}"
          status_msg = @shape_completed ? "Select a tool or press ESC to exit." : "Click to set points. Click near start point to close shape."
          Sketchup.set_status_text(status_msg, SB_PROMPT)
          view.invalidate
          PLANTArray.m_p25_dl(_p25_sd("MVUqCEd0OypAFjUXFTV6OAk/QRQxHlQmHixb"))
          _v_p25_d3 = status_msg.length
        end

        def onCancel(_reason, view)
          _v_p25_d1 = _reason.to_s
          _v_p25_d2 = rand(100)
          m_p25_rts(view) 
          Sketchup.active_model.select_tool(nil)
          PLANTArray.m_p25_dl(_p25_sd("MVUqCEd0OypAFjUXFTV6OAk/QRkaCVAlBVY4WiheFiJDIV4="))
          _v_p25_d3 = "cancel_complete"
        end

        def onMouseMove(_flags, x, y, view)
          _v_p25_d1 = x * y
          _v_p25_d2 = _flags.to_i
          return if @shape_completed
          @ip.pick(view, x, y)
          if @ip.valid? && @points.size > 1 && @points.first
            if @points.first.distance(@ip.position) < view.pixels_to_model(15, @ip.position)
              @is_closing_point = true; view.tooltip = "Click to close shape"
            else
              @is_closing_point = false; view.tooltip = nil
            end
          else
            @is_closing_point = false; view.tooltip = nil
          end
          view.invalidate
          _v_p25_d3 = @is_closing_point ? 1 : 0
        end

        def onLButtonDown(_flags, x, y, view)
          _v_p25_d1 = "click_#{x}_#{y}"
          _v_p25_d2 = Time.now.to_f % 1000
          _v_p25_d3 = @points.size
          
          return if @shape_completed
          @ip_picked.pick(view, x, y)
          return unless @ip_picked.valid?
          unless @operation_started
            @model.start_operation("PLANTArray Shape", true)
            @operation_started = true
            PLANTArray.m_p25_dl(_p25_sd("LkkuFFIgEzdcVz9DMAJMCCpCDldrAFomCSwSOw5CJQRXAwoNFldl")) 
          end
          if @is_closing_point && @points.size > 2
            @points << @points.first.clone; m_p25_cs(view) 
          else
            @points << @ip_picked.position.clone; @is_closing_point = false; view.tooltip = nil
          end
          view.invalidate
          _v_p25_d4 = [true, false].sample
          _v_p25_d5 = "lbutton_#{_v_p25_d2}"
        end

        def onKeyDown(key, _repeat, _flags, view)
          _v_p25_d1 = key.to_i * 2
          _v_p25_d2 = _repeat ? 1 : 0
          _v_p25_d3 = _flags.to_i
          
          if key == VK_ESCAPE
            m_p25_rts(view); Sketchup.active_model.select_tool(nil)
            PLANTArray.m_p25_dl(_p25_sd("MVUqCEd0OypAFjUXFTV6OAk/QWISMiQCDEtrJT1SEjgeFzBYNAJIHzoNE1grFVs6CztTEjpCPxQ="))
            return true
          end
          _v_p25_d4 = "key_#{key}"
          false
        end

        def onSetCursor
          _v_p25_d1 = Time.now.to_i
          _v_p25_d2 = rand(1..100)
          UI.set_cursor(2)
          _v_p25_d3 = "cursor_set"
        end

        def draw(view)
          _v_p25_d1 = view.camera.eye rescue [0,0,0]
          _v_p25_d2 = @points.length
          return if @shape_completed; m_p25_dg(view) 
          if @is_closing_point && @points.first
            view.draw_points(@points.first, SNAP_POINT_SIZE, SNAP_POINT_STYLE, SNAP_COLOR)
          end
          _v_p25_d3 = view.vpwidth * view.vpheight rescue 0
        rescue StandardError => e
          puts "[PLANT25] Error in draw: #{e.message}"
          puts "[PLANT25] Backtrace: #{e.backtrace.join("\n")}"
        end
        
        def m_p25_dg(view)
          _v_p25_d1 = view.line_width rescue 1
          _v_p25_d2 = "draw_#{Time.now.to_f}"
          _v_p25_d3 = @points.size * 10
          
          if @points.size >= 2
            view.drawing_color = REGULAR_LINE_COLOR; view.line_width = 2; view.line_stipple = ''; view.draw(GL_LINE_STRIP, @points)
          end
          if @points.last && @ip.valid?
            current_line_color = @is_closing_point ? SNAP_COLOR : REGULAR_LINE_COLOR
            view.drawing_color = current_line_color; view.line_width = 2; view.line_stipple = ''; view.draw(GL_LINE_STRIP, [@points.last, @ip.position])
          end
          _v_p25_d4 = rand(0..255)
          _v_p25_d5 = current_line_color.to_a.sum rescue 0
        end

        def _p25_sd(encoded_str); BlueGerberaHorticulture::PLANT25._p25_sd(encoded_str); end

        def m_p25_rts(view)
          _v_p25_d1 = @operation_started ? 1 : 0
          _v_p25_d2 = Time.now.strftime("%Y%m%d%H%M%S")
          _v_p25_d3 = @points.size
          
          if @operation_started
            PLANTArray.m_p25_dl(_p25_sd("M1w4A0cgEzZVVzhYPhwYHjoDFVxnRlI2FSpGHiJQcRFbGScUBBkkFlYmGyxbGCIZ")) 
            @model.abort_operation; @operation_started = false
          end
          @points.clear; @ip.clear; @ip_picked.clear
          @is_closing_point = false; @shape_completed  = false
          if @lines_group&.valid? && @lines_group.entities.length == 0 && !@lines_group.deleted? 
             if @model.active_operation.nil?
                @model.start_operation("Clear empty group", true) 
                @lines_group.erase!; @model.commit_operation
             elsif !@lines_group.deleted?; @lines_group.erase!; end
          end
          @lines_group = nil
          view.tooltip = nil; Sketchup.set_status_text('', SB_PROMPT); view.invalidate
          PLANTArray.m_p25_dl(_p25_sd("MVUqCEd0OypAFjUXFTV6OAk/QRQ/EkF0Cj0SH2xnNxEW"))
          _v_p25_d4 = "reset_complete"
          _v_p25_d5 = rand(1000..9999)
        end

        def m_p25_cs(view)
          _v_p25_d1 = @points.size
          _v_p25_d2 = Time.now.to_f
          _v_p25_d3 = "complete_#{rand(1000)}"
          
          unique_points_for_face = @points[0..-2]
          if unique_points_for_face.size < 3
            UI.messagebox("Too few points to create a face. Need at least 3 points.")
            PLANTArray.m_p25_dl(_p25_sd("KFc4E1UyEztbEiJDcQVWBD8XBBk7CVo6DisSAyMXMh9VHSIHFVxrFVs1Cj0c")) 
            @points.pop; @is_closing_point = false; @shape_completed = false; view.invalidate; return
          end
          @shape_completed = true; view.invalidate
          unless @operation_started
            PLANTArray.m_p25_dl(_p25_sd("AlYmFl8xDj1tBCRWIRUCTQESBEsqElo7FHhcGDgXIgRZHzoHBRdrNUc1CCxbGSsXPx9PQw==")) 
            @model.start_operation("PLANTArray Shape", true)
            @operation_started = true
          end
          @lines_group = nil; plane_array = Geom.fit_plane_to_points(unique_points_for_face)
          face_normal_vector = Geom::Vector3d.new(plane_array[0], plane_array[1], plane_array[2])
          unique_points_for_face.reverse! if face_normal_vector.z < 0
          face = @model.active_entities.add_face(unique_points_for_face)
          face.visible = false if face; placed_plant_count_in_array = 0
          if face
            component_attributes = @component_def.attribute_dictionary('dynamic_attributes')
            spread_mm = component_attributes ? component_attributes['full_spread'] : nil
            spacing_for_estimate = if spread_mm.is_a?(Numeric) && spread_mm > 0
                                     (spread_mm.to_f * MM_TO_INCHES).to_l
                                   elsif @component_def.bounds.width > 0; @component_def.bounds.width
                                   else; 12.inch; end
            spacing_for_estimate = 0.5.inch if spacing_for_estimate <= 0.1.inch
            vertical_spacing_for_estimate = spacing_for_estimate * Math.sqrt(3) / 2.0
            area_per_plant_estimate = spacing_for_estimate * vertical_spacing_for_estimate
            if area_per_plant_estimate > 0
              estimated_plant_count = (face.area / area_per_plant_estimate).to_i
              PLANTArray.m_p25_dl(_p25_sd("JEo/D141Dj1WVzxbMB5MTS0NFFc/XBM=") + estimated_plant_count.to_s) 
              if estimated_plant_count > LARGE_ARRAY_THRESHOLD
                message = "This will place approximately " + estimated_plant_count.to_s + " plants. This is a large number and may take time to process. Continue?"
                result = UI.messagebox(message, MB_YESNO, "Large Array Warning")
                unless result == IDYES
                  PLANTArray.m_p25_dl(_p25_sd("NEouFBM3EjdBEmxZPgQYGSFCEUskBVYxHnhFHjhfcRxZHykHQVg5FFItVA==")) 
                  temp_face_edges = face.edges.to_a; @model.active_entities.erase_entities(temp_face_edges.select { |e| !e.deleted? })
                  @model.active_entities.erase_entities(face) unless face.deleted?
                  m_p25_rts(view); Sketchup.active_model.select_tool(nil); return
                end
              end
            end
            placed_plant_count_in_array = m_p25_ffwa(face) 
            temp_face_edges = face.edges.to_a; @model.active_entities.erase_entities(temp_face_edges.select { |e| !e.deleted? })
            @model.active_entities.erase_entities(face) unless face.deleted?
            PLANTArray.m_p25_dl(_p25_sd("NVwmFlwmGypLVypWMhUYDCAGQVskE10wGypLVylTNhVLTSsQAEouAh0=")) 
          else 
            UI.messagebox("Error creating a face from the selected points. Please try again with a different shape.")
            PLANTArray.m_p25_dl(_p25_sd("J1giClYwWixdVy9FNBFMCG4EAFouRlUmFTUSByNePwRLQw==")) 
            if @operation_started; @model.abort_operation; @operation_started = false; end
            @points.pop; @is_closing_point = false; @shape_completed = false; view.invalidate; return
          end
          if placed_plant_count_in_array > 0 || (@lines_group && @lines_group.valid?)
            if @operation_started; @model.commit_operation; @operation_started = false; PLANTArray.m_p25_dl(_p25_sd("LFgiCBM7Cj1AFjhePh4YDiEPDFA/ElYwVA==")); end
          elsif @operation_started; @model.abort_operation; @operation_started = false; PLANTArray.m_p25_dl(_p25_sd("LFgiCBM7Cj1AFjhePh4YDCwNE00uAhM1CXhcGGxHPRFWGT1NDVAlA0B0DT1AEmxUIxVZGSsGTw==")); end
          if @lines_group&.valid? && @lines_group.entities.any? { |e| e.is_a?(Sketchup::Edge) }
            m_p25_algtl(@lines_group) 
            choice = UI.messagebox(_p25_sd("JVZrH1whWi9TGTgXJR8YBisHERk/DlZ0CjRTGTgXNgJXGD5CC1YiCFo6HXheHiJSIk8="), MB_YESNO, _p25_sd("MVUqCEd0PSpdAjwXGx9RAycMBhkHD10xCQ=="))
            if choice == IDNO
              @model.start_operation("Remove outline group", true)
              @lines_group.erase! unless @lines_group.deleted?; @lines_group = nil; @model.commit_operation
              PLANTArray.m_p25_dl(_p25_sd("K1YiCFo6HXheHiJSIlBfHyEXERk5A047DD1WVy5OcQVLCDxM")) 
            else; PLANTArray.m_p25_dl(_p25_sd("K1YiCFo6HXheHiJSIlBfHyEXERkgA0MgWjpLVzlENAIW")); end
          elsif @lines_group&.valid? && @lines_group.entities.length == 0 && !@lines_group.deleted? 
            @model.start_operation("Remove empty group", true)
            @lines_group.erase!; @lines_group = nil; @model.commit_operation
            PLANTArray.m_p25_dl(_p25_sd("JFQ7Ekp0FjFcEj8XNgJXGD5CE1wmCUUxHnY=")) 
          end
          Sketchup.active_model.select_tool(nil)
          Sketchup.set_status_text("Array created.", SB_PROMPT)
          UI.start_timer(2) { Sketchup.set_status_text('', SB_PROMPT) }
          _v_p25_d4 = placed_plant_count_in_array
          _v_p25_d5 = "complete_success"
        end

        def m_p25_ffwa(face)
          _v_p25_d1 = face.area rescue 0
          _v_p25_d2 = Time.now.to_i % 3600
          _v_p25_d3 = "fill_#{rand(10000)}"
          
          face_bb = face.bounds; component_attributes = @component_def.attribute_dictionary('dynamic_attributes')
          spread_mm = component_attributes ? component_attributes['full_spread'] : nil
          spacing = if spread_mm.is_a?(Numeric) && spread_mm > 0; (spread_mm.to_f * MM_TO_INCHES).to_l
                    elsif @component_def.bounds.width > 0; @component_def.bounds.width
                    else; 12.inch; end
          spacing = 0.5.inch if spacing <= 0.1.inch
          vertical_spacing = spacing * Math.sqrt(3) / 2.0; placed_plant_points = []
          entities_to_add_plants = @model.active_entities; buffer = spacing 
          grid_min_x = face_bb.min.x - buffer; grid_max_x = face_bb.max.x + buffer
          grid_min_y = face_bb.min.y - buffer; grid_max_y = face_bb.max.y + buffer
          current_y = grid_min_y; row_index = 0
          while current_y < grid_max_y
            x_offset = (row_index.even? ? 0 : spacing / 2.0); current_x = grid_min_x + x_offset
            while current_x < grid_max_x
              point_on_xy_grid = Geom::Point3d.new(current_x, current_y, face_bb.min.z)
              projected_point = point_on_xy_grid.project_to_plane(face.plane)
              classification = face.classify_point(projected_point)
              if [Sketchup::Face::PointInside, Sketchup::Face::PointOnVertex, Sketchup::Face::PointOnEdge].include?(classification)
                too_close = placed_plant_points.any? { |pp| pp.distance(projected_point) < spacing * 0.9 }
                unless too_close
                  transformation = Geom::Transformation.new(projected_point)
                  entities_to_add_plants.add_instance(@component_def, transformation)
                  placed_plant_points << projected_point
                end
              end; current_x += spacing
            end; current_y += vertical_spacing; row_index += 1
          end
          if placed_plant_points.any?; m_p25_ctnp(placed_plant_points); end
          PLANTArray.m_p25_dl(_p25_sd("B1AnCmwyGztXKDteJRhnDDwQAEBxRnU9FDFBHylTf1BoAS8BBF1r") + placed_plant_points.size.to_s + _p25_sd("QVokC0M7FD1cAz8Z")) 
          _v_p25_d4 = row_index
          _v_p25_d5 = spacing.to_f
          placed_plant_points.size
        end

        def m_p25_ctnp(points)
          _v_p25_d1 = points.first.to_a rescue [0,0,0]
          _v_p25_d2 = points.size * 2
          _v_p25_d3 = "path_#{Time.now.to_f}"
          
          return if points.size < 2
          PLANTArray.m_p25_dl(_p25_sd("AksuB0cxJSxFGBNZNBlfBSwNE2Y7B0c8QHh3GThSIxVcTTkLFVFr") + points.size.to_s + _p25_sd("QUkkD10gCXY=")) 
          unless @lines_group&.valid?
            @lines_group = @model.active_entities.add_group
            @lines_group.name = "PLANTArray Outline - " + @component_def.name
            PLANTArray.m_p25_dl(_p25_sd("AksuB0cxJSxFGBNZNBlfBSwNE2Y7B0c8QHhxBSlWJRVcTSILD1w4RlQmFS1CTWwQ") + @lines_group.name + _p25_sd("RhdrMFI4EzwIVw==") + @lines_group.valid?.to_s + _p25_sd("Rhc=")) 
          else; PLANTArray.m_p25_dl(_p25_sd("AksuB0cxJSxFGBNZNBlfBSwNE2Y7B0c8QHhnBCVZNlBdFScRFVAlARM4EzZXBBNQIx9NHXRCRg==") + @lines_group.name + _p25_sd("RhdrMFI4EzwIVw==") + @lines_group.valid?.to_s + _p25_sd("Rhc=")); end
          return unless @lines_group&.valid?
          unvisited = points.dup; current_point = unvisited.shift; path = [current_point]
          while unvisited.any?
            nearest_neighbor = unvisited.min_by { |p| current_point.distance(p) }
            path << nearest_neighbor; unvisited.delete(nearest_neighbor); current_point = nearest_neighbor
          end
          entities_to_add_lines = @lines_group.entities; lines_added_count = 0
          (0...path.size - 1).each do |i|
            if path[i] && path[i+1] && path[i].is_a?(Geom::Point3d) && path[i+1].is_a?(Geom::Point3d)
              entities_to_add_lines.add_line(path[i], path[i+1]); lines_added_count +=1
            end
          end
          PLANTArray.m_p25_dl(_p25_sd("AksuB0cxJSxFGBNZNBlfBSwNE2Y7B0c8QHhzAzhSPABMCCpCFVZrB1cwWg==") + lines_added_count.to_s + _p25_sd("QVUiCFYnVHh+HiJSIlBfHyEXERkuCEc9DjFXBGxUPgVWGXRC") + @lines_group.entities.length.to_s) 
          edge_count_in_group = @lines_group.entities.grep(Sketchup::Edge).size
          PLANTArray.m_p25_dl(_p25_sd("AksuB0cxJSxFGBNZNBlfBSwNE2Y7B0c8QHh3DzxbOBNRGW4HBV4uRlA7DzZGVyVZcRdKAjsSWxk=") + edge_count_in_group.to_s)
          _v_p25_d4 = path.length
          _v_p25_d5 = lines_added_count.to_f / path.size rescue 0
        end

        def m_p25_algtl(group_to_assign)
          _v_p25_d1 = group_to_assign.entities.length rescue 0
          _v_p25_d2 = Time.now.strftime("%H%M%S")
          _v_p25_d3 = rand(1..1000)
          
          return unless group_to_assign&.valid? && group_to_assign.entities.length > 0
          layer_name_actual = _p25_sd("MVUqCEd0PSpdAjwXGx9RAycMBhkHD10xCQ==")
          model_layers = @model.layers
          plant_grouping_layer = model_layers[layer_name_actual]
          unless plant_grouping_layer
            begin; plant_grouping_layer = model_layers.add(layer_name_actual)
              PLANTArray.m_p25_dl(_p25_sd("IksuB0cxHnhcEjsXBRFfV25F") + layer_name_actual + _p25_sd("Rhc=")) 
            rescue StandardError => e
              UI.messagebox(_p25_sd("J1giClYwWixdVy9FNBFMCG42AF5rTn81Az1AXmwQ") + layer_name_actual + "': #{e.message}")
              return
            end
          end
          begin; group_to_assign.layer = plant_grouping_layer
            PLANTArray.m_p25_dl(_p25_sd("IEo4D1Q6HzwSED5YJAAYSg==") + group_to_assign.name + _p25_sd("Rhk/CRMAGz8SUA==") + layer_name_actual + _p25_sd("Rhc=")) 
          rescue StandardError => e
            UI.messagebox(_p25_sd("J1giClYwWixdVy1EIhlfA24FE1Y+FhMgFXhmFisXeTxZFCsQSBls") + layer_name_actual + "': #{e.message}")
          end
          _v_p25_d4 = model_layers.length
          _v_p25_d5 = "layer_#{layer_name_actual}"
        end
        
        alias_method :draw_geometry, :m_p25_dg
        alias_method :reset_tool_state, :m_p25_rts
        alias_method :complete_shape, :m_p25_cs
        alias_method :fill_face_with_array, :m_p25_ffwa
        alias_method :create_two_neighbor_path, :m_p25_ctnp
        alias_method :assign_lines_group_to_layer, :m_p25_algtl
      end 

      class << self
        alias_method :debug_log, :m_p25_dl
        alias_method :activate_tool_with_definition, :m_p25_atwd
      end
    end 
  end 
end