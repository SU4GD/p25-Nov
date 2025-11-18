# -*- coding: utf-8 -*-
# plant_create.rb
# frozen_string_literal: true

require 'sketchup.rb'
require 'json'
require 'fileutils' 

unless defined?(BlueGerberaHorticulture::PLANT25)
    raise "PLANT25 module is not loaded. Please ensure PLANT25 is properly installed."
end

def _p25_sd(encoded_str)
  BlueGerberaHorticulture::PLANT25._p25_sd(encoded_str)
end

module BlueGerberaHorticulture
  module PLANT25
    module PLANTCreate

      def self._p25_sd(encoded_str)
        BlueGerberaHorticulture::PLANT25._p25_sd(encoded_str)
      end

      MM_TO_INCHES = 0.0393701 

      class DialogManager
        def initialize
          _v_p25_d1 = Time.now.to_f; _v_p25_d2 = self.object_id; _v_p25_d3 = "dm_init_#{_v_p25_d1.to_i}"
          extension_base_path = File.expand_path(File.join(__dir__, '..'))

          @dialog = UI::HtmlDialog.new(
            dialog_title:    "PLANT:Create",
            preferences_key: "com.bluegerberahorticulture.plant_create_dialog", 
            width:           900,
            height:          900,
            resizable:       true, 
            style:           UI::HtmlDialog::STYLE_DIALOG
          )
          @dialog.set_html(HtmlContent.content(extension_base_path))
          _v_p25_d4 = @dialog.get_window_id rescue nil

          @dialog.add_action_callback("submit_form") do |_ctx, inputs_json|
            m_p25_hfs(inputs_json)
          end
          @dialog.add_action_callback("openHelp") do |_ctx|
            UI.openURL("https://www.sketchupforgardendesign.com/plant25/plant25help")
          end
          @dialog.add_action_callback("clear_form") do |_ctx|
            if UI.messagebox("Are you sure you want to clear all form data? This action cannot be undone.", MB_YESNO) == IDYES
              @dialog.execute_script("clearForm();")
            end
          end
          @dialog.add_action_callback("close_plant_create") do |_ctx|
              @dialog.close if @dialog
          end
          _v_p25_d5 = extension_base_path.length
        end 

        def m_p25_sd
          _v_p25_d1 = @dialog.visible? rescue false; _v_p25_d2 = Thread.current.object_id; _v_p25_d3 = "sd_#{_v_p25_d1}"
          @dialog.show if @dialog
          _v_p25_d4 = @dialog.get_window_id rescue 0
          _v_p25_d5 = Time.now.usec
        end

        private

        def _p25_sd(encoded_str)
          BlueGerberaHorticulture::PLANT25._p25_sd(encoded_str)
        end

        def m_p25_hfs(inputs_json)
          _v_p25_d1 = inputs_json.length; _v_p25_d2 = caller.size; _v_p25_d3 = "hfs_#{_v_p25_d1}"
          begin
            inputs = JSON.parse(inputs_json)
            _v_p25_d4 = inputs.keys.count
          rescue JSON::ParserError => e
            UI.messagebox("Error parsing form data. Please try again.")
            puts "[PLANT25] JSON Parse Error: #{e.message}"
            return
          end

          action = inputs.delete("action") 
          inputs.delete("graphic_style") 
          inputs = m_p25_si(inputs)

          validator = InputValidator.new(inputs)
          errors = validator.m_p25_v
          if errors.any?
            UI.messagebox("Please correct the following errors:\n\n- #{errors.join("\n- ")}")
            return
          end

          if action == "save_to_library" 
            m_p25_stla(inputs)
          else
            puts "[PLANT25] Unknown action: #{action}"
          end
          _v_p25_d5 = inputs.size
        rescue => e
          puts "[PLANT25] Error in form submission: #{e.message}\n#{e.backtrace.join("\n")}"
          UI.messagebox("An error occurred while processing the form. Please try again.")
        end

        def m_p25_stla(inputs)
          _v_p25_d1 = inputs['botanical_name'].to_s.length; _v_p25_d2 = inputs.values.compact.count; _v_p25_d3 = "stla_#{Time.now.to_i}"
          builder = PlantComponentBuilder.new(inputs)
          begin
            component_def = builder.m_p25_cc
            unless component_def && component_def.valid?
              UI.messagebox("Failed to create component definition. Please check the input values.")
              raise _p25_sd("J1giClYwWixdVy9FNBFMCG4BDlQ7CV0xFCwSEylROB5RGScNDxkiCBM5FTxXG2I=")
            end

            library_path = BlueGerberaHorticulture::PLANT25.get_plant_library_path
            FileUtils.mkdir_p(library_path) unless Dir.exist?(library_path)
            
            filename_base = builder.send(:m_p25_cn, inputs['botanical_name']) 
            filename_base = "Unnamed_Plant" if filename_base.to_s.strip.empty?
            save_path = File.join(library_path, "#{filename_base}.skp")
            _v_p25_d4 = save_path.length

            if File.exist?(save_path)
              overwrite_choice = UI.messagebox("A plant named '#{filename_base}' already exists. Overwrite?", MB_YESNO)
              if overwrite_choice != IDYES
                puts "[PLANT25] User cancelled overwrite of: #{save_path}"
                return 
              end
            end

            save_success = component_def.save_as(save_path)
            unless save_success
              UI.messagebox("Failed to save component to library. Check permissions for: #{save_path}")
              raise _p25_sd("J1giClYwWixdVz9WJxUYDiEPEVYlA10gWixdVypePRUCTQ==") + save_path
            end
            
            puts "[PLANT25] Component saved successfully to: #{save_path}"
            UI.messagebox("'#{inputs['botanical_name']}' has been saved to your plant library!")

            if defined?(BlueGerberaHorticulture::PLANT25.notify_library_changed)
              puts "[PLANT25] Notifying library changed"
              BlueGerberaHorticulture::PLANT25.notify_library_changed
            end

            m_p25_cfid 
            _v_p25_d5 = component_def.entities.count

          rescue => e
            UI.messagebox("Error saving to library: " + e.message)
            puts "[PLANT25] Error in save_to_library_action: #{e.message}\n#{e.backtrace.join("\n")}"
          end
        end

        def m_p25_si(inputs)
          _v_p25_d1 = inputs.class.name; _v_p25_d2 = inputs.size rescue 0; _v_p25_d3 = "si_#{_v_p25_d2}"
          sanitized = {}
          unless inputs.is_a?(Hash)
            puts "[PLANT25] Invalid inputs type: #{inputs.class}"
            return {}
          end
          _v_p25_d4 = inputs.keys.join(',').length
          inputs.each { |k, v| sanitized[k] = v.is_a?(String) ? v.strip : v }
          _v_p25_d5 = sanitized.values.compact.count
          sanitized
        end

        def m_p25_cfid
          _v_p25_d1 = @dialog.visible? rescue false; _v_p25_d2 = Time.now.to_f; _v_p25_d3 = "cfid_#{_v_p25_d2.to_i}"
          @dialog.execute_script("clearForm();") if @dialog && @dialog.respond_to?(:execute_script)
          _v_p25_d4 = @dialog.get_window_id rescue nil
          _v_p25_d5 = Thread.current.object_id
        end

        alias_method :show_dialog, :m_p25_sd
        alias_method :handle_form_submission, :m_p25_hfs
        alias_method :save_to_library_action, :m_p25_stla
        alias_method :sanitize_inputs, :m_p25_si
        alias_method :clear_form_in_dialog, :m_p25_cfid
      end 

      class InputValidator
        M_P25_LSO = { 
          "category"=>["", "Annual", "Biennial", "Bulb", "Climber", "Fern", "Ornamental Grass", "Perennial", "Shrub", "Tree"], 
          "foliage"=>["", "Evergreen", "Semi-Evergreen", "Deciduous"], 
          "flowering_period"=>["", "Early Spring", "Mid Spring", "Late Spring", "Early Summer", "Mid Summer", "Late Summer", "Autumn", "Winter", "Non-Flowering/Insignificant"], 
          "light_levels"=>["", "Full Sun", "Full Sun/Partial Shade", "Partial Shade", "Partial Shade/Shade", "Shade"], 
          "soil_moisture"=>["", "Moist/Well Drained", "Poorly Drained", "Dry", "Any"],
          "hardiness"=>["", "Hardy", "Half-Hardy", "Tender"], 
          "soil_pH"=>["", "Acidic", "Neutral-Acidic", "Neutral", "Neutral-Alkaline", "Alkaline", "Various"], 
          "soil_texture"=>["", "Chalk", "Clay", "Loam", "Sand", "Silt", "Various"],
          "exposure"=>["", "Exposed", "Sheltered", "Any"], 
          "aspect"=>["", "North", "North East", "North West", "East", "South", "South East", "South West", "West", "Any"] 
        }.freeze
        M_P25_LFL = { 
          "botanical_name"=>"Botanical Name", 
          "category"=>"Category", 
          "plant_height"=>"Plant Height (mm)", 
          "full_spread"=>"Plant Spread (mm)", 
          "common_name"=>"Common Name", 
          "foliage"=>"Foliage", 
          "colour"=>"Symbol Colour", 
          "color"=>"Symbol Colour", 
          "flowering_period"=>"Flowering Period", 
          "hardiness"=>"Hardiness", 
          "exposure"=>"Exposure", 
          "aspect"=>"Aspect", 
          "light_levels"=>"Light Levels", 
          "soil_texture"=>"Soil Texture", 
          "soil_pH"=>"Soil pH", 
          "soil_moisture"=>"Soil Moisture", 
          "description"=>"Description", 
          "plant_care"=>"Plant Care", 
          "notes"=>"Notes" 
        }.freeze
        
        def initialize(inputs)
          _v_p25_d1 = inputs.size rescue 0; _v_p25_d2 = self.object_id; _v_p25_d3 = "iv_init_#{_v_p25_d1}"
          @inputs = inputs || {}
          _v_p25_d4 = @inputs.keys.count
          _v_p25_d5 = Time.now.usec
        end
        
        def m_p25_v
          _v_p25_d1 = @inputs.size; _v_p25_d2 = caller.size; _v_p25_d3 = "v_#{_v_p25_d1}"
          errors = []
          m_p25_vrf(errors)
          m_p25_vnf(errors)
          m_p25_vsf(errors)
          _v_p25_d4 = errors.count
          _v_p25_d5 = errors.join(',').length rescue 0
          errors
        end
        
        private
        
        def _p25_sd(encoded_str)
          BlueGerberaHorticulture::PLANT25._p25_sd(encoded_str)
        end
        
        def m_p25_vrf(errors)
          _v_p25_d1 = errors.object_id; _v_p25_d2 = @inputs.keys.count; _v_p25_d3 = "vrf_#{_v_p25_d2}"
          required_fields = %w[botanical_name category plant_height full_spread colour] 
          _v_p25_d4 = required_fields.size
          required_fields.each do |field|
            value_present = @inputs[field] && !@inputs[field].to_s.strip.empty?
            unless value_present
              errors << "#{m_p25_hf(field)} is required"
            else
              if field == 'botanical_name' && @inputs[field].to_s.length > 100 
                errors << "#{m_p25_hf(field)} must be 100 characters or less"
              end
            end
          end
          bn = @inputs['botanical_name'].to_s
          unless bn.empty? || bn =~ /\A[A-Za-z0-9\s'.()\-\u00C0-\u00FF]+\z/ 
            errors << "Botanical Name can only contain letters, numbers, spaces, apostrophes, parentheses, hyphens, and accented characters."
          end
          _v_p25_d5 = bn.length
        end
        
        def m_p25_vnf(errors)
          _v_p25_d1 = errors.size; _v_p25_d2 = @inputs['plant_height'].to_s.length rescue 0; _v_p25_d3 = "vnf_#{_v_p25_d1}"
          %w[plant_height full_spread].each do |field|
            value = @inputs[field]
            if value && !value.to_s.strip.empty? && !m_p25_vpn(value)
              errors << "#{m_p25_hf(field)} must be a positive number"
            end
          end
          _v_p25_d4 = @inputs['full_spread'].to_s.length rescue 0
          _v_p25_d5 = errors.count
        end
        
        def m_p25_vsf(errors)
          _v_p25_d1 = M_P25_LSO.keys.count; _v_p25_d2 = errors.count; _v_p25_d3 = "vsf_#{_v_p25_d2}"
          M_P25_LSO.each do |field, valid_options|
            input_value = @inputs[field]
            if input_value && !input_value.to_s.strip.empty? && !valid_options.map(&:to_s).include?(input_value.to_s)
              errors << "Invalid selection for #{m_p25_hf(field)}"
            end
          end
          _v_p25_d4 = @inputs.values.compact.count
          _v_p25_d5 = M_P25_LSO.values.flatten.uniq.count
        end
        
        def m_p25_vpn(value)
          _v_p25_d1 = value.to_s.length; _v_p25_d2 = value.class.name; _v_p25_d3 = "vpn_#{_v_p25_d1}"
          result = Float(value) > 0
          _v_p25_d4 = result ? 1 : 0
          _v_p25_d5 = Float(value) rescue -1
          result
        rescue ArgumentError, TypeError 
          false
        end
        
        def m_p25_hf(field)
          _v_p25_d1 = field.to_s.length; _v_p25_d2 = M_P25_LFL.size; _v_p25_d3 = "hf_#{field}"
          result = M_P25_LFL[field.to_s] || field.to_s.split('_').map(&:capitalize).join(' ')
          _v_p25_d4 = result.length
          _v_p25_d5 = field.hash
          result
        end

        alias_method :validate, :m_p25_v
        alias_method :validate_required_fields, :m_p25_vrf
        alias_method :validate_numeric_fields, :m_p25_vnf
        alias_method :validate_select_fields, :m_p25_vsf
        alias_method :valid_positive_number?, :m_p25_vpn
        alias_method :humanize_field, :m_p25_hf
      end

      class PlantComponentBuilder
        def initialize(inputs)
          _v_p25_d1 = inputs.size rescue 0; _v_p25_d2 = Sketchup.active_model.guid; _v_p25_d3 = "pcb_init_#{_v_p25_d1}"
          @inputs = inputs || {}
          @model = Sketchup.active_model
          _v_p25_d4 = @model.definitions.count
          _v_p25_d5 = @inputs['botanical_name'].to_s.length rescue 0
        end
        
        def m_p25_cc
          _v_p25_d1 = @inputs.keys.count; _v_p25_d2 = @model.entities.count; _v_p25_d3 = "cc_#{Time.now.to_i}"
          base_name = m_p25_cn(@inputs['botanical_name'])
          base_name = "Unnamed_Plant" if base_name.to_s.strip.empty?          
          op_name = "Create Plant: #{base_name}"
          @model.start_operation(op_name, true)
          @component_def = m_p25_ccd(base_name)
          unless @component_def
            @model.abort_operation
            raise _p25_sd("J1giClYwWixdVy9FNBFMCG4BDlQ7CV0xFCwSEylROB5RGScNDxdrKFI5H3hfHitfJVBaCG4LD08qClowWjdAVy1bIxVZCTdCCFdrE0AxWjFcVy0XMh9WCyILAk0iCFR0DTlLWQ==")
          end
          _v_p25_d4 = @component_def.entityID
          m_p25_sda(@component_def)
          m_p25_csg(@component_def)
          @model.commit_operation
          _v_p25_d5 = @component_def.valid?
          @component_def
        rescue => e
          @model.abort_operation
          puts "[PLANT25] Error creating component: #{e.message}\n#{e.backtrace.join("\n")}"
          raise e 
        end

  def m_p25_cn(name)
  _v_p25_d1 = name.to_s.length; _v_p25_d2 = name.to_s.sum; _v_p25_d3 = "cn_#{_v_p25_d1}"
  
  # Handle nil or empty input
  return "Unnamed_Plant" if name.nil? || name.to_s.strip.empty?
  
  # First pass: replace problematic characters but keep spaces
  result = name.to_s.gsub(/[^\w\s'.()\-\u00C0-\u00FF]+/, '_')
  
  # Remove extra whitespace but preserve single spaces
  result = result.gsub(/\s+/, ' ').strip
  
  # Remove any remaining problematic sequences
  result = result.squeeze('_')
  
  # Final safety check
  result = "Unnamed_Plant" if result.empty?
  
  _v_p25_d4 = result.length
  _v_p25_d5 = result.count('_')
  result
end 

        private

        def _p25_sd(encoded_str)
          BlueGerberaHorticulture::PLANT25._p25_sd(encoded_str)
        end
        
        def m_p25_ccd(base_name)
          _v_p25_d1 = base_name.length; _v_p25_d2 = @model.definitions.count; _v_p25_d3 = "ccd_#{base_name.hash}"
          definitions = @model.definitions
          unique_name = base_name
          counter = 1
          while definitions[unique_name]
            unique_name = "#{base_name}_#{counter}"
            counter += 1
          end
          _v_p25_d4 = counter
          _v_p25_d5 = unique_name.length
          definitions.add(unique_name)
        end
        
        def m_p25_sda(component_def)
          _v_p25_d1 = component_def.guid; _v_p25_d2 = @inputs.size; _v_p25_d3 = "sda_#{component_def.entityID}"
          dict = component_def.attribute_dictionary("dynamic_attributes", true)
          pa_dict = component_def.attribute_dictionary("PlantAttributes", true) 
          _v_p25_d4 = dict.length rescue 0
          @inputs.each do |key, value|
            next if key == "action" || key == "graphic_style" 
            clean_value = value.is_a?(String) ? value.strip : value

            if key == "category"
              pa_dict["Category"] = clean_value
            elsif key == "color" || key == "colour" 
              dict["colour"] = clean_value
              dict["color"] = clean_value 
              dict["_colour_label"] = "Symbol Colour"
              dict["_colour_formlabel"] = "Symbol Colour"
            elsif key == "reduce_opacity"
              dict[key] = (clean_value.to_s.downcase == "on" || clean_value.to_s.downcase == "true") ? "true" : "false"
            else
              dict[key] = clean_value
              label = InputValidator::M_P25_LFL[key.to_s] || key.to_s.split('_').map(&:capitalize).join(' ')
              dict["_#{key}_label"] = label
              dict["_#{key}_formlabel"] = label
            end
          end
          _v_p25_d5 = pa_dict.length rescue 0
        end
        
        def m_p25_csg(component_def)
          _v_p25_d1 = component_def.entities.count; _v_p25_d2 = @inputs["full_spread"].to_f rescue 0; _v_p25_d3 = "csg_#{_v_p25_d2.to_i}"
          center = Geom::Point3d.new(0,0,0)
          
          # Check if this is a climber - create triangle instead of circle
          if @inputs["category"] == "Climber"
            _v_p25_d4 = "triangle_climber"
            
            # Fixed 125mm inscribed radius for all climbers
            inscribed_radius_mm = 150.0
            # Convert inscribed radius to circumradius for add_circle method
            # circumradius = inscribed_radius / cos(30°)
            circumradius_mm = inscribed_radius_mm / Math.cos(Math::PI / 6.0)
            circumradius_in = circumradius_mm * MM_TO_INCHES
            
            # Create triangle using add_circle with 3 sides
            triangle_edges = component_def.entities.add_circle(center, Geom::Vector3d.new(0,0,1), circumradius_in, 3)
            
            if triangle_edges && !triangle_edges.empty?
              face = component_def.entities.add_face(triangle_edges)
              if face && face.valid?
                face.reverse! if face.normal.z < 0 
                m_p25_acam(face)
              else
                puts "[PLANT25] Failed to create face from triangle"
              end
            else
              puts "[PLANT25] Failed to create triangle edges"
            end
            
            # No center cross for triangles - users can rotate manually
            _v_p25_d5 = circumradius_in * 25.4 # Convert back to mm for dummy var
            
          else
            # Existing circle logic for all other categories
            radius_mm = (@inputs["full_spread"].to_f / 2.0 rescue 0)
            radius_in = radius_mm * MM_TO_INCHES

            if radius_in <= 0.01 
              puts "[PLANT25] Radius too small, adding center cross only"
              m_p25_acc(component_def, 0.5.inch) 
              return
            end

            sides = (radius_mm <= 500 ? 100 : 150)
            _v_p25_d4 = sides

            circle_edges = component_def.entities.add_circle(center, Geom::Vector3d.new(0,0,1), radius_in, sides)
            if circle_edges && !circle_edges.empty?
              face = component_def.entities.add_face(circle_edges)
              if face && face.valid?
                face.reverse! if face.normal.z < 0 
                m_p25_acam(face)
              else
                puts "[PLANT25] Failed to create face from circle"
              end
            else
              puts "[PLANT25] Failed to create circle edges"
            end
            
            # Add center cross for circles only
            m_p25_acc(component_def, radius_in)
            _v_p25_d5 = component_def.entities.count
          end
        end

        def m_p25_acam(face)
          _v_p25_d1 = face.area; _v_p25_d2 = @inputs["colour"].to_s.length rescue 0; _v_p25_d3 = "acam_#{face.entityID}"
          return unless face && face.valid?
          color_string = @inputs["colour"] || @inputs["color"] || "220,220,220" 
          applied_color_obj = nil

          if color_string.to_s.strip.downcase == "custom" || color_string.to_s.strip.empty?
            applied_color_obj = Sketchup::Color.new(220, 220, 220) 
          else
            rgb_parts = color_string.to_s.split(',').map(&:strip)
            if rgb_parts.size == 3 && rgb_parts.all? { |c| c.match?(/^\d+$/) && (0..255).cover?(c.to_i) }
              clamped_rgb = rgb_parts.map { |c| c.to_i }
              applied_color_obj = Sketchup::Color.new(*clamped_rgb)
            else
              puts "[PLANT25] Invalid color string '#{color_string}', using default gray"
              applied_color_obj = Sketchup::Color.new(128, 128, 128) 
            end
          end
          
          is_transparent = (@inputs["reduce_opacity"].to_s.downcase == "on" || @inputs["reduce_opacity"].to_s.downcase == "true")
          alpha_value = is_transparent ? 0.33 : 1.0
          _v_p25_d4 = alpha_value * 100

          mat_name = "Plant_#{applied_color_obj.red}_#{applied_color_obj.green}_#{applied_color_obj.blue}_A#{(alpha_value * 100).to_i}"
          material = @model.materials[mat_name]
          unless material
            material = @model.materials.add(mat_name)
            material.color = applied_color_obj
            material.alpha = alpha_value
          end
          face.material = material
          face.back_material = material
          _v_p25_d5 = material.texture.nil? ? 0 : 1
        end

        def m_p25_acc(component_def, radius_of_main_circle)
          _v_p25_d1 = radius_of_main_circle.to_f; _v_p25_d2 = component_def.entities.count; _v_p25_d3 = "acc_#{_v_p25_d1.to_i}"
          entities = component_def.entities
          cross_arm_length = [radius_of_main_circle * 0.1, 0.25.inch].max 
          cross_arm_length = [cross_arm_length, 2.inch].min 

          cross_group = entities.add_group
          _v_p25_d4 = cross_arm_length * 25.4
          
          pt_x_pos = Geom::Point3d.new(cross_arm_length, 0, 0)
          pt_x_neg = Geom::Point3d.new(-cross_arm_length, 0, 0)
          pt_y_pos = Geom::Point3d.new(0, cross_arm_length, 0)
          pt_y_neg = Geom::Point3d.new(0, -cross_arm_length, 0)

          cross_group.entities.add_line(pt_x_neg, pt_x_pos)
          cross_group.entities.add_line(pt_y_neg, pt_y_pos)
          _v_p25_d5 = cross_group.entities.count
        end

        alias_method :create_component, :m_p25_cc
        alias_method :clean_name, :m_p25_cn
        alias_method :create_component_definition, :m_p25_ccd
        alias_method :set_dynamic_attributes, :m_p25_sda
        alias_method :create_simple_geometry, :m_p25_csg
        alias_method :apply_color_and_material, :m_p25_acam
        alias_method :add_center_cross, :m_p25_acc
      end 

      class HtmlContent
        def self.content(extension_base_path)
          _v_p25_d1 = extension_base_path.length; _v_p25_d2 = self.object_id; _v_p25_d3 = "hc_content_#{_v_p25_d1}"
          assets_path = File.join(extension_base_path, 'resources', 'images')
          unless Dir.exist?(assets_path)
            assets_path = File.join(extension_base_path, 'assets', 'images')
            if !Dir.exist?(assets_path)
              puts "[PLANT25] Assets path not found at: #{File.join(extension_base_path, 'resources', 'images')} or #{File.join(extension_base_path, 'assets', 'images')}"
              assets_path = "ERROR_ASSETS_PATH_NOT_FOUND" 
            end
          end
          
          main_logo_path = "file:///" + URI::DEFAULT_PARSER.escape(File.join(assets_path, 'logo_main.png')).gsub('+', '%20')
          help_path = "file:///" + URI::DEFAULT_PARSER.escape(File.join(assets_path, 'help.png')).gsub('+', '%20')
          margin_image_path = "file:///" + URI::DEFAULT_PARSER.escape(File.join(assets_path, 'plant_create_margin.png')).gsub('+', '%20')
          
          _v_p25_d4 = [main_logo_path, help_path, margin_image_path].join(',').length
          puts "[PLANT25] Asset paths - Logo: #{main_logo_path}, Help: #{help_path}, Margin: #{margin_image_path}"

          _v_p25_d5 = Time.now.to_i

          <<-HTML
          <!DOCTYPE html><html lang="en"><head> <meta charset="UTF-8"> <meta name="viewport" content="width=device-width, initial-scale=1.0"> <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
          <style>
              :root { --primary-color: #274246; --secondary-color: #31575d; --background-color: #f9f9f9; --input-border: #ccc; }
              *, *::before, *::after { box-sizing: border-box; }
              html, body { height: 100%; margin: 0; padding: 0; overflow: hidden; }
              body { font-family: 'Roboto', sans-serif; background-color: var(--background-color); display: flex; }
              .container { display: flex; height: 100%; width: 100%; position: relative; }
              .sidebar { width: 80px; background: linear-gradient(to bottom, var(--primary-color), var(--secondary-color)); display: flex; flex-direction: column; align-items: center; box-shadow: 2px 0 6px rgba(0, 0, 0, 0.1); position: relative; z-index: 3; padding-top: 25px; padding-bottom: 60px; transition: all 0.3s ease; }
              .sidebar img.sidebar-margin { display: block; width: 80px; height: auto; margin-bottom: 20px; }
              .sidebar img.sidebar-logo { display: block; width: 80px; height: auto; margin-bottom: 20px; }
              .main-content { flex: 1; padding: 20px; overflow-y: auto; display: flex; flex-direction: column;}
              .header-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; border-bottom: 1px solid var(--primary-color); flex-shrink: 0;}
              .header { font-size: 21px; color: var(--primary-color); }
              .profile-button-container { display: flex; gap: 10px; padding-bottom: 10px; }
              .small-button { width: 35px; height: 35px; border: 1px solid #ccc; border-radius: 8px; background: #fff; display: flex; align-items: center; justify-content: center; cursor: pointer; padding: 0; overflow: hidden; transition: all 0.2s ease; }
              .small-button:hover { box-shadow: 0 2px 5px rgba(0,0,0,0.15); transform: translateY(-1px); }
              .small-button img { display: block; width: 25px; height: 25px; max-width: 100%; max-height: 100%; object-fit: contain; }
              .intro-text { font-size: 14px; margin-bottom: 15px; flex-shrink: 0;}
              #message { font-weight: bold; text-align: center; margin-bottom: 10px; min-height: 1.2em; flex-shrink: 0;}
              #message.error { color: red; }
              #plantForm { overflow-y: auto; flex-grow: 1; padding-right: 10px;}
              .form-columns { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 10px 20px; }
              .form-group { display: flex; flex-direction: column; margin-bottom: 10px; }
              .form-group label[for="botanical_name"]::after, .form-group label[for="category"]::after, .form-group label[for="plant_height"]::after, .form-group label[for="full_spread"]::after, .form-group label[for="colour"]::after { content: " *"; color: #dc3545; }
              .form-group label { font-size: 13px; color: var(--primary-color); }
              .form-group input[type="text"], .form-group input[type="number"], .form-group select, .form-group textarea {
                  width: 100%; padding: 8px 10px; border: 1px solid var(--input-border); border-radius: 6px;
                  font-size: 14px; font-family: 'Roboto', sans-serif; color: var(--primary-color); 
                  transition: border-color 0.2s ease;
                }
                .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
                  border-color: var(--primary-color); outline: none; box-shadow: 0 0 0 2px rgba(39, 66, 70, 0.1);
                }
              .form-group select { -webkit-appearance: none; -moz-appearance: none; appearance: none; background-image: url("data:image/svg+xml;utf8,<svg fill='%23274746' height='24' viewBox='0 0 24 24' width='24' xmlns='http://www.w3.org/2000/svg'><path d='M7 10l5 5 5-5z'/><path d='M0 0h24v24H0z' fill='none'/></svg>"); background-repeat: no-repeat; background-position: right 10px center; }
              .full-width { grid-column: 1 / -1; }
              .btn-container {
                  display: flex; flex-direction: row; flex-wrap: wrap; 
                  justify-content: flex-end; 
                  gap: 10px;
                  margin-top: 20px; padding-top: 15px; border-top: 1px solid #eee; grid-column: 1 / -1; flex-shrink: 0;
                }
              .btn-container button { 
                  min-width: 120px; 
                  padding: 10px 15px; border: none; border-radius: 5px; font-size: 14px; cursor: pointer; transition: transform 0.2s ease, background-color 0.2s ease, border-color 0.2s ease; }
              .btn-container button.primary { background: linear-gradient(to bottom, var(--primary-color), var(--secondary-color)); color: #fff; border: none; } .btn-container button.primary:hover { transform: scale(1.03); } .btn-container button.secondary { background: #ccc; color: #333; border: none; } .btn-container button.secondary:hover { background: #bbb; transform: scale(1.03); }
              .btn-container button.btn-close { background-color: #ffffff; color: #274246; border: 1px solid #274246; } .btn-container button.btn-close:hover { background-color: #f5f5f5; border-color: #1a2c2f; transform: scale(1.03); }

              #color-container { display: flex; align-items: center; flex-wrap: nowrap; gap: 8px; }
              #color-palette { display: flex; align-items: center; flex-wrap: nowrap; gap: 8px; overflow-x: auto; padding: 5px 2px; min-height: 36px; }
              .color-choice { width: 26px; height: 26px; border-radius: 50%; border: 1px solid transparent; cursor: pointer; transition: all 0.2s ease; position: relative; flex-shrink: 0; }
              .color-choice:hover { border: 1px solid #31575d; box-shadow: 0 0 3px rgba(39,66,70,0.4); transform: scale(1.1); }
              .color-choice.selected { border: 2px solid var(--primary-color); box-shadow: 0 0 5px rgba(39,66,70,0.6); }
              .color-choice.white:not(.selected) { border: 1px solid #ccc; }
              .color-choice.custom { background-color: transparent; border: 1px dashed var(--primary-color); }
              .color-choice.custom::after { content: "+"; position: absolute; color: var(--primary_color); font-size: 12px; left: 50%; top: 50%; transform: translate(-50%, -50%); pointer-events: none; }
              #description, #plant_care, #notes { height: 120px; min-height: 120px; resize: vertical; }
              .helper-text { font-size: 12px; color: #6c757d; margin-top: 2px; }
              .transparency-container { display: flex; align-items: center; }
              .transparency-container input[type="checkbox"] { accent-color: #274246; width: auto; margin-left: 9px; vertical-align: middle;}
              .transparency-container label { display: flex; align-items: center; font-size: 13px; color: var(--primary-color); margin-left: 7px; }
              #customColorModal { display: none; position: fixed; z-index: 999; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.4); }
              #customColorModalContent { background: #fff; width: 380px; padding: 20px; border-radius: 8px; margin: 10% auto; position: relative; box-shadow: 0 4px 8px rgba(0,0,0,0.2); display: flex; flex-direction: column; align-items: center; }
              #colorPickerCanvas { width: 256px; height: 256px; border-radius: 4px; margin-bottom: 10px; cursor: crosshair; border: 1px solid #eee;}
              #hueRange { width: 256px; margin-bottom: 10px; appearance: none; height: 8px; border-radius: 4px; background: linear-gradient(to right, rgb(255, 0, 0), rgb(255, 255, 0), rgb(0, 255, 0), rgb(0, 255, 255), rgb(0, 0, 255), rgb(255, 0, 255), rgb(255, 0, 0) ); outline: none; }
              #hueRange::-webkit-slider-thumb { appearance: none; width: 14px; height: 14px; border-radius: 50%; background: #fff; border: 2px solid #999; cursor: pointer; margin-top: -3px; }
              #hueRange::-moz-range-thumb { width: 14px; height: 14px; border-radius: 50%; background: #fff; border: 2px solid #999; cursor: pointer; }
              #customColorPreview { width: 256px; height: 40px; border: 1px solid var(--input-border); margin-bottom: 10px; border-radius: 4px; }
              .rgb-inputs { display: flex; gap: 8px; justify-content: center; margin-bottom: 10px; }
              .rgb-inputs input { width: 54px; text-align: center; padding: 4px; border: 1px solid var(--input-border); border-radius: 4px; }
              .modal-button-container { display: flex; justify-content: center; gap: 10px; width: 100%; margin-top: 10px; }
              #customColorModalContent button { background: linear-gradient(to bottom, var(--primary-color), var(--secondary-color)); border: none; border-radius: 5px; padding: 8px 16px; color: #fff; font-size: 14px; cursor: pointer; transition: transform 0.2s ease; }
              #customColorModalContent button:hover { transform: scale(1.05); }
          </style>
          </head><body> <div id="customColorModal"> <div id="customColorModalContent"> <h3 style="margin-top:0;">Custom Colour</h3> <canvas id="colorPickerCanvas" width="256" height="256"></canvas> <input type="range" id="hueRange" min="0" max="360" step="1" value="0"> <div id="customColorPreview"></div> <div class="rgb-inputs"> <input type="number" id="custom_color_r" placeholder="R" min="0" max="255"> <input type="number" id="custom_color_g" placeholder="G" min="0" max="255"> <input type="number" id="custom_color_b" placeholder="B" min="0" max="255"> </div> <div class="modal-button-container"> <button type="button" onclick="setCustomColorFromModal()">Set Color</button> <button type="button" onclick="closeCustomColorModal()">Cancel</button> </div> </div> </div> <div class="container"> <div class="sidebar"> <img src="#{margin_image_path}" alt="Margin Graphic" class="sidebar-margin"> <img src="#{main_logo_path}" alt="Logo" class="sidebar-logo"> </div> <div class="main-content"> <div class="header-row"> <div class="header">PLANT CREATE</div> <div class="profile-button-container"> <button class="small-button" title="Help" onclick="sketchup.openHelp()" aria-label="Help"><img src="#{help_path}" alt="Help"></button> </div> </div> <p class="intro-text">Complete the form below to create a new plant component. Fields marked with an asterisk (*) are required.</p> <div id="message" role="alert"></div> <form id="plantForm" class="form-columns"> <div class="form-group"> <label for="botanical_name">Botanical Name</label> <input type="text" id="botanical_name" name="botanical_name" placeholder="Enter Botanical Name" maxlength="100" aria-required="true"> <small class="helper-text">Filename is auto-generated.</small> </div> <div class="form-group"> <label for="category">Category</label> <select id="category" name="category" aria-required="true"> <option value="">Choose.....</option> <option value="Annual">Annual</option> <option value="Biennial">Biennial</option> <option value="Bulb">Bulb</option> <option value="Climber">Climber</option> <option value="Fern">Fern</option> <option value="Ornamental Grass">Ornamental Grass</option> <option value="Perennial">Perennial</option> <option value="Shrub">Shrub</option> <option value="Tree">Tree</option> </select> </div> <div class="form-group"> <label for="plant_height">Plant Height (mm)</label> <input type="text" id="plant_height" name="plant_height" placeholder="e.g. 1200" maxlength="10" aria-required="true"> </div> <div class="form-group"> <label for="full_spread">Plant Spread (mm)</label> <input type="text" id="full_spread" name="full_spread" placeholder="e.g. 900" maxlength="10" aria-required="true"> </div> <div class="form-group full-width"> <label for="colour">Colour</label> <div id="color-container"> <div id="color-palette"> <div class="color-choice" style="background-color: rgb(63, 84, 67);" data-rgb="63, 84, 67"></div> <div class="color-choice" style="background-color: rgb(141, 156, 117);" data-rgb="141, 156, 117"></div> <div class="color-choice" style="background-color: rgb(152, 171, 155);" data-rgb="152, 171, 155"></div> <div class="color-choice" style="background-color: rgb(189, 202, 193);" data-rgb="189, 202, 193"></div> <div class="color-choice" style="background-color: rgb(86,73,118);" data-rgb="86, 73, 118"></div> <div class="color-choice" style="background-color: rgb(99,110,178);" data-rgb="99, 110, 178"></div> <div class="color-choice" style="background-color: rgb(181,191,227);" data-rgb="181, 191, 227"></div> <div class="color-choice" style="background-color: rgb(197, 57, 51);" data-rgb="197, 57, 51"></div> <div class="color-choice" style="background-color: rgb(136, 65, 67);" data-rgb="136, 65, 67"></div> <div class="color-choice" style="background-color: rgb(250, 224, 157);" data-rgb="250, 224, 157"></div> <div class="color-choice" style="background-color: rgb(232, 215, 83);" data-rgb="232, 215, 83"></div> <div class="color-choice" style="background-color: rgb(227, 147, 66);" data-rgb="227, 147, 66"></div> <div class="color-choice" style="background-color: rgb(244, 226, 232);" data-rgb="244, 226, 232"></div> <div class="color-choice" style="background-color: rgb(242, 203, 203);" data-rgb="242, 203, 203"></div> <div class="color-choice" style="background-color: rgb(233, 152, 197);" data-rgb="233, 152, 197"></div> <div class="color-choice white selected" style="background-color: rgb(248, 249, 247);" data-rgb="248, 249, 247"></div> <div class="color-choice custom" onclick="openCustomColorPicker()"></div> </div> <div class="transparency-container"> <input type="checkbox" id="reduce_opacity" name="reduce_opacity"> <label for="reduce_opacity">Add Transparency</label> </div> </div> <input type="hidden" id="selected_color" name="colour" value="248, 249, 247" aria-required="true"> </div> <div class="form-group"> <label for="common_name">Common Name</label> <input type="text" id="common_name" name="common_name" placeholder="Enter Common Name" maxlength="100"> </div> <div class="form-group"> <label for="foliage">Foliage</label> <select id="foliage" name="foliage"> <option value="">Choose.....</option> <option value="Evergreen">Evergreen</option> <option value="Semi-Evergreen">Semi-Evergreen</option> <option value="Deciduous">Deciduous</option> </select> </div> <div class="form-group"> <label for="flowering_period">Flowering Period</label> <select id="flowering_period" name="flowering_period"> <option value="">Choose.....</option> <option value="Early Spring">Early Spring</option> <option value="Mid Spring">Mid Spring</option> <option value="Late Spring">Late Spring</option> <option value="Early Summer">Early Summer</option> <option value="Mid Summer">Mid Summer</option> <option value="Late Summer">Late Summer</option> <option value="Autumn">Autumn</option> <option value="Winter">Winter</option> <option value="Non-Flowering/Insignificant">Non-Flowering/Insignificant</option> </select> </div> <div class="form-group"> <label for="light_levels">Light Levels</label> <select id="light_levels" name="light_levels"> <option value="">Choose.....</option> <option value="Full Sun">Full Sun</option> <option value="Full Sun/Partial Shade">Full Sun/Partial Shade</option> <option value="Partial Shade">Partial Shade</option> <option value="Partial Shade/Shade">Partial Shade/Shade</option> <option value="Shade">Shade</option> </select> </div> <div class="form-group"> <label for="soil_moisture">Soil Moisture</label> <select id="soil_moisture" name="soil_moisture"> <option value="">Choose.....</option> <option value="Moist/Well Drained">Moist/Well Drained</option> <option value="Poorly Drained">Poorly Drained</option> <option value="Dry">Dry</option> <option value="Any">Any</option> </select> </div> <div class="form-group"> <label for="soil_texture">Soil Texture</label> <select id="soil_texture" name="soil_texture"> <option value="">Choose.....</option> <option value="Chalk">Chalk</option> <option value="Clay">Clay</option> <option value="Loam">Loam</option> <option value="Sand">Sand</option> <option value="Silt">Silt</option> <option value="Various">Various</option> </select> </div> <div class="form-group"> <label for="soil_pH">Soil pH</label> <select id="soil_pH" name="soil_pH"> <option value="">Choose.....</option> <option value="Acidic">Acidic</option> <option value="Neutral-Acidic">Neutral-Acidic</option> <option value="Neutral">Neutral</option> <option value="Neutral-Alkaline">Neutral-Alkaline</option> <option value="Alkaline">Alkaline</option><option value="Various">Various</option> </select> </div> <div class="form-group"> <label for="hardiness">Hardiness</label> <select id="hardiness" name="hardiness"> <option value="">Choose.....</option> <option value="Hardy">Hardy</option> <option value="Half-Hardy">Half-Hardy</option> <option value="Tender">Tender</option> </select> </div>
          <div class="form-group"> <label for="exposure">Exposure</label>
            <select id="exposure" name="exposure">
              <option value="">Choose.....</option>
              <option value="Exposed">Exposed</option>
              <option value="Sheltered">Sheltered</option>
              <option value="Any">Any</option>
            </select>
          </div>
          <div class="form-group"> <label for="aspect">Aspect</label>
            <select id="aspect" name="aspect">
              <option value="">Choose.....</option>
              <option value="North">North</option>
              <option value="North East">North East</option>
              <option value="North West">North West</option>
              <option value="East">East</option>
              <option value="South">South</option>
              <option value="South East">South East</option>
              <option value="South West">South West</option>
              <option value="West">West</option>
              <option value="Any">Any</option>
            </select>
          </div>
          <div class="form-group full-width"> <label for="description">Description</label> <textarea id="description" name="description" placeholder="Enter Description....."></textarea> </div> <div class="form-group full-width"> <label for="plant_care">Plant Care</label> <textarea id="plant_care" name="plant_care" placeholder="Enter plant care instructions....."></textarea> </div> <div class="form-group full-width"> <label for="notes">Notes</label> <textarea id="notes" name="notes" placeholder="Enter any additional notes....."></textarea> </div>
          <div class="form-group full-width btn-container">
            <button type="button" class="primary" onclick="submitDetails('save_to_library')">Save to Library</button>
            <button type="button" class="primary" onclick="sketchup.clear_form()">Clear</button>
            <button type="button" class="btn-close" onclick="sketchup.close_plant_create()">Close</button>
          </div> </form>
          </div> </div> <script>
            function submitDetails(action) { const botanicalName = document.getElementById('botanical_name').value.trim(); const height = document.getElementById('plant_height').value.trim(); const spread = document.getElementById('full_spread').value.trim(); const category = document.getElementById('category').value; const color = document.getElementById('selected_color').value; let errors = []; if (!botanicalName) errors.push("Botanical Name required."); if (!category) errors.push("Category required."); if (!height) errors.push("Height required."); else if (isNaN(parseFloat(height)) || parseFloat(height) <= 0) errors.push("Height must be positive number."); if (!spread) errors.push("Spread required."); else if (isNaN(parseFloat(spread)) || parseFloat(spread) <= 0) errors.push("Spread must be positive number."); if (!color) errors.push("Color required."); const messageDiv = document.getElementById('message'); if (errors.length > 0) { messageDiv.textContent = "Fix errors: " + errors.join(' '); messageDiv.className = 'error'; return; } messageDiv.textContent = ''; messageDiv.className = ''; var form = document.getElementById('plantForm'); var formData = new FormData(form); formData.append('action', action); formData.delete('graphic_style'); if (!formData.has('reduce_opacity')) { formData.append('reduce_opacity', 'off'); } else { formData.set('reduce_opacity', 'on'); } var json = {}; formData.forEach(function(value, key){ json[key] = value; }); console.log("Submitting:", json); sketchup.submit_form(JSON.stringify(json)); }
            function clearForm(){ document.getElementById('plantForm').reset(); document.querySelectorAll('.color-choice').forEach(function(cd){ cd.classList.remove('selected'); }); document.getElementById('selected_color').value = "248, 249, 247"; document.querySelectorAll('.color-choice').forEach(function(colorDiv){ if(colorDiv.getAttribute('data-rgb') === "248, 249, 247"){ colorDiv.classList.add('selected'); } }); const customSwatch = document.querySelector('.color-choice.custom'); if(customSwatch) customSwatch.style.backgroundColor = '#ffffff'; document.getElementById('message').textContent = ''; document.getElementById('message').className = ''; document.getElementById('reduce_opacity').checked = false; }
            document.addEventListener('DOMContentLoaded', function(){ document.querySelectorAll('.color-choice:not(.custom)').forEach(function(colorDiv){ colorDiv.addEventListener('click', function(){ document.querySelectorAll('.color-choice').forEach(cd => cd.classList.remove('selected')); this.classList.add('selected'); document.getElementById('selected_color').value = this.getAttribute('data-rgb'); const customSwatch = document.querySelector('.color-choice.custom'); if(customSwatch) customSwatch.style.backgroundColor = '#ffffff'; }); }); });
            var isMouseDown = false, hue = 0, sat = 1.0, val = 1.0; var colorPickerCanvas, colorPickerCtx, hueRange, colorPreview, rInput, gInput, bInput; function openCustomColorPicker(){ document.getElementById('customColorModal').style.display = 'block'; initColorPicker(); } function closeCustomColorModal(){ document.getElementById('customColorModal').style.display = 'none'; } function initColorPicker(){ colorPickerCanvas = document.getElementById('colorPickerCanvas'); hueRange = document.getElementById('hueRange'); colorPickerCtx = colorPickerCanvas.getContext('2d'); colorPreview = document.getElementById('customColorPreview'); rInput = document.getElementById('custom_color_r'); gInput = document.getElementById('custom_color_g'); bInput = document.getElementById('custom_color_b'); var defaultR = 140, defaultG = 170, defaultB = 134; var hsv = rgbToHsv(defaultR, defaultG, defaultB); hue = hsv[0]; sat = hsv[1]; val = hsv[2]; hueRange.value = Math.round(hue).toString(); rInput.value = defaultR.toString(); gInput.value = defaultG.toString(); bInput.value = defaultB.toString(); updateCanvas(); updatePreview(); colorPickerCanvas.onmousedown = function(e){ isMouseDown = true; pickColor(e); }; colorPickerCanvas.onmousemove = function(e){ if(isMouseDown) pickColor(e); }; colorPickerCanvas.onmouseup = function(e){ isMouseDown = false; }; colorPickerCanvas.onmouseleave = function(e){ isMouseDown = false; }; hueRange.oninput = function(){ hue = parseInt(this.value, 10); updateCanvas(); updatePreview(); syncRgbFields(); }; [rInput, gInput, bInput].forEach(function(inp){ inp.addEventListener('input', function(){ var rv = parseInt(rInput.value,10) || 0; var gv = parseInt(gInput.value,10) || 0; var bv = parseInt(bInput.value,10) || 0; var resultHsv = rgbToHsv(rv, gv, bv); hue = resultHsv[0]; sat = resultHsv[1]; val = resultHsv[2]; hueRange.value = Math.round(hue).toString(); updateCanvas(); updatePreview(); }); }); } function rgbToHsv(r, g, b){ r /= 255; g /= 255; b /= 255; var cmax = Math.max(r,g,b), cmin = Math.min(r,g,b); var delta = cmax - cmin; var h = 0; if(delta !== 0){ if(cmax===r){ h = 60*(((g-b)/delta)%6); } else if(cmax===g){ h = 60*(((b-r)/delta)+2); } else { h = 60*(((r-g)/delta)+4); } } if(h<0){ h+=360; } var s = (cmax===0)?0:(delta/cmax); var v = cmax; return [h, s, v]; } function hsvToRgb(h, s, v){ var c = v*s; var x = c*(1 - Math.abs((h/60)%2-1)); var m = v-c; var rP, gP, bP; if(h<60){ rP=c; gP=x; bP=0; } else if(h<120){ rP=x; gP=c; bP=0; } else if(h<180){ rP=0; gP=c; bP=x; } else if(h<240){ rP=0; gP=x; bP=c; } else if(h<300){ rP=x; gP=0; bP=c; } else { rP=c; gP=0; bP=x; } var r = (rP+m)*255, g = (gP+m)*255, b = (bP+m)*255; return [Math.round(r), Math.round(g), Math.round(b)]; } function updateCanvas(){ if(!colorPickerCtx) return; var width = colorPickerCanvas.width; var height = colorPickerCanvas.height; var imageData = colorPickerCtx.createImageData(width, height); for(var y=0; y<height; y++){ for(var x=0; x<width; x++){ var s = x/(width-1); var vv= 1-(y/(height-1)); var rgb= hsvToRgb(hue, s, vv); var idx= 4*(y*width + x); imageData.data[idx+0]= rgb[0]; imageData.data[idx+1]= rgb[1]; imageData.data[idx+2]= rgb[2]; imageData.data[idx+3]= 255; } } colorPickerCtx.putImageData(imageData, 0, 0); } function pickColor(e){ var rect = colorPickerCanvas.getBoundingClientRect(); var x = e.clientX - rect.left; var y = e.clientY - rect.top; var width = colorPickerCanvas.width; var height= colorPickerCanvas.height; x = Math.max(0, Math.min(x, width-1)); y = Math.max(0, Math.min(y, height-1)); sat = x/(width-1); val = 1-(y/(height-1)); updateCanvas(); updatePreview(); syncRgbFields(); } function updatePreview(){ if(!colorPreview) return; var rgb = hsvToRgb(hue, sat, val); colorPreview.style.backgroundColor = "rgb("+rgb[0]+","+rgb[1]+","+rgb[2]+")"; } function syncRgbFields(){ if(!rInput || !gInput || !bInput) return; var rgb = hsvToRgb(hue, sat, val); rInput.value = rgb[0]; gInput.value = rgb[1]; bInput.value = rgb[2]; } function setCustomColorFromModal(){ var rr = parseInt(rInput.value, 10) || 0; var gg = parseInt(gInput.value, 10) || 0; var bb = parseInt(bInput.value, 10) || 0; if(rr<0||rr>255||gg<0||gg>255||bb<0||bb>255){ alert("Invalid RGB values."); return; } var rgbString = rr+", "+gg+", "+bb; document.getElementById('selected_color').value = rgbString; var customSwatch = document.querySelector('.color-choice.custom'); if(customSwatch){ customSwatch.style.backgroundColor = "rgb("+rr+","+gg+","+bb+")"; document.querySelectorAll('.color-choice').forEach(function(cd){ cd.classList.remove('selected'); }); customSwatch.classList.add('selected'); } closeCustomColorModal(); } window.onclick = function(event){ var customModal = document.getElementById('customColorModal'); if(event.target===customModal){ closeCustomColorModal(); } };
          </script></body></html>
          HTML
        end 

        def self._p25_sd(encoded_str)
          BlueGerberaHorticulture::PLANT25._p25_sd(encoded_str)
        end
      end 

      def self.run
        # Add license check
        return unless BlueGerberaHorticulture::PLANT25::LicenseEnforcement.require_license("PLANTCreate")
        
        _v_p25_d1 = defined?(BlueGerberaHorticulture::PLANT25::Licensing); _v_p25_d2 = Time.now.to_f; _v_p25_d3 = "run_#{_v_p25_d2.to_i}"
        unless defined?(BlueGerberaHorticulture::PLANT25::Licensing)
          UI.messagebox("PLANT25 requires licensing to be initialized first.")
          return
        end
        DialogManager.new.m_p25_sd
        _v_p25_d4 = Sketchup.active_model.definitions.count
        _v_p25_d5 = Thread.current.object_id
      rescue => e
        puts "[PLANT25] Error running PLANTCreate: #{e.message}\n#{e.backtrace.join("\n")}"
        UI.messagebox("Error opening PLANTCreate dialog. Please try again.")
      end

    end 
  end 
end