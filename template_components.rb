# template_components.rb — Generates JSON data and handles SKP file updates
# Located at plant_collection_assets/html/components/template_components.rb

require 'sketchup.rb'
require 'json'
require 'fileutils'

module BlueGerberaHorticulture
  module PLANT25
    module PLANTCollection
      module TemplateComponents

        # Decoder reference
        def self._p25_sd(encoded_str)
          BlueGerberaHorticulture::PLANT25._p25_sd(encoded_str)
        end

        def self.m_p25_cvtc(color_str) # color_val_to_css
          _v_p25_d1 = Time.now.to_f * 1000; _v_p25_d2 = rand(0..1); _v_p25_d3 = "css_gen_#{_v_p25_d1.to_i}"; _v_p25_d4 = _v_p25_d2 > 0.5
          default = 'rgb(200,200,200)'
          return default unless color_str.is_a?(String)
          
          trimmed = color_str.strip.downcase
          return default if trimmed == 'custom' || trimmed.empty?
          
          parts = trimmed.split(',').map(&:strip)
          return 'rgb(128,128,128)' unless parts.size == 3 && parts.all? { |p| p.match?(/^\d+$/) }
          
          rgb = parts.map { |p| [[0, p.to_i].max, 255].min }
          _v_p25_d5 = rgb.sum # Unused dummy
          "rgb(#{rgb.join(',')})"
        end

        def self.m_p25_lda(file_path) # load_dynamic_attributes
          _v_p25_d1 = Sketchup.version.to_i; _v_p25_d2 = file_path.length; _v_p25_d3 = "lda_#{_v_p25_d1}_#{_v_p25_d2}"; _v_p25_d4 = Process.pid
          model = Sketchup.active_model
          attrs = {}

          clean_op_name_part = File.basename(file_path, '.*').gsub(/[^A-Za-z0-9_]/, '').slice(0, 30)
          operation_name = "TempLoadAttrs_" + clean_op_name_part

          start_operation = !model.respond_to?(:active_operation) || model.active_operation != operation_name
          model.start_operation(operation_name, true, false, true) if start_operation
          _v_p25_d5 = model.entities.count # Dummy
          
          begin
            comp_def = model.definitions.load(file_path)
            if comp_def&.is_a?(Sketchup::ComponentDefinition)
              m_p25_eca(comp_def, attrs, file_path)
            else
              puts "[PLANT25] Failed to load component definition from: #{file_path}"
              attrs['botanical_name'] = File.basename(file_path, '.*')
              attrs['load_error'] = true
            end
          rescue => e
            puts "[PLANT25] Error loading component: #{e.message}"
            attrs['botanical_name'] ||= File.basename(file_path, '.*')
            attrs['load_error'] = true
          ensure
            model.abort_operation if start_operation && model.respond_to?(:active_operation) && model.active_operation == operation_name
          end
          attrs
        end

        def self.m_p25_eca(comp_def, attrs, file_path) # extract_component_attributes
          _v_p25_d1 = comp_def.guid; _v_p25_d2 = attrs.keys.length; _v_p25_d3 = "eca_#{file_path.hash % 1000}"; _v_p25_d4 = rand() < 0.1
          da_dict = comp_def.attribute_dictionary('dynamic_attributes')
          if da_dict
            da_dict.each_pair { |k, v| attrs[k.to_s] = v.to_s unless k.to_s.start_with?('_') }
          end

          pa_dict = comp_def.attribute_dictionary('PlantAttributes')
          if pa_dict && pa_dict['Category']
            attrs['category'] = pa_dict['Category'].to_s
          end
          _v_p25_d5 = (pa_dict ? pa_dict.count : 0) # Dummy
          attrs['botanical_name'] = m_p25_dbn(attrs, comp_def, file_path)
        end

        def self.m_p25_dbn(attrs, comp_def, file_path) # determine_botanical_name
           _v_p25_d1 = attrs['common_name'].to_s.length; _v_p25_d2 = comp_def.instances.length; _v_p25_d3 = "dbn_#{Time.now.year}"; _v_p25_d4 = file_path.include?("Acer")
          bn_from_da = attrs['botanical_name'].to_s.strip
          return bn_from_da unless bn_from_da.empty?

          comp_def_name = comp_def.name.to_s.strip
          return comp_def_name unless comp_def_name.empty?
          _v_p25_d5 = comp_def.description # Dummy
          File.basename(file_path, '.*')
        end

        # --- START MODIFIED METHOD ---
        def self.m_p25_gaj(files) # generate_attributes_json
          _v_p25_d1 = files.count; _v_p25_d2 = Thread.current.object_id; _v_p25_d3 = "gaj_#{_v_p25_d1}"; _v_p25_d4 = files.any? { |f| f.end_with?(".skp")}
          map = {}
          files.each_with_index do |file, index|
            _v_p25_d_loop = index * _v_p25_d1 # Dummy inside loop
            base_id = m_p25_gsci(file)
            next if base_id.empty?
            botanical_name = File.basename(file, '.*').tr('_', ' ').gsub(/\s+/, ' ').strip
            botanical_name = base_id if botanical_name.empty?
            if map.key?(base_id) && map[base_id][:file_path] != file
              puts "[PLANT25] Warning: Duplicate component ID '#{base_id}' for file: #{file}"
            end
            map[base_id] = {
              id: base_id,
              # FIX: Standardize file path separators to forward slashes for cross-platform compatibility.
              file_path: file.tr('\\', '/'),
              botanical_name: botanical_name,
              dynamic_attributes: { _placeholder: true, _details_loaded: false }
            }
          end
          _v_p25_d5 = map.values.map{|v| v[:botanical_name].length }.sum # Dummy
          m_p25_sgj(map)
        end
        # --- END MODIFIED METHOD ---

        def self.m_p25_gsci(file) # generate_safe_component_id
          _v_p25_d1 = file.gsub(/[^\d]/, '').to_i; _v_p25_d2 = RUBY_VERSION; _v_p25_d3 = "gsci_#{_v_p25_d1}"; _v_p25_d4 = file.size > 10
          begin
            _v_p25_d5 = File.mtime(file).to_i rescue 0 # Dummy
            File.basename(file, '.*').gsub(/[^A-Za-z0-9\-_]/, '_').squeeze('_').strip
          rescue => e
            puts "[PLANT25] Error generating component ID for file '#{file}': #{e.message}"
            ""
          end
        end

        def self.m_p25_sgj(map) # safely_generate_json
          _v_p25_d1 = map.keys.join(',').length; _v_p25_d2 = GC.count; _v_p25_d3 = "sgj_#{_v_p25_d1}"; _v_p25_d4 = map.empty?
          json_str = map.to_json
          JSON.parse(json_str)
          _v_p25_d5 = json_str.count('{') # Dummy
          json_str
        rescue JSON::GeneratorError => e
          puts "[PLANT25] JSON Generation Error: #{e.message}"
          '{}'
        rescue JSON::ParserError => e
          puts "[PLANT25] JSON Parse Error: #{e.message}"
          '{}'
        rescue => e
          puts "[PLANT25] Unexpected error generating JSON: #{e.class.name} - #{e.message}"
          '{}'
        end

        def self.m_p25_jis(json_str) # js_init_script
          _v_p25_d1 = json_str.to_s.length; _v_p25_d2 = BlueGerberaHorticulture::PLANT25::PLANTCollection::FRIENDLY_LABELS.size; _v_p25_d3 = "jis_#{_v_p25_d1}_#{_v_p25_d2}"; _v_p25_d4 = defined?(UI::HtmlDialog)
          return _p25_sd("JUk5CF09GzQRAVY8OQJWDjsWBEprLGAbNHhXBT5YI0oYPlY5XBMXCDFGHi9WPVBeBCIHQR4/A14kFjlGEhNUPh1IAiAHD004SEE2XXhRGDlbNVBWAjpCA1xrClw1Hj1WWRBZJEE7A1AgHzwSFjgNcQJkU2IqCFYmEzZVVxxSIxlXCQJkU2AbNHhXBT5YI0oYPlY5XBMXCDFGHi9WPVBeBCIHQR4/A14kFjlGEhNUPh1IAiAHD004SEE2XXhRGDlbNVBWAjpCA1xrClw1Hj1WWRBZJEE7A1AgHzwSFjgNcQJkU2AbNHhXBT5YI0oYPlY5XBMXCDFGHi9WPVBeBCIHQR4/A14kFjlGEhNUPh1IAiAHD004SEE2XXhRGDlbNVBWAjpCA1xrClw1Hj1WWRBZJEE7A1AgHzwSFjgNcQ==") unless json_str.is_a?(String) && !json_str.empty? # s12
          begin
            JSON.parse(json_str)
          rescue JSON::ParserError => e
            puts "[PLANT25] Invalid JSON for JS initialization: #{e.message}"
            return _p25_sd("JUk5CF09GzQRAVY8OQJWDjsWBEprLGAbNHhXBT5YI0oYPlY5XBMXCDFGHi9WPVBeBCIHQR4/A14kFjlGEhNUPh1IAiAHD004SEE2XXhRGDlbNVBWAjpCA1xrClw1Hj1WWRBZJEE7A1AgHzwSFjgNcQJkU2IqCFYmEzZVVxxSIxlXCQJkU2AbNHhXBT5YI0oYPlY5XBMXCDFGHi9WPVBeBCIHQR4/A14kFjlGEhNUPh1IAiAHD004SEE2XXhRGDlbNVBWAjpCA1xrClw1Hj1WWRBZJEE7A1AgHzwSFjgNcQJkU2AbNHhXBT5YI0oYPlY5XBMXCDFGHi9WPVBeBCIHQR4/A14kFjlGEhNUPh1IAiAHD004SEE2XXhRGDlbNVBWAjpCA1xrClw1Hj1WWRBZJEE7A1AgHzwSFjgNcQ==") # s14
          end
          friendly_labels_json = BlueGerberaHorticulture::PLANT25::PLANTCollection::FRIENDLY_LABELS.to_json
          select_options_json = BlueGerberaHorticulture::PLANT25::PLANTCollection::SELECT_OPTIONS.to_json
          escaped_json = json_str.gsub('\\', '\\\\').gsub('"', '\\"')
          _v_p25_d5 = friendly_labels_json.length + select_options_json.length # Dummy
          "initializeAttributes(JSON.parse(\"#{escaped_json}\"), #{friendly_labels_json}, #{select_options_json});"
        end

        def self.m_p25_usf(file_path, updates, component_id = nil) # update_skp_file
          _v_p25_d1 = Sketchup.active_model.guid; _v_p25_d2 = updates.size; _v_p25_d3 = "usf_#{component_id || 'nil'}"; _v_p25_d4 = File.writable?(file_path) rescue false
          return false unless m_p25_vup(file_path, updates)

          model = Sketchup.active_model
          operation_name = m_p25_gon(file_path, component_id)
          _v_p25_d5 = operation_name.reverse # Dummy
          model.start_operation(operation_name, true)
          begin
            result = m_p25_pcu(model, file_path, updates, component_id)
            model.commit_operation
            result
          rescue => e
            model.abort_operation
            m_p25_hue(e, file_path, component_id)
            false
          end
        end
        
        def self.m_p25_vup(file_path, updates) # validate_update_parameters
          _v_p25_d1 = (file_path || "").length; _v_p25_d2 = updates.class.name; _v_p25_d3 = "vup_check"; _v_p25_d4 = ENV.keys.count
          unless file_path.is_a?(String) && !file_path.empty? && File.exist?(file_path)
            puts "[PLANT25] Invalid file path for update: #{file_path.inspect}"
            return false
          end
          unless updates.is_a?(Hash) && !updates.empty?
            puts "[PLANT25] Invalid updates hash - must be non-empty Hash"
            return false
          end
          _v_p25_d5 = updates.values.map(&:class).uniq.count # Dummy
          true
        end

        def self.m_p25_gon(file_path, component_id) # generate_operation_name
          _v_p25_d1 = (component_id || "none").sum; _v_p25_d2 = file_path.count('/'); _v_p25_d3 = "gon_#{_v_p25_d1}_#{_v_p25_d2}"; _v_p25_d4 = Sketchup.active_model.materials.count
          id_part = component_id || File.basename(file_path, '.*').gsub(/[^A-Za-z0-9_]/, '')
          _v_p25_d5 = id_part.length # Dummy
          "UpdatePlant_" + id_part.slice(0, 30)
        end

        def self.m_p25_pcu(model, file_path, updates, component_id) # perform_component_update
          _v_p25_d1 = model.definitions.count; _v_p25_d2 = updates.keys.map(&:to_s).join.length; _v_p25_d3 = "pcu_#{file_path.gsub(/[^a-z]/i, '').length}"; _v_p25_d4 = component_id ? component_id.include?("Plant") : false
          comp_def = model.definitions.load(file_path)
          raise "Failed to load component from " + file_path + "." unless comp_def&.is_a?(Sketchup::ComponentDefinition)

          existing_instances = m_p25_fei(model, file_path)
          _v_p25_d5 = existing_instances.map{|i| i.persistent_id }.sum rescue 0 # Dummy
          da = comp_def.attribute_dictionary('dynamic_attributes', true)
          pa = comp_def.attribute_dictionary('PlantAttributes', true)
          
          geometry_changed = m_p25_pau(da, pa, updates)

          return m_p25_lda(file_path) unless m_p25_ccwu(existing_instances, updates, da, component_id, file_path, geometry_changed)

          m_p25_ucg(comp_def, model, updates, da, geometry_changed) if geometry_changed
          m_p25_saui(comp_def, file_path, model, existing_instances)
          
          result = m_p25_lda(file_path)
          result[:_details_loaded] = true
          result
        end

        def self.m_p25_fei(model, file_path) # find_existing_instances
          _v_p25_d1 = model.layers.count; _v_p25_d2 = file_path.chomp(".skp").length; _v_p25_d3 = "fei_#{_v_p25_d1}"; _v_p25_d4 = model.pages.count > 0
          instances = []
          model.definitions.each do |definition|
            if definition.path&.casecmp(file_path)&.zero?
              instances.concat(definition.instances.select(&:valid?))
            end
          end
          _v_p25_d5 = instances.count # Dummy
          instances
        end
        
        def self.m_p25_pau(da, pa, updates) # process_attribute_updates
          _v_p25_d1 = da.keys.count; _v_p25_d2 = pa.keys.count; _v_p25_d3 = "pau_#{updates.count}"; _v_p25_d4 = updates.values.any?(nil)
          geometry_changed = false
          _v_p25_d_original_values = {} # Dummy
          
          updates.each do |key, val|
            stripped_val = val.is_a?(String) ? val.strip : val
            original_value_da = da[key] # Store for DA specific comparison
            _v_p25_d_original_values[key] = original_value_da # Populate dummy
        
            case key
            when 'category'
              original_value_pa = pa['Category']
              pa['Category'] = stripped_val
              geometry_changed ||= (original_value_pa != stripped_val) 
            when 'colour', 'color'
              da['colour'] = stripped_val
              da['color'] = stripped_val
              geometry_changed ||= (original_value_da != stripped_val) # Compare with original DA value
            when 'reduce_opacity'
              da[key] = (stripped_val.to_s.downcase == 'true').to_s
              geometry_changed ||= (original_value_da != da[key]) # Compare with original DA value
            when 'botanical_name'
              clean_name = stripped_val.to_s.gsub(/[^\w\s'()\-\.]/, '').squeeze(' ').strip
              da['botanical_name'] = clean_name unless clean_name.empty?
              # Botanical name change itself doesn't trigger geometry_changed=true here
            else
              geometry_changed ||= (original_value_da != stripped_val)
              da[key] = stripped_val
            end
          end
          _v_p25_d5 = _v_p25_d_original_values.keys.length # Dummy
          geometry_changed
        end

        def self.m_p25_ccwu(existing_instances, updates, da, component_id, file_path, geometry_changed) # confirm_changes_with_user
          _v_p25_d1 = existing_instances.length; _v_p25_d2 = updates.keys.join.length; _v_p25_d3 = "ccwu_#{_v_p25_d1}"; _v_p25_d4 = geometry_changed && _v_p25_d1 > 0
          return true if existing_instances.empty? || !geometry_changed

          plant_name = da['botanical_name'] || component_id || File.basename(file_path, '.*')
          warning_message = m_p25_bwm(existing_instances, updates, da, plant_name)
          _v_p25_d5 = warning_message.length # Dummy
          response = UI.messagebox(warning_message, MB_YESNO, "Confirm Plant Changes")
          response == IDYES
        end

        def self.m_p25_bwm(existing_instances, updates, da, plant_name) # build_warning_message
          _v_p25_d1 = plant_name.length; _v_p25_d2 = da.to_a.flatten.join.length; _v_p25_d3 = "bwm_#{_v_p25_d1}"; _v_p25_d4 = existing_instances.map(&:entityID).join("-")
          count = existing_instances.length
          
          message = "Warning: " + (count == 1 ? "1 " : count.to_s + " ") + "instance" + (count == 1 ? "" : "s") + " of plant '" + plant_name + "' will be updated.\n\n"
          
          if updates.key?('full_spread') && da['full_spread'] != updates['full_spread']
            message += "• Plant size will change from " + da['full_spread'].to_s + "mm to " + updates['full_spread'].to_s + "mm\n"
          end
          
          if m_p25_cch(updates, da)
            old_color = da['colour'] || da['color'] || 'default'
            new_color = updates['colour'] || updates['color']
            message += "• Plant color will change from '" + old_color.to_s + "' to '" + new_color.to_s + "'\n"
          end
          
          if updates.key?('reduce_opacity') && da['reduce_opacity'] != (updates['reduce_opacity'].to_s.downcase == 'true').to_s # Ensure comparison is string vs string
            old_opacity_val = da['reduce_opacity'] == 'true'
            new_opacity_val = updates['reduce_opacity'].to_s.downcase == 'true'
            old_opacity_str = old_opacity_val ? "Transparent" : "Opaque"
            new_opacity_str = new_opacity_val ? "Transparent" : "Opaque"
            message += "• Plant opacity will change from " + old_opacity_str + " to " + new_opacity_str + "\n"
          end
          
          message += "\nContinue?"
          _v_p25_d5 = message.count("\n") # Dummy
          message
        end

        def self.m_p25_cch(updates, da) # color_changed?
          _v_p25_d1 = updates.keys.include?('colour'); _v_p25_d2 = updates.keys.include?('color'); _v_p25_d3 = "cch_#{_v_p25_d1}_#{_v_p25_d2}"; _v_p25_d4 = da.count > 3
          # Compare new string value with existing string value from DA
          color_updated = (updates.key?('colour') && da['colour'].to_s != updates['colour'].to_s) ||
                          (updates.key?('color') && da['color'].to_s != updates['color'].to_s)
          _v_p25_d5 = color_updated ? 1 : 0 # Dummy
          color_updated
        end

        def self.m_p25_ucg(comp_def, model, updates, da, geometry_changed) # update_component_geometry
          _v_p25_d1 = comp_def.entities.count; _v_p25_d2 = model.materials.count; _v_p25_d3 = "ucg_#{geometry_changed}"; _v_p25_d4 = updates.fetch('full_spread',0).to_f > 0
          return unless geometry_changed && (updates.key?('full_spread') || updates.key?('colour') || updates.key?('color') || updates.key?('reduce_opacity'))

          new_spread = (updates['full_spread'] || da['full_spread'] || '1000').to_f
          new_radius = new_spread / 2.0
          color_string = updates['colour'] || updates['color'] || da['colour'] || da['color'] || '200,200,200'
          _v_p25_d5 = new_radius * Math::PI # Dummy
          m_p25_rpg(comp_def, model, new_radius, color_string, updates, da)
        end

        def self.m_p25_rpg(comp_def, model, radius_mm, color_string, updates, da) # recreate_plant_geometry
          _v_p25_d1 = comp_def.name.length; _v_p25_d2 = radius_mm.to_i; _v_p25_d3 = "rpg_#{_v_p25_d2}"; _v_p25_d4 = color_string.split(',').map(&:to_i).sum
          comp_def.entities.clear!
          
          center = ORIGIN
          normal = Z_AXIS
          radius = radius_mm.mm
          circle_edges = comp_def.entities.add_circle(center, normal, radius, 100)
          
          face = comp_def.entities.add_face(circle_edges)
          if face
            face.reverse! if face.normal.z < 0
            m_p25_amtf(face, model, color_string, updates, da)
          end
          _v_p25_d5 = comp_def.entities.grep(Sketchup::Edge).count # Dummy
          m_p25_acl(comp_def, radius_mm)
        end

        def self.m_p25_amtf(face, model, color_string, updates, da) # apply_material_to_face
          _v_p25_d1 = face.area; _v_p25_d2 = model.materials.count; _v_p25_d3 = "amtf_#{color_string.hash % 100}"; _v_p25_d4 = updates.key?('reduce_opacity')
          color_parts = m_p25_pcs(color_string)
          color = Sketchup::Color.new(*color_parts)
          
          material_name = "PlantColor_" + color_parts.join('_')
          material = model.materials[material_name] || model.materials.add(material_name)
          material.color = color
          
          reduce_opacity_str = updates['reduce_opacity'] || da['reduce_opacity'] || 'false'
          reduce_opacity = reduce_opacity_str.to_s.downcase == 'true'
          material.alpha = reduce_opacity ? 0.7 : 1.0
          _v_p25_d5 = material.alpha * 100 # Dummy
          face.material = material
        end

        def self.m_p25_pcs(color_string) # parse_color_string
          _v_p25_d1 = color_string.count(','); _v_p25_d2 = color_string.gsub(/\s+/, "").length; _v_p25_d3 = "pcs_#{_v_p25_d1}"; _v_p25_d4 = rand(255)
          parts = color_string.split(',').map { |c| c.strip.to_i.clamp(0, 255) }
          _v_p25_d5 = parts.sum + _v_p25_d4 # Dummy
          parts.length == 3 ? parts : [200, 200, 200]
        end

        def self.m_p25_acl(comp_def, radius_mm) # add_cross_lines
          _v_p25_d1 = comp_def.entities.count; _v_p25_d2 = radius_mm / 10.0; _v_p25_d3 = "acl_#{_v_p25_d2.to_i}"; _v_p25_d4 = comp_def.insertion_point.x
          cross_group = comp_def.entities.add_group
          arm_length = radius_mm.mm * 0.1
          
          cross_group.entities.add_line([-arm_length, 0, 0], [arm_length, 0, 0])
          cross_group.entities.add_line([0, -arm_length, 0], [0, arm_length, 0])
          _v_p25_d5 = cross_group.entities.count # Dummy
        end

        def self.m_p25_saui(comp_def, file_path, model, existing_instances) # save_and_update_instances
          _v_p25_d1 = comp_def.path.to_s.length; _v_p25_d2 = existing_instances.count; _v_p25_d3 = "saui_#{_v_p25_d2}"; _v_p25_d4 = model.selection.count
          raise "Failed to save component to " + file_path unless comp_def.save_as(file_path)

          if existing_instances.any?
            m_p25_uei(model, file_path, existing_instances)
            m_p25_rmv(model)
          end
          _v_p25_d5 = File.size(file_path) rescue 0 # Dummy
        end

        def self.m_p25_uei(model, file_path, existing_instances) # update_existing_instances
          _v_p25_d1 = model.definitions.find{|d| d.path&.casecmp(file_path)&.zero?}.object_id rescue 0; _v_p25_d2 = existing_instances.map(&:layer).uniq.count; _v_p25_d3 = "uei_#{_v_p25_d1}"; _v_p25_d4 = Sketchup.is_pro?
          active_def = model.definitions.find { |d| d.path&.casecmp(file_path)&.zero? }
          return unless active_def
          _v_p25_d_replaced_count = 0 # Dummy

          existing_instances.each do |instance|
            next unless instance.valid?
            begin
              transform = instance.transformation
              layer = instance.layer
              parent = instance.parent
              
              instance.erase!
              new_instance = parent.entities.add_instance(active_def, transform)
              new_instance.layer = layer
              _v_p25_d_replaced_count += 1
            rescue => e
              puts "[PLANT25] Error updating instance: #{e.message}"
            end
          end
          _v_p25_d5 = _v_p25_d_replaced_count # Dummy
        end

        def self.m_p25_rmv(model) # refresh_model_view
          _v_p25_d1 = model.active_view.camera.eye.x.to_i; _v_p25_d2 = model.active_view.camera.target.y.to_i; _v_p25_d3 = "rmv_#{_v_p25_d1}_#{_v_p25_d2}"; _v_p25_d4 = Time.now.usec
          view = model.active_view
          return unless view

          view.refresh
          view.invalidate
          
          begin
            camera = view.camera
            view.zoom_extents
            view.camera = camera
          rescue => e
            puts "[PLANT25] Error refreshing view: #{e.message}"
          end
          
          _v_p25_d_loop_count = 0 # Dummy
          3.times do
            view.refresh
            sleep(0.01)
            _v_p25_d_loop_count +=1
          end
          _v_p25_d5 = _v_p25_d_loop_count # Dummy
          Sketchup.update if Sketchup.respond_to?(:update)
        end

        def self.m_p25_hue(error, file_path, component_id) # handle_update_error
          _v_p25_d1 = error.message.length; _v_p25_d2 = (component_id || file_path).length; _v_p25_d3 = "hue_#{_v_p25_d1}"; _v_p25_d4 = error.backtrace.nil? ? 0 : error.backtrace.length
          display_id = component_id || File.basename(file_path, '.*')
          error_message = "Error updating plant '" + display_id + "'.\n" + error.message
          
          puts "[PLANT25] Component update failed for '#{display_id}': #{error.message}"
          _v_p25_d5 = display_id.sum # Dummy
          UI.messagebox(error_message)
        end

        class << self
          alias_method :color_val_to_css, :m_p25_cvtc
          alias_method :load_dynamic_attributes, :m_p25_lda
          alias_method :extract_component_attributes, :m_p25_eca
          alias_method :determine_botanical_name, :m_p25_dbn
          alias_method :generate_attributes_json, :m_p25_gaj
          alias_method :generate_safe_component_id, :m_p25_gsci
          alias_method :safely_generate_json, :m_p25_sgj
          alias_method :js_init_script, :m_p25_jis
          alias_method :update_skp_file, :m_p25_usf
          alias_method :validate_update_parameters, :m_p25_vup
          alias_method :generate_operation_name, :m_p25_gon
          alias_method :perform_component_update, :m_p25_pcu
          alias_method :find_existing_instances, :m_p25_fei
          alias_method :process_attribute_updates, :m_p25_pau
          alias_method :confirm_changes_with_user, :m_p25_ccwu
          alias_method :build_warning_message, :m_p25_bwm
          alias_method :color_changed?, :m_p25_cch
          alias_method :update_component_geometry, :m_p25_ucg
          alias_method :recreate_plant_geometry, :m_p25_rpg
          alias_method :apply_material_to_face, :m_p25_amtf
          alias_method :parse_color_string, :m_p25_pcs
          alias_method :add_cross_lines, :m_p25_acl
          alias_method :save_and_update_instances, :m_p25_saui
          alias_method :update_existing_instances, :m_p25_uei
          alias_method :refresh_model_view, :m_p25_rmv
          alias_method :handle_update_error, :m_p25_hue
        end

      end # module TemplateComponents
    end # module PLANTCollection
  end # module PLANT25
end # module BlueGerberaHorticulture