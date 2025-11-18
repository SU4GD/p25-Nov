# -*- coding: utf-8 -*-
# plant_collection.rb — Manages the PLANTCollection dialog
# frozen_string_literal: true

require 'sketchup.rb'
require 'json'
require 'fileutils'
require 'uri'
require 'cgi'

def _p25_sd(encoded_str)
  BlueGerberaHorticulture::PLANT25._p25_sd(encoded_str)
end

# Ensure core PLANT25 module is loaded (provides PLUGIN_DIR, logging, etc.)
begin
  # __dir__ is PLANT25/PLANTCollection/
  # File.expand_path('..', __dir__) is PLANT25/
  core_plant25_path = File.join(File.expand_path('..', __dir__), 'core', 'plant25.rb')
  require core_plant25_path
rescue LoadError => e
  UI.messagebox("PLANT25 Core module not found: " + e.message)
  raise e # Critical dependency
end

# Load TemplateComponents, which handles SKP attribute reading and updating for this dialog
begin
  require_relative 'plant_collection_assets/html/components/template_components'
rescue LoadError => e
  expected_path = File.expand_path(File.join(__dir__, 'plant_collection_assets', 'html', 'components', 'template_components.rb'))
  error_message = "PLANT25 TemplateComponents module not found. Expected at: " + expected_path + ". Error: " + e.message
  BlueGerberaHorticulture::PLANT25.error_log(error_message)
  UI.messagebox(error_message)
  raise e
end

