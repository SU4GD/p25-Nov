# PLANT25/ui/toolbar_manager.rb

require 'sketchup.rb'
require 'uri'
require 'json'

require_relative '../core/plant25.rb'
require_relative '../core/licensing.rb' 
require_relative 'dialog_manager.rb'
require_relative '../PLANTCollection/plant_collection.rb' 

module BlueGerberaHorticulture
  module PLANT25
    module ToolbarManager
      extend self

      def self._p25_sd(encoded_str)
        BlueGerberaHorticulture::PLANT25._p25_sd(encoded_str)
      end

      @current_plant_id = nil
      @toolbar = nil
      @mini_dialog = nil

      attr_reader :toolbar, :mini_dialog

      def icon_path_fs(filename)
        base_plugin_dir = File.expand_path(File.join(__dir__, '..')) 

        primary_path = File.join(base_plugin_dir, 'resources', 'images', filename)
        return primary_path.tr('\\', '/') if File.exist?(primary_path)

        fallback_path1 = File.join(base_plugin_dir, 'assets', 'images', filename)
        return fallback_path1.tr('\\', '/') if File.exist?(fallback_path1)

        fallback_path2 = File.join(base_plugin_dir, 'assets', filename)
        return fallback_path2.tr('\\', '/') if File.exist?(fallback_path2)

        default_path_for_log = primary_path.tr('\\', '/') 
        log_message = _p25_sd("Om4qFF09FD9vLBhYPhxaDDwvAFcqAVYmJ3h7FCNZcRZRAStCD1Y/RlU7DzZWTWw=") + filename + _p25_sd("TxkYA1ImGTBXE2xUPh1VAiBCEVg/DkB6WhxXES1CPQRRAylCFVZxRg==") + default_path_for_log
        puts log_message 
        BlueGerberaHorticulture::PLANT25.error_log(log_message) if BlueGerberaHorticulture::PLANT25.respond_to?(:error_log)
        default_path_for_log 
      end
      private :icon_path_fs

      def open_main_dialog
        unless defined?(BlueGerberaHorticulture::PLANT25::DialogManager)
          UI.messagebox("Error: DialogManager module not loaded. Please restart SketchUp.")
          return
        end

        BlueGerberaHorticulture::PLANT25::DialogManager.create_html_dialog

        if @mini_dialog && @mini_dialog.respond_to?(:visible?) && @mini_dialog.visible?
          @mini_dialog.close
        end
      end

      def create_toolbar
        return @toolbar if @toolbar&.valid? 

        begin
          @toolbar = UI::Toolbar.new('PLANT25')
          cmd_open = UI::Command.new('PLANT25') { open_main_dialog }
          cmd_open.tooltip = "Open PLANT25"
          
          small_icon_path = icon_path_fs('toolbar.png') 
          large_icon_path = icon_path_fs('toolbar.png') 

          cmd_open.small_icon = small_icon_path if File.exist?(small_icon_path)
          cmd_open.large_icon = large_icon_path if File.exist?(large_icon_path)

          unless File.exist?(small_icon_path) 
            puts _p25_sd("Om4qFF09FD9vLBhYPhxaDDwvAFcqAVYmJ3hmGCNbMxFKTScBDldjFRp0FDdGVypYJB5cQ24xDFgnChM9GTdcVzxWJRgCTQ==") + small_icon_path
          end

          @toolbar.add_item(cmd_open)
          @toolbar.restore 
        rescue StandardError => e
          log_message = _p25_sd("OnwZNHwGJwNmGCNbMxFKIC8MAF4uFG50OSpXFjhScQRXAiIAAEtrAFI9Fj1WTWw=") + e.message + _p25_sd("PVc=") + e.backtrace.join(_p25_sd("PVc="))
          BlueGerberaHorticulture::PLANT25.error_log(log_message) if BlueGerberaHorticulture::PLANT25.respond_to?(:error_log)
          puts log_message 
          @toolbar = nil 
        end
        @toolbar 
      end

      def update_mini_panel_content
        unless @mini_dialog && @mini_dialog.respond_to?(:visible?) && @mini_dialog.visible?
          if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
            puts _p25_sd("On0uBEYzJwNmGCNbMxFKIC8MAF4uFG50DyhWFjhSDh1RAyc9EVglA18LGTdcAylZJVBLBicSEVwvXBMwEzleGCsXPx9MTTwHAF0yRlwmWjFcAS1bOBQW")
          end
          return
        end
        if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
          puts _p25_sd("On0uBEYzJwNmGCNbMxFKIC8MAF4uFG50DyhWFjhSDh1RAyc9EVglA18LGTdcAylZJVBdFSsBFE0iCFR6VHY=")
        end
        component_folder = BlueGerberaHorticulture::PLANT25.get_plant_library_path
        plant_data_list = []
        begin
          if component_folder && Dir.exist?(component_folder)
            skp_files = Dir.glob(File.join(component_folder, '**', '*.skp'))
            if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
              puts _p25_sd("On0uBEYzJwNmGCNbMxFKIC8MAF4uFG50PDdHGSgX") + skp_files.length.to_s + _p25_sd("QWoANhMyEzRXBGxRPgIYACcMCBk7B10xFnY=")
            end
            plant_data_list = skp_files.map do |file_path|
              display_name = File.basename(file_path, '.skp').tr('_', ' ').gsub(/\s+/, ' ').strip
              botanical_name_for_list = display_name.empty? ? File.basename(file_path, '.skp') : display_name
              botanical_name_for_list = "Unnamed Plant" if botanical_name_for_list.empty?
              { id: file_path, botanical_name: botanical_name_for_list }
            rescue StandardError => e
              error_msg = _p25_sd("Om0kCV82Gyp/FiJWNhVKMG4nE0skFBMkCDdREj9EOB5fTSgLDVxrFlIgEngV") + file_path + _p25_sd("RhktCUF0FzFcHmxHMB5dAW4OCEo/XBM=") + e.message
              BlueGerberaHorticulture::PLANT25.error_log(error_msg) if BlueGerberaHorticulture::PLANT25.respond_to?(:error_log)
              puts error_msg if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
              nil
            end.compact 
            plant_data_list.sort_by! { |plant| plant[:botanical_name].to_s.downcase }
            if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG && !plant_data_list.empty?
              puts _p25_sd("On0uBEYzJwNmGCNbMxFKIC8MAF4uFG50NzFcHmxHMB5dAW4SDVglEmwwGyxTKCBeIgQYRSgLE0o/RgZ9QHg=") + plant_data_list.take(5).inspect
            end
          else
            log_msg = _p25_sd("Onw5FFwmJwNmGCNbMxFKIC8MAF4uFG50KjRTGTgXPRlaHy8QGBktCV8wHyoSGiVEIhlWCm4EDktrC1o6E3hCFiJSPUoY") + component_folder.inspect
            BlueGerberaHorticulture::PLANT25.error_log(log_msg) if BlueGerberaHorticulture::PLANT25.respond_to?(:error_log)
            puts log_msg if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
          end
        rescue StandardError => e
          log_msg = _p25_sd("OnwZNHwGJwNmGCNbMxFKIC8MAF4uFG50PypAGD4XIhNZAyALD15rClo2CDlADmxRPgIYACcMCBk7B10xFmIS") + e.message
          BlueGerberaHorticulture::PLANT25.error_log(log_msg) if BlueGerberaHorticulture::PLANT25.respond_to?(:error_log)
          puts log_msg if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
        end

        valid_ids = plant_data_list.map { |p| p[:id] }
        unless @current_plant_id && valid_ids.include?(@current_plant_id)
          @current_plant_id = nil
        end
        @current_plant_id = nil if plant_data_list.empty?

        plants_json = plant_data_list.to_json
        current_id_json = @current_plant_id ? @current_plant_id.to_json : 'null' 

        if @mini_dialog && @mini_dialog.respond_to?(:execute_script)
          script = "if(typeof populateMiniPanelDropdown === 'function') { populateMiniPanelDropdown(#{plants_json}, #{current_id_json}); } else { console.error('JS MiniPanel: populateMiniPanelDropdown function not found.'); }"
          @mini_dialog.execute_script(script)
          if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
            puts _p25_sd("On0uBEYzJwNmGCNbMxFKIC8MAF4uFG50NzFcHmxHMB5dAW4XEV0qElZ0CTtAHjxDcRVACC0XFVwvSBMXDypAEiJDcTl8TT0HD01rElx0MAsIVw==") + current_id_json
          end
        end
      end

      def refresh_mini_panel_list
        UI.start_timer(0.1, false) { update_mini_panel_content }
      end

      def notify_mini_panel_tool_changed(tool_key_name)
        if @mini_dialog && @mini_dialog.respond_to?(:visible?) && @mini_dialog.visible? && @mini_dialog.respond_to?(:execute_script)
          js_tool_key_name = tool_key_name ? "'#{tool_key_name.gsub('\\', '\\\\').gsub("'", "\\'")}'" : 'null'
          script = "if(typeof setActiveMiniButton === 'function') { setActiveMiniButton(#{js_tool_key_name}); } else { console.warn('JS MiniPanel: setActiveMiniButton function not found.'); }"
          @mini_dialog.execute_script(script)
          if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
            puts _p25_sd("On0uBEYzJwNmGCNbMxFKIC8MAF4uFG50NDdGHipeNBQYACcMCGY7B10xFnhdEWxDPh9UTS0KAFcsAwl0") + (tool_key_name || 'none')
          end
        elsif defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
          puts _p25_sd("On0uBEYzJwNmGCNbMxFKIC8MAF4uFG50FDdGHipODh1RAyc9EVglA18LDjddGxNUORFWCisGWxkGD109WjxbFiBYNlBWAjpCE1wqAkp0FSoSASVEOBJUCGA=")
        end
      end

      def _p25_sd(encoded_str)
        BlueGerberaHorticulture::PLANT25._p25_sd(encoded_str)
      end

      def open_mini_panel
        unless defined?(BlueGerberaHorticulture::PLANT25::DialogManager)
          UI.messagebox("DialogManager not loaded. Please check if all extension files are present.")
          return
        end

        if BlueGerberaHorticulture::PLANT25::DialogManager.respond_to?(:dialog) &&
           BlueGerberaHorticulture::PLANT25::DialogManager.dialog &&
           BlueGerberaHorticulture::PLANT25::DialogManager.dialog.respond_to?(:visible?) &&
           BlueGerberaHorticulture::PLANT25::DialogManager.dialog.visible?
          BlueGerberaHorticulture::PLANT25::DialogManager.dialog.close
        end

        component_folder = BlueGerberaHorticulture::PLANT25.get_plant_library_path
        unless component_folder && Dir.exist?(component_folder)
          UI.messagebox("Plant library path not found. Please check your installation.")
          return
        end

        if @mini_dialog && @mini_dialog.respond_to?(:visible?) && @mini_dialog.visible?
          @mini_dialog.bring_to_front
          return
        end

        create_file_uri = lambda do |icon_filename|
          path = icon_path_fs(icon_filename) 
          return '' if path.nil? || path.empty? || path.start_with?("error_") || !File.exist?(path)
          "file:///#{URI::DEFAULT_PARSER.escape(path).gsub('+', '%20')}"
        end

        icon_uris = {
          place: create_file_uri.call('plant_place.png'),
          path: create_file_uri.call('plant_path.png'),
          array: create_file_uri.call('plant_array.png'),
          create: create_file_uri.call('plant_create.png'),
          report: create_file_uri.call('plant_report.png'),
          library: create_file_uri.call('collection.png'),
          mini: create_file_uri.call('toolbar.png'), 
          close: create_file_uri.call('close.png')
        }

        mini_panel_css = <<~CSS
          *, *::before, *::after { box-sizing: border-box; }
          html, body { background: transparent; margin: 0; padding: 0; overflow: hidden; font-family: sans-serif; font-size: 13px; color: #333; }
          body { display: flex; align-items: center; height: 100%; padding: 0 4px; } 
          .plant-list {
            border: 1px solid rgba(0,0,0,0.15); 
            border-radius: 4px;
            padding: 0; 
            margin: 0 4px 0 0; 
            background: rgba(255,255,255,0.8); 
            flex-shrink: 0; 
            display: flex; 
            align-items: center; 
          }
          select#plantSelect {
            border: none; 
            background: transparent; 
            font-size: 13px;
            max-width: 320px; 
            width: 320px; 
            cursor: pointer;
            padding: 6px 4px; 
            height: 25px; 
            line-height: 28px; 
          }
          select#plantSelect:focus {
            outline: 2px solid Highlight; 
            outline-offset: -1px; 
          }
          img.action-icon {
            width: 30px;  
            height: 30px; 
            padding: 2px; 
            object-fit: contain; 
            vertical-align: middle; 
            cursor: pointer;
            border-radius: 4px; 
            margin: 0 1px; 
            transition: transform 0.3s ease, box-shadow 0.3s ease, background-color 0.15s ease;
            border: 1.5px solid transparent; 
          }
          img.action-icon:hover {
            transform: translateY(-2px); 
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2); 
            background-color: rgba(0,0,0,0.03); 
          }
          img.action-icon:focus-visible { 
            outline: 1.5px solid #BFBFBF; 
            outline-offset: 1px;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
            background-color: rgba(0,0,0,0.03);
          }
          img.action-icon.active { 
            border: 1.5px solid #274246; 
            box-shadow: 0 0 5px rgba(39, 66, 70, 0.4); 
            background-color: rgba(39, 66, 70, 0.1); 
          }
           img.action-icon.active:focus-visible { 
             outline: 1.5px solid #274246; 
             outline-offset: 1px;
          }
        CSS

        mini_panel_js = <<~JS
          function populateMiniPanelDropdown(plantsArray, currentId) {
            const selectElement = document.getElementById('plantSelect');
            if (!selectElement) {
              console.error('Mini panel: plantSelect element not found');
              return;
            }
            selectElement.innerHTML = ''; 

            if (!plantsArray || plantsArray.length === 0) {
              const option = document.createElement('option');
              option.value = '';
              option.textContent = 'Choose Plant...'; 
              selectElement.appendChild(option);
              selectElement.disabled = true;
              if (typeof sketchup.selectPlant === 'function') {
                sketchup.selectPlant(''); 
              }
            } else {
              selectElement.disabled = false;
              let newSelectedValueToSetInJs = null; 
              let anOptionWasExplicitlySelected = false;

              let shouldAddChooseOption = true; 
              
              if (shouldAddChooseOption) {
                  const chooseOption = document.createElement('option');
                  chooseOption.value = ''; 
                  chooseOption.textContent = 'Choose Plant...';
                  selectElement.appendChild(chooseOption);
                  if (currentId === null) {
                      newSelectedValueToSetInJs = '';
                      anOptionWasExplicitlySelected = true;
                  }
              }

              plantsArray.forEach(plant => {
                const option = document.createElement('option');
                option.value = String(plant.id); 
                option.textContent = plant.botanical_name || 'Unnamed Plant';
                selectElement.appendChild(option);

                if (String(plant.id) === String(currentId)) {
                  newSelectedValueToSetInJs = String(plant.id);
                  anOptionWasExplicitlySelected = true;
                }
              });

              if (newSelectedValueToSetInJs !== null) {
                selectElement.value = newSelectedValueToSetInJs;
              } else if (selectElement.options.length > 0 && selectElement.options[0].value === '') {
                selectElement.value = '';
                newSelectedValueToSetInJs = '';
              } else if (selectElement.options.length > 0) {
                selectElement.value = selectElement.options[0].value;
                newSelectedValueToSetInJs = selectElement.options[0].value;
              }

              if (typeof sketchup.selectPlant === 'function') {
                sketchup.selectPlant(newSelectedValueToSetInJs === null ? '' : String(newSelectedValueToSetInJs));
              }
            }
          }

          function setActiveMiniButton(toolKey) {
            const toolButtonIds = { 
              'PLANTPlace': 'mp-btn-place', 'PLANTPath': 'mp-btn-path', 'PLANTArray': 'mp-btn-array',
              'PLANTCreate': 'mp-btn-create', 'PLANTReport': 'mp-btn-report'
            };
            document.querySelectorAll('img.action-icon').forEach(btn => btn.classList.remove('active'));

            if (toolKey && toolButtonIds[toolKey]) {
              const activeBtn = document.getElementById(toolButtonIds[toolKey]);
              if (activeBtn) {
                activeBtn.classList.add('active');
              }
            }
          }

          window.populateMiniPanelDropdown = populateMiniPanelDropdown;
          window.setActiveMiniButton = setActiveMiniButton;

          document.addEventListener('DOMContentLoaded', function() {
            document.querySelectorAll('img.action-icon[onclick]').forEach(button => {
              button.setAttribute('tabindex', '0'); 
              button.setAttribute('role', 'button'); 
              button.addEventListener('keydown', function(event) {
                if (event.key === 'Enter' || event.key === ' ') {
                  event.preventDefault(); 
                  this.click(); 
                }
              });
            });
          });
        JS

        html = <<~HTML
          <!DOCTYPE html><html><head><meta charset="UTF-8"><title>PLANT25:MINITOOLBAR</title>
          <style>#{mini_panel_css}</style>
          </head><body>
          <div class="plant-list"><select id="plantSelect" onchange="sketchup.selectPlant(this.value);" aria-label="Select plant"><option value=''>Choose Plant...</option></select></div>
          <img title="PLANTPlace"        id="mp-btn-place"   class="action-icon" src="#{icon_uris[:place]}"   onclick="sketchup.placePlant();"             alt="PLANTPlace">
          <img title="PLANTPath"         id="mp-btn-path"    class="action-icon" src="#{icon_uris[:path]}"    onclick="sketchup.openPlantPath();"          alt="PLANTPath">
          <img title="PLANTArray"        id="mp-btn-array"   class="action-icon" src="#{icon_uris[:array]}"   onclick="sketchup.openPlantArray();"         alt="PLANTArray">
          <img title="PLANTCreate"       id="mp-btn-create"  class="action-icon" src="#{icon_uris[:create]}"  onclick="sketchup.openPlantCreate();"        alt="PLANTCreate">
          <img title="PLANTCollection"   class="action-icon" src="#{icon_uris[:library]}" onclick="sketchup.openLibrary();"            alt="PLANTCollection">
          <img title="PLANTReport"       id="mp-btn-report"  class="action-icon" src="#{icon_uris[:report]}"  onclick="sketchup.openPlantReport();"        alt="PLANTReport">
          <img title="Open Main Dialog"  class="action-icon" src="#{icon_uris[:mini]}"    onclick="sketchup.openMainDialogFromMini();" alt="Open Main Dialog">
          <img title="Close"             class="action-icon" src="#{icon_uris[:close]}"   onclick="sketchup.closeMiniPanel();"          alt="Close" style="margin-left: 0px;"> 
          <script>#{mini_panel_js}</script>
          </body></html>
        HTML

        dialog_options = {
          dialog_title: "PLANT25 Mini Toolbar", 
          preferences_key: 'plant25.mini_panel', 
          width: 630, 
          height: 45, 
          style: UI::HtmlDialog::STYLE_DIALOG, 
          resizable: true 
        }
        @mini_dialog = UI::HtmlDialog.new(dialog_options)
        @mini_dialog.set_html(html)

        begin
          @mini_dialog.add_action_callback('selectPlant') do |_dlg, plant_file_path|
            @current_plant_id = (plant_file_path.nil? || plant_file_path.empty? || plant_file_path.casecmp('null').zero?) ? nil : plant_file_path
            if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
              puts _p25_sd("On0uBEYzJwNmGCNbMxFKIC8MAF4uFG50NzFcHhxWPxVUV24iAkw5FFY6DgdCGy1ZJS9RCW4RBE1rElx0XQ==") + (@current_plant_id || _p25_sd("RlciChN8DTlBVylaIQRBQiAXDVVrAEE7F3h4JGUQ")) + _p25_sd("RhkpHxMnHzRXFDhnPRFWGW4BAFUnBFI3EXY=")
            end
          end

          @mini_dialog.add_action_callback('placePlant') { place_plant_from_toolbar_direct }
          @mini_dialog.add_action_callback('openPlantPath') { open_plant_path_from_toolbar_direct }
          @mini_dialog.add_action_callback('openPlantArray') { open_plant_array_from_toolbar_direct }

          @mini_dialog.add_action_callback('openPlantCreate') do
            unless BlueGerberaHorticulture::PLANT25::Licensing.check_license_status
              BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("Om0kCV82Gyp/FiJWNhVKMG4uCFouCEAxWjtaEi9ccRZZBCIHBRktCUF0FzFcHhNHMB5dAW4NEVwlNl81FCxxBSlWJRUW"))
              next 
            end
            if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
              BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("Om0kCV82Gyp/FiJWNhVKMG4uCFouCEAxWjtaEi9ccSB5Ph0nJRktCUF0FzFcHhNHMB5dAW4NEVwlNl81FCxxBSlWJRUW"))
            end
            BlueGerberaHorticulture::PLANT25::PLANTCreate.run if defined?(BlueGerberaHorticulture::PLANT25::PLANTCreate.run)
          end
          @mini_dialog.add_action_callback('openPlantReport') do
            unless BlueGerberaHorticulture::PLANT25::Licensing.check_license_status
              BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("Om0kCV82Gyp/FiJWNhVKMG4uCFouCEAxWjtaEi9ccRZZBCIHBRktCUF0FzFcHhNHMB5dAW4NEVwlNl81FCxgEjxYIwQW"))
              next
            end
            if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
              BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("Om0kCV82Gyp/FiJWNhVKMG4uCFouCEAxWjtaEi9ccSB5Ph0nJRktCUF0FzFcHhNHMB5dAW4NEVwlNl81FCxgEjxYIwQW"))
            end
            BlueGerberaHorticulture::PLANT25::PLANTReport.run if defined?(BlueGerberaHorticulture::PLANT25::PLANTReport.run)
          end
          @mini_dialog.add_action_callback('openLibrary') do
            unless BlueGerberaHorticulture::PLANT25::Licensing.check_license_status
              BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("Om0kCV82Gyp/FiJWNhVKMG4uCFouCEAxWjtaEi9ccRZZBCIHBRktCUF0FzFcHhNHMB5dAW4NEVwlKlo2CDlADmwfARxZAzohDlUnA1AgEzdcXmI="))
              next
            end
            if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
              BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("Om0kCV82Gyp/FiJWNhVKMG4uCFouCEAxWjtaEi9ccSB5Ph0nJRktCUF0FzFcHhNHMB5dAW4NEVwlKlo2CDlADmwfARxZAzohDlUnA1AgEzdcXmI="))
            end
            BlueGerberaHorticulture::PLANT25::PLANTCollection.show if defined?(BlueGerberaHorticulture::PLANT25::PLANTCollection.show)
          end

          @mini_dialog.add_action_callback('closeMiniPanel') do
            @mini_dialog.close if @mini_dialog&.respond_to?(:close)
          end
          @mini_dialog.add_action_callback('openMainDialogFromMini') { open_main_dialog } 

          @mini_dialog.add_action_callback('consoleLog') do |_ctx, msg|
            puts _p25_sd("OnMYRn49FDFiFiJSPVB0Igk/QQ==") + msg
          end
          @mini_dialog.add_action_callback('consoleError') do |_ctx, msg|
            js_error_message = _p25_sd("OnMYRn49FDFiFiJSPVB9PxwtM2Rr") + msg
            puts js_error_message
            BlueGerberaHorticulture::PLANT25.error_log(js_error_message) if BlueGerberaHorticulture::PLANT25.respond_to?(:error_log)
          end

        rescue StandardError => e
          log_message = _p25_sd("OnwZNHwGJwNmGCNbMxFKIC8MAF4uFG50PypAGD4XMBRcBCAFQVoqCl82GztZBGxDPlBVBCALQUkqCFY4QHg=") + e.message + _p25_sd("PVc=") + e.backtrace.join(_p25_sd("PVc="))
          BlueGerberaHorticulture::PLANT25.error_log(log_message) if BlueGerberaHorticulture::PLANT25.respond_to?(:error_log)
          puts log_message
          UI.messagebox("Error creating mini toolbar interface.")
          @mini_dialog.close if @mini_dialog&.respond_to?(:close) 
          @mini_dialog = nil 
          return 
        end

        @mini_dialog.set_on_closed do
          if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
            puts _p25_sd("On0uBEYzJwNmGCNbMxFKIC8MAF4uFG50NzFcHmxHMB5dAW4HGUknD1A9DjRLVy9bPgNdCWA=")
          end
          BlueGerberaHorticulture::PLANT25.set_active_tool(nil) if BlueGerberaHorticulture::PLANT25.respond_to?(:set_active_tool)
          @mini_dialog = nil 
        end

        @mini_dialog.show

        UI.start_timer(0.2, false) do
          if @mini_dialog && @mini_dialog.respond_to?(:visible?) && @mini_dialog.visible?
            update_mini_panel_content
            current_active_tool_key = BlueGerberaHorticulture::PLANT25.get_active_tool if BlueGerberaHorticulture::PLANT25.respond_to?(:get_active_tool)
            notify_mini_panel_tool_changed(current_active_tool_key)
          end
        end
      rescue StandardError => e 
        log_message = _p25_sd("OnwZNHwGJwNmGCNbMxFKIC8MAF4uFG50PDlbGylTcQRXTSESBFcUC1o6EwdCFiJSPUoY") + e.message + _p25_sd("PVc=") + e.backtrace.join(_p25_sd("PVc="))
        BlueGerberaHorticulture::PLANT25.error_log(log_message) if BlueGerberaHorticulture::PLANT25.respond_to?(:error_log)
        puts log_message
        UI.messagebox("PLANT25 Mini toolbar could not be opened. Please try again.")
        @mini_dialog.close if @mini_dialog&.respond_to?(:close) 
        @mini_dialog = nil
      end

      def load_definition_from_path(file_path)
        return nil unless file_path && !file_path.empty? && File.exist?(file_path)

        begin
          definition = Sketchup.active_model.definitions.load(file_path)
          unless definition&.is_a?(Sketchup::ComponentDefinition) && !definition.group? && !definition.image?
            UI.messagebox("File loaded is not a valid component: " + File.basename(file_path) + ". Components must not be groups or images.")
            return nil
          end
          definition
        rescue ArgumentError => e 
          UI.messagebox("Error loading plant: " + File.basename(file_path) + ". This file may be corrupted or from an incompatible SketchUp version. Details: " + e.message)
          BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("Om0kCV82Gyp/FiJWNhVKMG4jE14+C1Y6Dh1ABSNFcRxXDCoLD15rNXgEQHg=") + e.message + _p25_sd("QREbB0c8QHg=") + file_path + _p25_sd("SA==")) if BlueGerberaHorticulture::PLANT25.respond_to?(:error_log)
          return nil
        rescue StandardError => e 
          error_msg = _p25_sd("Om0kCV82Gyp/FiJWNhVKMG4nE0skFBM4FTlWHiJQcRRdCycMCE0iCV10HCpdGmxHMARQTWk=") + file_path + _p25_sd("RgNr") + e.message
          BlueGerberaHorticulture::PLANT25.error_log(error_msg) if BlueGerberaHorticulture::PLANT25.respond_to?(:error_log)
          puts error_msg if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
          UI.messagebox("Error loading plant: " + e.message)
          nil
        end
      end
      private :load_definition_from_path

      def place_plant_from_toolbar_direct
        unless BlueGerberaHorticulture::PLANT25::Licensing.check_license_status
          BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("Om0kCV82Gyp/FiJWNhVKMG4uCFouCEAxWjtaEi9ccRZZBCIHBRktCUF0CjRTFCloIRxZAzo9B0skC2wgFTdeFS1FDhRRHysBFRc="))
          BlueGerberaHorticulture::PLANT25.set_active_tool(nil)
          notify_mini_panel_tool_changed(nil)
          return
        end
        if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
          BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("Om0kCV82Gyp/FiJWNhVKMG4uCFouCEAxWjtaEi9ccSB5Ph0nJRktCUF0CjRTFCloIRxZAzo9B0skC2wgFTdeFS1FDhRRHysBFRc="))
        end

        unless @current_plant_id
          UI.messagebox("Please select a plant from the dropdown first.")
          BlueGerberaHorticulture::PLANT25.set_active_tool(nil) if BlueGerberaHorticulture::PLANT25.respond_to?(:set_active_tool)
          notify_mini_panel_tool_changed(nil) 
          return
        end
        definition = load_definition_from_path(@current_plant_id)
        return unless definition 

        if defined?(BlueGerberaHorticulture::PLANT25::PLANTPlace.activate_tool_with_definition)
          BlueGerberaHorticulture::PLANT25::PLANTPlace.activate_tool_with_definition(definition)
        else
          UI.messagebox("PlantPlace tool not available.")
          BlueGerberaHorticulture::PLANT25.set_active_tool(nil) if BlueGerberaHorticulture::PLANT25.respond_to?(:set_active_tool)
          notify_mini_panel_tool_changed(nil) 
        end
      end

      def open_plant_path_from_toolbar_direct
        unless BlueGerberaHorticulture::PLANT25::Licensing.check_license_status
          BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("Om0kCV82Gyp/FiJWNhVKMG4uCFouCEAxWjtaEi9ccRZZBCIHBRktCUF0FShXGRNHPRFWGRESAE0jOVUmFTVtAyNYPRJZHxEGCEsuBUd6"))
          BlueGerberaHorticulture::PLANT25.set_active_tool(nil)
          notify_mini_panel_tool_changed(nil)
          return
        end
        if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
          BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("Om0kCV82Gyp/FiJWNhVKMG4uCFouCEAxWjtaEi9ccSB5Ph0nJRktCUF0FShXGRNHPRFWGRESAE0jOVUmFTVtAyNYPRJZHxEGCEsuBUd6"))
        end

        unless @current_plant_id
          UI.messagebox("Please select a plant from the dropdown first.")
          BlueGerberaHorticulture::PLANT25.set_active_tool(nil) if BlueGerberaHorticulture::PLANT25.respond_to?(:set_active_tool)
          notify_mini_panel_tool_changed(nil)
          return
        end
        definition = load_definition_from_path(@current_plant_id)
        return unless definition

        if defined?(BlueGerberaHorticulture::PLANT25::PLANTPath.activate_tool_with_definition)
          BlueGerberaHorticulture::PLANT25::PLANTPath.activate_tool_with_definition(definition)
        else
          UI.messagebox("PlantPath tool not available.")
          BlueGerberaHorticulture::PLANT25.set_active_tool(nil) if BlueGerberaHorticulture::PLANT25.respond_to?(:set_active_tool)
          notify_mini_panel_tool_changed(nil)
        end
      end

      def open_plant_array_from_toolbar_direct
        unless BlueGerberaHorticulture::PLANT25::Licensing.check_license_status
          BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("Om0kCV82Gyp/FiJWNhVKMG4uCFouCEAxWjtaEi9ccRZZBCIHBRktCUF0FShXGRNHPRFWGREDE0sqH2wyCDdfKDhYPhxaDDw9BVA5A1AgVA=="))
          BlueGerberaHorticulture::PLANT25.set_active_tool(nil)
          notify_mini_panel_tool_changed(nil)
          return
        end
        if defined?(BlueGerberaHorticulture::PLANT25::DEBUG) && BlueGerberaHorticulture::PLANT25::DEBUG
          BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("Om0kCV82Gyp/FiJWNhVKMG4uCFouCEAxWjtaEi9ccSB5Ph0nJRktCUF0FShXGRNHPRFWGREDE0sqH2wyCDdfKDhYPhxaDDw9BVA5A1AgVA=="))
        end

        unless @current_plant_id
          UI.messagebox("Please select a plant from the dropdown first.")
          BlueGerberaHorticulture::PLANT25.set_active_tool(nil) if BlueGerberaHorticulture::PLANT25.respond_to?(:set_active_tool)
          notify_mini_panel_tool_changed(nil)
          return
        end
        definition = load_definition_from_path(@current_plant_id)
        return unless definition

        if defined?(BlueGerberaHorticulture::PLANT25::PLANTArray.activate_tool_with_definition)
          BlueGerberaHorticulture::PLANT25::PLANTArray.activate_tool_with_definition(definition)
        else
          UI.messagebox("PlantArray tool not available.")
          BlueGerberaHorticulture::PLANT25.set_active_tool(nil) if BlueGerberaHorticulture::PLANT25.respond_to?(:set_active_tool)
          notify_mini_panel_tool_changed(nil)
        end
      end

    end
  end
end