# frozen_string_literal: true
# PLANT25/ui/dialog_manager.rb - Manages the main PLANT25 HtmlDialog

require 'sketchup.rb'
require 'uri'
require 'json'

require_relative '../core/plant25.rb'
require_relative '../core/licensing.rb'
begin
  require_relative '../core/plant_cache_manager.rb'
rescue LoadError
  # CacheManager optional
end

module BlueGerberaHorticulture
  module PLANT25
    module DialogManager
      @dialog = nil

      class << self
        attr_reader :dialog

        def create_html_dialog
          if @dialog && @dialog.respond_to?(:visible?) && @dialog.visible?
            BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] Main dialog already visible. Bringing to front.")
            @dialog.bring_to_front
            return
          end

          if defined?(BlueGerberaHorticulture::PLANT25::LicenseEnforcement) &&
             BlueGerberaHorticulture::PLANT25::LicenseEnforcement.activation_in_progress
            BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] Activation in progress, skipping dialog creation")
            return
          end

          unless BlueGerberaHorticulture::PLANT25::Licensing.check_license_status
            BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] No license found - triggering activation before showing main dialog")
            if defined?(BlueGerberaHorticulture::PLANT25::LicenseEnforcement)
              BlueGerberaHorticulture::PLANT25::LicenseEnforcement.require_license("PLANT25")
            else
              BlueGerberaHorticulture::PLANT25::Licensing.activate_license_via_ui
            end
            return
          end

          BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] License valid - proceeding with main dialog creation.")

          if @dialog && @dialog.respond_to?(:set_html) && !@dialog.visible?
            BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] Dialog exists but not visible. Re-showing.")
          else
            BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] Creating new dialog instance.")
            begin
              @dialog = UI::HtmlDialog.new(
                dialog_title:    'PLANT25',
                preferences_key: 'PLANT25_MainDialog',
                scrollable:      false,
                width:           500,
                height:          700,
                resizable:       true,
                style:           UI::HtmlDialog::STYLE_DIALOG
              )
              setup_image_paths
              load_html_content
              setup_callbacks
            rescue StandardError => e
              log_message = "[DialogManager] Failed to create dialog: #{e.message}\n#{e.backtrace.join("\n")}"
              BlueGerberaHorticulture::PLANT25.error_log(log_message)
              UI.messagebox("Error creating PLANT25 dialog: #{e.message}")
              @dialog = nil
              return
            end
          end
          @dialog.show
          BlueGerberaHorticulture::PLANT25.debug_log("PLANT25 Dialog shown.")

          UI.start_timer(1.0, false) do
            if @dialog && @dialog.visible? && BlueGerberaHorticulture::PLANT25::Licensing.check_license_status
              BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] Fallback refresh - ensuring plant list and images are loaded")
              refresh_plant_list(false)
              update_image_paths_in_js
            end
          end
        end

        def refresh_dialog_after_license_activation
          BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] Refreshing dialog after license activation")
          if @dialog && @dialog.respond_to?(:execute_script) && @dialog.visible?
            refresh_plant_list(false)
            update_image_paths_in_js
            @dialog.execute_script("if(typeof window.showLicenseActivatedMessage === 'function') { window.showLicenseActivatedMessage(); }")
          else
            BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] Dialog not ready for post-activation refresh")
          end
        end

        def force_refresh_dialog
          BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] Force refreshing dialog content")
          if @dialog && @dialog.visible?
            BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] Dialog is visible, refreshing...")
            refresh_plant_list(false)
            update_image_paths_in_js
          else
            BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] Dialog not visible, cannot refresh")
          end
        end

        def refresh_plant_list(show_confirmation_alert = false)
          BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] refresh_plant_list called. Show alert: #{show_confirmation_alert}")

          unless @dialog && @dialog.respond_to?(:execute_script) && @dialog.visible?
            BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] Dialog not ready for plant list update - skipping")
            return
          end

          unless defined?(BlueGerberaHorticulture::PLANT25.get_plant_library_path)
            BlueGerberaHorticulture::PLANT25.error_log("[DialogManager] get_plant_library_path not available.")
            @dialog.execute_script("if(typeof window.updatePlantListDOM === 'function') { window.updatePlantListDOM([]); console.error('Could not get plant library path.'); }")
            return
          end

          # Ensure CacheManager is initialised so quick_load_data is present
          if defined?(BlueGerberaHorticulture::PLANT25::CacheManager) &&
             BlueGerberaHorticulture::PLANT25::CacheManager.respond_to?(:initialize)
            begin
              BlueGerberaHorticulture::PLANT25::CacheManager.initialize
            rescue => e
              BlueGerberaHorticulture::PLANT25.error_log("[DialogManager] CacheManager initialize error: #{e.message}")
            end
          end

          library_path = BlueGerberaHorticulture::PLANT25.get_plant_library_path
          begin
            plant_data_for_js = []
            if library_path && Dir.exist?(library_path)
              # Load favourites from cache (safe defaults)
              favourites_by_id = {}
              if defined?(BlueGerberaHorticulture::PLANT25::CacheManager)
                cache_data = BlueGerberaHorticulture::PLANT25::CacheManager.quick_load_data || {}
                favourites_by_id = cache_data["favourites_by_id"] || {}
              end

              plant_data_for_js = Dir.glob(File.join(library_path, '**', '*.skp')).map do |file_path|
                begin
                  display_name = File.basename(file_path, '.skp').tr('_', ' ').gsub(/\s+/, ' ').strip
                  parent_dir_name = File.basename(File.dirname(file_path))
                  category = if parent_dir_name.casecmp(File.basename(library_path)).zero?
                               "General"
                             else
                               parent_dir_name.tr('_', ' ').gsub(/\s+/, ' ').strip
                             end

                  plant_id = File.basename(file_path, '.skp')
                  is_favourite = favourites_by_id[plant_id] == true

                  {
                    id: plant_id,
                    file_path: file_path,
                    display_name: display_name.empty? ? "Unnamed Plant" : display_name,
                    category: category,
                    favourite: is_favourite
                  }
                rescue StandardError => e
                  BlueGerberaHorticulture::PLANT25.error_log("[DialogManager] Error processing file '#{file_path}': #{e.message}")
                  nil
                end
              end.compact

              # Favourites first, then A–Z within groups
              plant_data_for_js.sort_by! { |plant| [plant[:favourite] ? 0 : 1, plant[:display_name].to_s.downcase] }
            else
              BlueGerberaHorticulture::PLANT25.error_log("[DialogManager] Plant library path not found: #{library_path.inspect}")
            end

            json_data = plant_data_for_js.to_json
            script_update = "if(typeof window.updatePlantListDOM === 'function') { window.updatePlantListDOM(#{json_data}); } else { console.warn('updatePlantListDOM function not found.'); }"

            if @dialog && @dialog.respond_to?(:execute_script) && @dialog.visible?
              BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] Updating plant list. Plants: #{plant_data_for_js.size}")
              @dialog.execute_script(script_update)
              @dialog.execute_script("if(typeof window.filterItems === 'function'){ window.filterItems(); }")
              @dialog.execute_script("if(typeof window.showRefreshConfirmation === 'function') && #{show_confirmation_alert} { window.showRefreshConfirmation(); }")
            else
              BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] Dialog not ready for plant list update.")
            end
          rescue StandardError => e
            BlueGerberaHorticulture::PLANT25.error_log("[DialogManager] refreshPlantList error: #{e.message}\n#{e.backtrace.join("\n")}")
            if @dialog&.visible? && @dialog.respond_to?(:execute_script)
              @dialog.execute_script("if(typeof window.updatePlantListDOM === 'function') { window.updatePlantListDOM([]); console.error('Error refreshing plant list.'); }")
            end
          end
        end

        private

        def setup_image_paths
          unless defined?(BlueGerberaHorticulture::PLANT25::PLUGIN_DIR)
            BlueGerberaHorticulture::PLANT25.error_log("[DialogManager] PLUGIN_DIR undefined.")
            @images_dir = "error_plugin_dir_undefined"
            @image_paths = {}
            return
          end
          @images_dir = File.join(BlueGerberaHorticulture::PLANT25::PLUGIN_DIR, 'resources', 'images')
          @image_paths = {
            margin: 'margin.png', logo: 'logo_main.png', profile: 'profile.png', help: 'help.png',
            mini: 'mini.png', plant_place: 'plant_place.png', plant_path: 'plant_path.png',
            plant_array: 'plant_array.png', plant_create: 'plant_create.png',
            collection: 'collection.png', plant_report: 'plant_report.png', footer: 'plant_footer.png'
          }
        end

        def get_image_url(filename)
          return "error_images_dir_not_set" if @images_dir == "error_plugin_dir_undefined" || @images_dir.nil?
          path = File.join(@images_dir, filename)
          return "error_file_not_found_#{filename.gsub(/\W/, '_')}" unless File.exist?(path)
          "file:///#{URI::DEFAULT_PARSER.escape(path.tr('\\', '/')).gsub('+', '%20')}"
        end

        def load_html_content
          unless defined?(BlueGerberaHorticulture::PLANT25::PLUGIN_DIR)
            msg = "FATAL: PLUGIN_DIR not defined. Cannot locate dialog HTML."
            BlueGerberaHorticulture::PLANT25.error_log(msg)
            UI.messagebox(msg)
            raise NameError, msg
          end
          html_path = File.join(BlueGerberaHorticulture::PLANT25::PLUGIN_DIR, 'resources', 'html', 'index.html')
          unless File.exist?(html_path)
            msg = "FATAL: Dialog HTML template not found: #{html_path}"
            BlueGerberaHorticulture::PLANT25.error_log(msg)
            UI.messagebox(msg)
            raise IOError, msg
          end
          @dialog.set_file(html_path)
        end

        def update_image_paths_in_js
          BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] update_image_paths_in_js called")

          return if @image_paths.nil? || @image_paths.empty?
          unless @dialog && @dialog.respond_to?(:execute_script) && @dialog.visible?
            BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] Dialog not ready for image update - skipping")
            return
          end

          begin
            urls_to_pass = @image_paths.transform_values { |filename| get_image_url(filename) }
            image_urls_json = urls_to_pass.to_json
            safe_json = image_urls_json.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')

            js_code = <<~JS
              (function() {
                try {
                  window.PLANT25 = window.PLANT25 || {};
                  window.PLANT25.imageUrls = #{safe_json};
                  var imageUrls = window.PLANT25.imageUrls || {};
                  document.querySelectorAll('img[data-image-key]').forEach(function(img) {
                    var key = img.getAttribute('data-image-key');
                    if (imageUrls[key] && typeof imageUrls[key] === 'string' && !imageUrls[key].startsWith('error_')) {
                      img.src = imageUrls[key];
                      img.classList.add('image-loaded');
                    }
                  });
                } catch (e) {
                  var jsCatchErrorMsg = 'Error updating image paths: ' + e.name + ': ' + e.message + "\\nStack: " + e.stack;
                  if (typeof sketchup !== 'undefined' && sketchup.consoleError) { sketchup.consoleError(jsCatchErrorMsg); }
                  else { console.error(jsCatchErrorMsg); }
                }
              })();
            JS

            BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] Executing image update JS.")
            @dialog.execute_script(js_code)
          rescue StandardError => e
            BlueGerberaHorticulture::PLANT25.error_log("[DialogManager] update_image_paths_in_js error: #{e.message}\n#{e.backtrace.join("\n")}")
          end
        end

        def setup_callbacks
          @dialog.add_action_callback("js_dialog_is_ready") do |_ctx|
            BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] Dialog ready callback received.")
            if BlueGerberaHorticulture::PLANT25::Licensing.check_license_status
              BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] License valid - refreshing plant list and images")
              UI.start_timer(0.5, false) do
                refresh_plant_list(false)
                update_image_paths_in_js
              end
            else
              BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] No license found in dialog ready callback")
            end
          end

          define_tool_activation_callback = lambda { |tool_name_pascal_case, sketchup_module_name_sym|
            callback_js_name = "open#{tool_name_pascal_case}"
            @dialog.add_action_callback(callback_js_name) do |_ctx, plant_file_path|
              BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] '#{callback_js_name}' called.")

              unless BlueGerberaHorticulture::PLANT25::Licensing.check_license_status
                BlueGerberaHorticulture::PLANT25.error_log("[DialogManager] License check failed for tool: #{tool_name_pascal_case}.")
                BlueGerberaHorticulture::PLANT25.set_active_tool(nil)
                next
              end

              if plant_file_path.nil? || plant_file_path.empty?
                UI.messagebox("No plant selected for the #{tool_name_pascal_case} tool. Please select a plant from the list.")
                BlueGerberaHorticulture::PLANT25.set_active_tool(nil)
                next
              end

              unless File.exist?(plant_file_path)
                UI.messagebox("Plant file for #{tool_name_pascal_case} not found: #{File.basename(plant_file_path)}")
                BlueGerberaHorticulture::PLANT25.error_log("[DialogManager] File not found: #{plant_file_path}")
                BlueGerberaHorticulture::PLANT25.set_active_tool(nil)
                refresh_plant_list(false)
                next
              end

              active_model = Sketchup.active_model
              definition = nil
              begin
                definition = active_model.definitions.load(plant_file_path)
              rescue ArgumentError => e
                UI.messagebox("Error loading plant for #{tool_name_pascal_case}: '#{File.basename(plant_file_path)}'. Invalid/corrupted.\nDetails: #{e.message}")
                BlueGerberaHorticulture::PLANT25.error_log("[DialogManager] ArgumentError loading SKP: #{e.message}")
                BlueGerberaHorticulture::PLANT25.set_active_tool(nil)
                next
              rescue StandardError => e
                UI.messagebox("Error loading plant for #{tool_name_pascal_case}: #{e.message}")
                BlueGerberaHorticulture::PLANT25.error_log("[DialogManager] Error loading SKP: #{e.message}")
                BlueGerberaHorticulture::PLANT25.set_active_tool(nil)
                next
              end

              unless definition&.is_a?(Sketchup::ComponentDefinition) && !definition.group? && !definition.image?
                UI.messagebox("Invalid component type for #{tool_name_pascal_case}. Select a plant component, not a group or image.")
                BlueGerberaHorticulture::PLANT25.set_active_tool(nil)
                next
              end

              module_const = BlueGerberaHorticulture::PLANT25.const_get(sketchup_module_name_sym) rescue nil
              if module_const && module_const.respond_to?(:activate_tool_with_definition)
                module_const.activate_tool_with_definition(definition)
              else
                UI.messagebox("#{tool_name_pascal_case} tool module unavailable.")
                BlueGerberaHorticulture::PLANT25.error_log("[DialogManager] #{sketchup_module_name_sym} module or method missing.")
                BlueGerberaHorticulture::PLANT25.set_active_tool(nil)
              end
            end
          }

          define_tool_activation_callback.call('PlantPlace', :PLANTPlace)
          define_tool_activation_callback.call('PlantPath', :PLANTPath)
          define_tool_activation_callback.call('PlantArray', :PLANTArray)

          dialog_tool_mappings = {
            'PlantCreate' => { module: :PLANTCreate, method: :run },
            'PlantCollection' => { module: :PLANTCollection, method: :show },
            'PlantReport' => { module: :PLANTReport, method: :run }
          }

          dialog_tool_mappings.each do |dialog_tool_name, config|
            @dialog.add_action_callback("open#{dialog_tool_name}") do |_ctx|
              unless BlueGerberaHorticulture::PLANT25::Licensing.check_license_status
                BlueGerberaHorticulture::PLANT25.error_log("[DialogManager] License check failed for open#{dialog_tool_name}.")
                BlueGerberaHorticulture::PLANT25.set_active_tool(nil)
                next
              end
              BlueGerberaHorticulture::PLANT25.set_active_tool(nil)

              module_sym = config[:module]
              method_to_call = config[:method]

              begin
                module_const = BlueGerberaHorticulture::PLANT25.const_get(module_sym)
                if module_const && module_const.respond_to?(method_to_call)
                  module_const.send(method_to_call)
                else
                  UI.messagebox("#{dialog_tool_name} module method '#{method_to_call}' not available.")
                  BlueGerberaHorticulture::PLANT25.error_log("[DialogManager] #{module_sym} method #{method_to_call} missing.")
                end
              rescue NameError => e
                UI.messagebox("#{dialog_tool_name} module not available.")
                BlueGerberaHorticulture::PLANT25.error_log("[DialogManager] #{module_sym} module not found: #{e.message}")
              rescue StandardError => e
                UI.messagebox("Error opening #{dialog_tool_name}: #{e.message}")
                BlueGerberaHorticulture::PLANT25.error_log("[DialogManager] Error opening #{dialog_tool_name}: #{e.message}")
              end
            end
          end

          @dialog.add_action_callback("openHelp") do |_ctx|
            BlueGerberaHorticulture::PLANT25.set_active_tool(nil)
            UI.openURL("https://plant25.com/help-centre")
          end

          @dialog.add_action_callback("openProfile") do |_ctx|
            BlueGerberaHorticulture::PLANT25.set_active_tool(nil)

            stored_license_details = BlueGerberaHorticulture::PLANT25::Licensing.load_stored_license_info

            if stored_license_details[:key] && !stored_license_details[:key].empty?
              status_message = BlueGerberaHorticulture::PLANT25::Licensing.build_license_status_message(stored_license_details)
              prompt = "#{status_message}\n\nWould you like to try re-validating your license online now?"
              title = "PLANT25 License Profile"
              choice = UI.messagebox(prompt, MB_YESNO, title)

              if choice == IDYES
                BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager Profile] User chose to re-validate.")
                BlueGerberaHorticulture::PLANT25::Licensing.m_p25_polv(stored_license_details[:key])
                updated_details = BlueGerberaHorticulture::PLANT25::Licensing.load_stored_license_info
                updated_status_message = BlueGerberaHorticulture::PLANT25::Licensing.build_license_status_message(updated_details)
                UI.messagebox(updated_status_message, MB_OK, "PLANT25 License Profile - Updated")
              else
                BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager Profile] User chose not to re-validate.")
              end
            else
              BlueGerberaHorticulture::PLANT25.error_log("[DialogManager Profile] No license key found. Prompting activation.")
              UI.messagebox("No active PLANT25 license found. Please activate your license.", MB_OK, "PLANT25 License Required")
              BlueGerberaHorticulture::PLANT25::Licensing.activate_license_via_ui
            end
          rescue StandardError => e
            BlueGerberaHorticulture::PLANT25.error_log("[DialogManager Profile] Error displaying license details: #{e.message}\n#{e.backtrace.join("\n")}")
            UI.messagebox("An error occurred while retrieving your PLANT25 license details. Please try again or contact support if the issue persists.", MB_OK, "Profile Error")
          end

          @dialog.add_action_callback("openMiniToolbar") do |_ctx|
            BlueGerberaHorticulture::PLANT25.set_active_tool(nil)
            if defined?(BlueGerberaHorticulture::PLANT25::ToolbarManager) && BlueGerberaHorticulture::PLANT25::ToolbarManager.respond_to?(:open_mini_panel)
              BlueGerberaHorticulture::PLANT25::ToolbarManager.open_mini_panel
            else
              UI.messagebox("Mini Toolbar is not available.")
            end
          end

          @dialog.add_action_callback("refreshPlantList") do |_ctx|
            if BlueGerberaHorticulture::PLANT25::Licensing.check_license_status
              if defined?(BlueGerberaHorticulture::PLANT25::PlantAPIManager)
                BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] Checking for plant updates from server...")
                Thread.new do
                  begin
                    updates_available = BlueGerberaHorticulture::PLANT25::PlantAPIManager.check_for_updates
                    UI.start_timer(0, false) { refresh_plant_list(true) }
                  rescue => e
                    BlueGerberaHorticulture::PLANT25.error_log("[DialogManager] Error during API sync: #{e.message}")
                    UI.start_timer(0, false) { refresh_plant_list(true) }
                  end
                end
              else
                BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] PlantAPIManager not available, refreshing with local plants only")
                refresh_plant_list(true)
              end
            else
              BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] License check failed on refreshPlantList action.")
            end
          end

          # Toggle favourite callback (persist + refresh)
          @dialog.add_action_callback("toggleFavourite") do |_ctx, plant_id|
            BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] toggleFavourite called for plant_id: #{plant_id}")

            unless defined?(BlueGerberaHorticulture::PLANT25::CacheManager)
              BlueGerberaHorticulture::PLANT25.error_log("[DialogManager] CacheManager not available for favourites")
              next
            end

            begin
              # Ensure cache manager is initialised
              if BlueGerberaHorticulture::PLANT25::CacheManager.respond_to?(:initialize)
                BlueGerberaHorticulture::PLANT25::CacheManager.initialize
              end

              cache_data = BlueGerberaHorticulture::PLANT25::CacheManager.quick_load_data || {}
              favourites_by_id = cache_data["favourites_by_id"] || {}

              current_status = favourites_by_id[plant_id] == true
              new_status = !current_status

              if new_status
                favourites_by_id[plant_id] = true
              else
                favourites_by_id.delete(plant_id)
              end

              cache_data["favourites_by_id"] = favourites_by_id
              BlueGerberaHorticulture::PLANT25::CacheManager.instance_variable_set(:@quick_load_data, cache_data)

              # Save using non-public method via send (ensures persistence)
              if BlueGerberaHorticulture::PLANT25::CacheManager.respond_to?(:save_quick_data, true)
                BlueGerberaHorticulture::PLANT25::CacheManager.send(:save_quick_data)
              end

              BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] Favourite toggled for #{plant_id}: #{new_status}")

              # Refresh to regroup and re-sort
              refresh_plant_list(false)
            rescue StandardError => e
              BlueGerberaHorticulture::PLANT25.error_log("[DialogManager] Error toggling favourite for #{plant_id}: #{e.message}")
            end
          end

          @dialog.add_action_callback("consoleLog") do |_ctx, msg|
            BlueGerberaHorticulture::PLANT25.debug_log("[JS Dialog LOG] #{msg}")
          end
          @dialog.add_action_callback("consoleError") do |_ctx, msg|
            BlueGerberaHorticulture::PLANT25.error_log("[JS Dialog ERROR] #{msg}")
          end

          @dialog.set_on_closed do
            BlueGerberaHorticulture::PLANT25.debug_log("[DialogManager] Dialog was closed.")
            BlueGerberaHorticulture::PLANT25.set_active_tool(nil)
            @dialog = nil
          end
        end
      end
    end
  end
end