module BlueGerberaHorticulture
  module PLANT25
    module PLANTCollection

      def self._p25_sd(encoded_str)
        BlueGerberaHorticulture::PLANT25._p25_sd(encoded_str)
      end

      FRIENDLY_LABELS = {
        "botanical_name"   => "Botanical Name",
        "category"         => "Category", 
        "common_name"      => "Common Name",
        "foliage"          => "Foliage",
        "colour"           => "Flower Colour",
        "color"            => "Flower Colour",
        "plant_height"     => "Plant Height (mm)",
        "full_spread"      => "Full Spread (mm)",
        "flowering_period" => "Flowering Period",
        "light_levels"     => "Light Levels",
        "soil_moisture"    => "Soil Moisture",
        "soil_texture"     => "Soil Texture",
        "soil_pH"          => "Soil pH",
        "hardiness"        => "Hardiness",
        "exposure"         => "Exposure",
        "aspect"           => "Aspect",
        "description"      => "Description",
        "plant_care"       => "Plant Care",
        "notes"            => "Notes",
        "reduce_opacity"   => "Reduce Opacity"
      }.freeze

    SELECT_OPTIONS = {
        "category"         => ["", "Annual", "Biennial", "Bulb", "Climber", "Fern", "Ornamental Grass", "Perennial", "Shrub", "Tree"],
        "foliage"          => ["", "Evergreen", "Semi-Evergreen", "Deciduous"],
        "flowering_period" => ["", "Early Spring", "Mid Spring", "Late Spring", "Early Summer", "Mid Summer", "Late Summer", "Autumn", "Winter", "Non-Flowering/Insignificant"],
        "light_levels"     => ["", "Full Sun", "Full Sun/Partial Shade", "Partial Shade", "Partial Shade/Shade", "Shade"],
        "soil_moisture"    => ["", "Moist/Well Drained", "Poorly Drained", "Dry", "Any"],
        "hardiness"        => ["", "Hardy", "Half-Hardy", "Tender"],
        "soil_pH"          => ["", "Acidic", "Neutral-Acidic", "Neutral", "Neutral-Alkaline", "Alkaline", "Various"],
        "soil_texture"     => ["", "Chalk", "Clay", "Loam", "Sand", "Silt", "Various"],
        "exposure"         => ["", "Exposed", "Sheltered", "Any"],
        "aspect"           => ["", "North", "North East", "North West", "East", "South", "South East", "South West", "West", "Any"]
      }.freeze

      class DialogManager
        def initialize
          BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24mCFgnCVQZGzZTEClFcRlWBDoLAFUiHFZ0CSxTBThSNQ=="))
          assets_path = File.join(__dir__, 'plant_collection_assets')

          @dialog = UI::HtmlDialog.new(
            dialog_title:    "PLANT:Collection",
            preferences_key: 'com.bluegerberahorticulture.plant_collection',
            width:           900, height: 800, resizable: true, style: UI::HtmlDialog::STYLE_DIALOG
          )

          html_file_path = File.join(assets_path, 'html', 'template.html')
          unless File.exist?(html_file_path)
            msg = "PLANT25 PLANTCollection HTML template not found at: " + html_file_path
            BlueGerberaHorticulture::PLANT25.error_log(msg); UI.messagebox(msg); raise IOError, msg
          end

          html_content = File.read(html_file_path)
          main_plugin_root_for_url = if defined?(BlueGerberaHorticulture::PLANT25::PLUGIN_DIR)
                                       BlueGerberaHorticulture::PLANT25::PLUGIN_DIR.tr('\\', '/')
                                     else
                                       BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("Om4qFF09FD9vLBx7ED5sLiEODVwoElo7FAUSGSN0ORFWCisRLFgvAxMjEyxaGDlDcRNXAD4ND1wlEnowVA=="))
                                       File.expand_path(File.join(__dir__, '..', '..')).tr('\\', '/')
                                     end
          modified_html_content = html_content.gsub('{PLUGIN_PATH}', main_plugin_root_for_url)
          @dialog.set_html(modified_html_content)

          setup_callbacks # Define all callbacks
        end

        def _p25_sd(encoded_str)
          BlueGerberaHorticulture::PLANT25._p25_sd(encoded_str)
        end

        def setup_callbacks
          @dialog.add_action_callback('js_is_ready') do |_ctx|
            BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24IEmYiFWwmHzlWDmxUMBxUDy8BChk/FFozHT1AEigZ"))
            folder_on_ready = BlueGerberaHorticulture::PLANT25.get_plant_library_path
            skp_files_on_ready = (folder_on_ready && Dir.exist?(folder_on_ready)) ? Dir.glob(File.join(folder_on_ready, '**', '*.skp')) : []
            lightweight_attributes_json = TemplateComponents.generate_attributes_json(skp_files_on_ready)
            script = TemplateComponents.js_init_script(lightweight_attributes_json)
            BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24nGVwoE0c9FD8SHiJeJRlZAScYAE0iCV10CTtAHjxDcVhUCCAFFVFxRg==") + script.length.to_s + _p25_sd("SA=="))
            @dialog.execute_script(script)
          end

          @dialog.add_action_callback('fetchPlantDetailsCallback') do |_ctx, file_path, component_id_from_js|
            BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24EBE0oDmM4GzZGMylDMBlUHm4EDktrAFo4H2IS") + file_path + _p25_sd("TRkiAgl0") + component_id_from_js.to_s)
            begin
              safe_js_id = component_id_from_js.to_s.gsub('\\', '\\\\').gsub("'", "\\'")
              unless file_path && !file_path.empty? && File.exist?(file_path)
                BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24EBE0oDmM4GzZGMylDMBlUHm5PQXAlEFI4EzwSESVbNC9IDDoKWxk=") + file_path.inspect)
                err_attrs = { load_error: true, message: "File not found", _details_loaded: false }.to_json.gsub('\\'){'\\\\'}.gsub("'"){"\\'"}.gsub("\n"){'\\n'}.gsub("\r"){"\\r"}
                @dialog.execute_script("receiveFullPlantDetails('#{safe_js_id}', JSON.parse('#{err_attrs}'));"); next
              end
              full_attrs = TemplateComponents.load_dynamic_attributes(file_path)
              full_attrs = { load_error: true, message: "Invalid attributes format", _details_loaded: false } unless full_attrs.is_a?(Hash)
              full_attrs[:_details_loaded] = true
              json_str = full_attrs.to_json.gsub('\\'){'\\\\'}.gsub("'"){"\\'"}.gsub("\n"){'\\n'}.gsub("\r"){"\\r"}
              js_cmd = "receiveFullPlantDetails('#{safe_js_id}', JSON.parse('#{json_str}'));"
              BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24oMhkICV45GzZWVypYI1BeCDoBCWknB10gPj1GFiVbIlAQCycQEk1rVwNkU2IS") + js_cmd.slice(0,100)) if BlueGerberaHorticulture::PLANT25::DEBUG && component_id_from_js.to_s.match?(/Goucher|Kaleidoscope|Dissectum/)
              @dialog.execute_script(js_cmd)
            rescue => e
              BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24EBE0oDmM4GzZGMylDMBlUHg0DDVUpB1A/Wj1ABSNFa1A=") + e.message + _p25_sd("PVc=") + e.backtrace.first(3).join(_p25_sd("PVc=")))
              safe_js_id_err = (defined?(component_id_from_js) && component_id_from_js) ? component_id_from_js.to_s.gsub('\\','\\\\').gsub("'", "\\'") : "error_id"
              err_attrs = { load_error: true, message: "Exception: " + e.message.to_s.gsub("'", "\\'"), _details_loaded: false }.to_json.gsub('\\'){'\\\\'}.gsub("'"){"\\'"}.gsub("\n"){'\\n'}.gsub("\r"){"\\r"}
              @dialog.execute_script("receiveFullPlantDetails('#{safe_js_id_err}', JSON.parse('#{err_attrs}'));")
            end
          end

          @dialog.add_action_callback('saveUpdatedAttributes') do |_ctx, json_data_from_js|
            begin
              BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24RAE8uM0MwGyxXEw1DJQJRDzsWBEprFFY3HzFEEigXeRZRHz0WQQh7VhpuWg==") + json_data_from_js.slice(0,100))
              data = JSON.parse(json_data_from_js)
              cid, fp, upd = data['componentId'], data['filePath'], data['updates']
              unless fp && !fp.empty? && File.exist?(fp)
                BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24RAE8uM0MwGyxXEw1DJQJRDzsWBEprSxMdFC5TGyVTcRZRASs9EVg/Dgl0") + fp.inspect)
                @dialog.execute_script("if(typeof showSaveError === 'function') { showSaveError('File path not found or invalid.'); }"); next
              end
              safe_js_cid = cid.to_s.gsub('\\','\\\\').gsub("'", "\\'")
              saved_attrs = TemplateComponents.update_skp_file(fp, upd, cid)
              if saved_attrs
                BlueGerberaHorticulture::PLANT25.notify_library_changed
                json_str = saved_attrs.to_json.gsub('\\'){'\\\\'}.gsub("'"){"\\'"}.gsub("\n"){'\\n'}.gsub("\r"){"\\r"}
                @dialog.execute_script("updateAttributesMapAndRefreshView('#{safe_js_cid}', JSON.parse('#{json_str}'));")
                UI.messagebox("Plant \"" + (saved_attrs['botanical_name'] || cid) + "\" updated successfully.")
              else
                BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24RAE8uM0MwGyxXEw1DJQJRDzsWBEprSxMhCjxTAyloIhtIMigLDVxrAFI9Fj1WVypYI1A=") + cid.to_s + ".")
              end
            rescue JSON::ParserError => e
              BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24RAE8uM0MwGyxXEw1DJQJRDzsWBEprLGAbNHhXBT5YI0oY") + e.message)
              UI.messagebox("Error parsing update data. Please try again.")
            rescue => e
              BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24RAE8uM0MwGyxXEw1DJQJRDzsWBEprA0EmFSoIVw==") + e.message + _p25_sd("PVc=") + e.backtrace.first(3).join(_p25_sd("PVc=")))
              UI.messagebox("An error occurred while saving. Please try again.")
            end
          end

          @dialog.add_action_callback('noChangesMade') do |_ctx, cid_js|
            if cid_js && !cid_js.empty?
              safe_js_cid = cid_js.to_s.gsub('\\','\\\\').gsub("'", "\\'")
              @dialog.execute_script("if(window.showComponentAttributes) { window.showComponentAttributes('#{safe_js_cid}'); }")
            else BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("Om4qFF09FD9vLBx7ED5sLiEODVwoElo7FAUSGSN0ORFWCisRLFgvAxMjEyxaGDlDcRNXAD4ND1wlEnowVA==")) end
          end

       @dialog.add_action_callback('deletePlantFile') do |_ctx, json_data|
  begin
    data = JSON.parse(json_data); cid, fp = data['componentId'], data['filePath']
    
    # Normalize the file path for the current platform
    fp = File.expand_path(fp) if fp
    
    BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24GBFUuElYEFjlcAwpePRUYCyEQQVAvXBM=") + cid.to_s + _p25_sd("TRk7B0c8QHg=") + fp.to_s)
    unless fp && fp.is_a?(String) && !fp.empty? && File.exist?(fp)
      BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24GBFUuElYEFjlcAwpePRUYQG4rD08qClowWj5bGyloIRFMBXRC") + fp.inspect); 
      UI.messagebox("Error: File path not found or invalid for deletion."); next
    end
              unless cid && cid.is_a?(String) && !cid.empty?
                BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24GBFUuElYEFjlcAwpePRUYQG4rD08qClowWjtdGjxYPxVWGRELBQNr") + cid.inspect); 
                UI.messagebox("Error: Component ID invalid for deletion."); next
              end
              name_alert = File.basename(fp, ".*")
              begin
                File.delete(fp)
                BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24mBFUuElYwWj5bGykNcQ==") + fp)
                BlueGerberaHorticulture::PLANT25.notify_library_changed
                UI.messagebox("Plant \"" + name_alert + "\" deleted successfully.")
                if @dialog&.visible?
                  safe_js_cid = cid.to_s.gsub('\\','\\\\').gsub("'", "\\'")
                  @dialog.execute_script("removeItemFromCollection('#{safe_js_cid}')")
                end
              rescue SystemCallError => e; 
                BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24GBFUuElYEFjlcAwpePRUYPjcRFVwmJVI4Fh1ABSNFa1A=") + e.message); 
                UI.messagebox("Error deleting " + name_alert + ": " + e.message)
              rescue => e; 
                BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24GBFUuElYEFjlcAwpePRUYCDwQDktxRg==") + e.message); 
                UI.messagebox("Unexpected error deleting " + name_alert + ": " + e.message)
              end
            rescue JSON::ParserError => e; 
              BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24GBFUuElYEFjlcAwpePRUYJx0tLxkuFEE7CGIS") + e.message); 
              UI.messagebox("Error: Invalid delete request format.")
            rescue => e; 
              BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24GBFUuElYEFjlcAwpePRUYDi8ODVsqBVh0HypAGD4NcQ==") + e.message); 
              UI.messagebox("Unexpected error processing delete request.")
            end
          end

          @dialog.add_action_callback('openHelp') { UI.openURL('https://www.sketchupforgardendesign.com/plant25/plant25help') }

          @dialog.add_action_callback('openProfile') do # Placeholder for PLANTCollection-specific profile info
            UI.messagebox("PLANTCollection Profile feature coming soon!")
          end

          @dialog.add_action_callback('manualRefreshCallback') do
            BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24PAFc+B18GHz5AEj9fEhFUASwDAlJrEkE9HT9XBSlTfw=="))
            folder_refresh = BlueGerberaHorticulture::PLANT25.get_plant_library_path
            skp_files = (folder_refresh && Dir.exist?(folder_refresh)) ? Dir.glob(File.join(folder_refresh, '**', '*.skp')) : []
            json_refresh = TemplateComponents.generate_attributes_json(skp_files)
            script_init = TemplateComponents.js_init_script(json_refresh)
            @dialog.execute_script("if(typeof clearPlantList === 'function') { clearPlantList(); } #{script_init}")
          end

          @dialog.add_action_callback('closePlantCollectionDialog') { @dialog.close if @dialog&.visible? }
          @dialog.set_on_closed {
            BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24mCFgnCVR0GTRdBClTfw=="))
            BlueGerberaHorticulture::PLANT25.set_active_tool(nil)
            @dialog = nil
          }
        end # end setup_callbacks

        def show_dialog
          if @dialog && @dialog.respond_to?(:visible?)
            @dialog.visible? ? @dialog.bring_to_front : @dialog.show
          else
            BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24RCVY8OVc9GzRdEGwacQJdQCcMCE0iB189ADFcEGxBOBEYHisOBxc5E116"))
            BlueGerberaHorticulture::PLANT25::PLANTCollection.run
          end
        end
      end # end class DialogManager

# After
      @dialog_manager_instance = nil

      def self.run
        return unless BlueGerberaHorticulture::PLANT25::LicenseEnforcement.require_license("PLANT Collection") # <-- ADD THIS LINE
        
        BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24RBFUtSEEhFHhRFiBbNBQ="))
        BlueGerberaHorticulture::PLANT25.set_active_tool("PLANTCollection")
        if @dialog_manager_instance.nil? || !(@dialog_manager_instance.instance_variable_get(:@dialog)&.respond_to?(:visible?))
          BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24hE1wqElo6HXhcEjsXFRlZASEFLFglB1QxCHhbGT9DMB5bCGA="))
          @dialog_manager_instance = DialogManager.new
        else
          BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24wBEw4D10zWj1KHj9DOB5fTQoLAFUkAX41FDlVEj4XOB5LGS8MAlxl"))
        end
        @dialog_manager_instance.show_dialog
      rescue => e
        BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("MXUKKGcXNRR+Mg9jGD92V24kIG0KKhMxCCpdBWxeP1BLCCIET0s+CAl0") + e.message + _p25_sd("PVc=") + e.backtrace.join(_p25_sd("PVc=")))
        UI.messagebox("Error opening PLANTCollection dialog: " + e.message + ". Please try again.")
        BlueGerberaHorticulture::PLANT25.set_active_tool(nil)
      end

      def self.show; run; end

    end # module PLANTCollection
  end # module PLANT25
end # module BlueGerberaHorticulture