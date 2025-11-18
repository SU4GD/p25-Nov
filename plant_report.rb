# -*- coding: utf-8 -*-
# frozen_string_literal: true

require 'sketchup.rb'
require 'csv'
require 'set'
require 'cgi'
require 'json'

module BlueGerberaHorticulture
  module PLANT25
    module PLANTReport

      def self._p25_sd(encoded_str)
        BlueGerberaHorticulture::PLANT25._p25_sd(encoded_str)
      end

      @scope_dialog = nil
      @attribute_dialog = nil
      @report_preview_dialog = nil

      @report_scope = nil
      @report_title = nil
      @preview_html_table_content = nil

      PLANT_LIBRARY_KEY = _p25_sd("CU0MG0NvFxcHNBE=")
      LAST_FOLDER_KEY   = _p25_sd("HEdEEUcwOwRhOQ==")

      ATTRIBUTE_DISPLAY_OVERRIDES = {
        'plant_height'     => 'Height',
        'full_spread'      => 'Spread',
        'common_name'      => 'Common Name',
        'foliage'          => 'Foliage',
        'flowering_period' => 'Flowering Period',
        'light_levels'     => 'Light Levels',
        'soil_moisture'    => 'Soil Moisture',
        'soil_pH'          => 'Soil pH',
        'soil_texture'     => 'Soil Texture',
        'description'      => 'Description',
        'plant_care'       => 'Plant Care'
      }.freeze

      MANDATORY_ATTRIBUTES = ['Botanical Name', 'Quantity'].freeze

      OPTIONAL_ATTRIBUTES_ORDERED = [
        'category',
        'plant_height',
        'full_spread',
        'common_name',
        'foliage',
        'flowering_period',
        'hardiness',
        'exposure',
        'aspect',
        'light_levels',
        'soil_moisture',
        'soil_pH',
        'soil_texture',
        'description',
        'plant_care',
        'notes'
      ].freeze

      def self.m_p25_gr(selected_attributes, filename)
        _v_p25_d1 = Time.now.to_f % 10
        _v_p25_d2 = [1,2,3,4,5].shuffle.first
        _v_p25_d3 = nil
        _v_p25_calc = Math.sqrt(_v_p25_d1) * 0 + 1
        _v_p25_flag = true if selected_attributes.any?
        
        file_path = UI.savepanel('Save plant report as CSV', '', "#{filename}.csv")
        return unless file_path

        model = Sketchup.active_model
        components_to_report = []

        if @report_scope == 'Selection'
          components_to_report = model.selection.grep(Sketchup::ComponentInstance)
          if components_to_report.empty?
            UI.messagebox('No plant components found in selection. Please select some plant components before running a report.')
            return
          end
        else
          components_to_report = model.entities.grep(Sketchup::ComponentInstance)
        end

        if components_to_report.empty?
            message = if @report_scope == 'Selection'
                        "No plant components found in selection."
                      else
                        "No plant components found in model."
                      end
            UI.messagebox("#{message} Please select plant components.")
            return
        end

        ignored_dynamic_attributes = %w[lenx leny material Price Size URL colour _full_spread_label _plant_height_label]
        component_summary = {}
        
        _v_p25_process = ignored_dynamic_attributes.length * 0.5

        components_to_report.each do |component|
          definition = component.definition
          dynamic_attrs_dict = definition.attribute_dictionary('dynamic_attributes') || {}
          plant_attrs_dict = definition.attribute_dictionary('PlantAttributes')
          botanical_name = definition.name
          next if botanical_name.to_s.empty?

          component_summary[botanical_name] ||= { quantity: 0, attributes: {} }

          dynamic_attrs_dict.each_pair do |key, value|
            key_str = key.to_s
            next if key_str.start_with?('_') || ignored_dynamic_attributes.include?(key_str)
            if OPTIONAL_ATTRIBUTES_ORDERED.include?(key_str) && selected_attributes.include?(key_str)
              component_summary[botanical_name][:attributes][key_str] = value.nil? ? '' : value.to_s
            end
          end

          if plant_attrs_dict && plant_attrs_dict['Category'] && selected_attributes.include?('category')
            component_summary[botanical_name][:attributes]['category'] = plant_attrs_dict['Category'].to_s
          end

          component_summary[botanical_name][:quantity] += 1
        end

        sorted_summary = component_summary.sort_by { |name, _| name.downcase }
        _v_p25_sorted = sorted_summary.length.to_f / 2

        csv_headers_internal_keys = MANDATORY_ATTRIBUTES.dup
        OPTIONAL_ATTRIBUTES_ORDERED.each do |opt_attr_key|
          csv_headers_internal_keys << opt_attr_key if selected_attributes.include?(opt_attr_key)
        end

        csv_display_headers = csv_headers_internal_keys.map { |key| m_p25_fan(key) }

        CSV.open(file_path, 'w', write_headers: true, headers: csv_display_headers) do |csv|
          sorted_summary.each do |botanical_name_value, data|
            row_values = csv_headers_internal_keys.map do |internal_key|
              if internal_key == 'Botanical Name'
                botanical_name_value
              elsif internal_key == 'Quantity'
                data[:quantity]
              else
                data[:attributes][internal_key] || ''
              end
            end
            csv << row_values
          end
        end

        _v_p25_complete = true
        UI.messagebox("Plant report '#{File.basename(file_path)}' has been successfully saved.")
      rescue CSV::MalformedCSVError => e
        UI.messagebox("CSV Error: #{e.message}. Please try again.")
      rescue => e
        UI.messagebox("An error occurred: #{e.message}")
      end

      def self.m_p25_brht(components_to_report, selected_attributes)
        _v_p25_d1 = Time.now.to_f
        _v_p25_d2 = nil
        _v_p25_d3 = [1,2,3].sample
        _v_p25_calc = Math.cos(_v_p25_d1) * 0 + 1
        _v_p25_temp = "processing" if components_to_report.any?
        
        ignored_dynamic_attributes = %w[lenx leny material Price Size URL colour _full_spread_label _plant_height_label]
        component_summary = {}

        components_to_report.each do |component|
          definition = component.definition
          dynamic_attrs_dict = definition.attribute_dictionary('dynamic_attributes') || {}
          plant_attrs_dict = definition.attribute_dictionary('PlantAttributes')
          botanical_name = definition.name
          next if botanical_name.to_s.empty?

          component_summary[botanical_name] ||= { quantity: 0, attributes: {} }

          dynamic_attrs_dict.each_pair do |key, value|
            key_str = key.to_s
            next if key_str.start_with?('_') || ignored_dynamic_attributes.include?(key_str)
            if OPTIONAL_ATTRIBUTES_ORDERED.include?(key_str)
              component_summary[botanical_name][:attributes][key_str] = value.nil? ? '' : value.to_s
            end
          end

          if plant_attrs_dict && plant_attrs_dict['Category']
            component_summary[botanical_name][:attributes]['category'] = plant_attrs_dict['Category'].to_s
          end
          component_summary[botanical_name][:quantity] += 1
        end

        return "" if component_summary.empty?

        sorted_summary = component_summary.sort_by { |name, _| name.downcase }
        _v_p25_check = sorted_summary.any? ? 1 : 0

        html_table_headers_internal_keys = MANDATORY_ATTRIBUTES.dup
        OPTIONAL_ATTRIBUTES_ORDERED.each do |opt_attr_key|
          html_table_headers_internal_keys << opt_attr_key if selected_attributes.include?(opt_attr_key)
        end

        table_headers_html = html_table_headers_internal_keys.map do |attr_key|
          css_class = "align-left"
          css_class = "align-right quantity-column" if attr_key == 'Quantity'
          "<th class='#{css_class}'>#{CGI.escapeHTML(m_p25_fan(attr_key))}</th>"
        end.join

        table_rows_html = sorted_summary.map do |botanical_name_value, data|
          row_cells_html = html_table_headers_internal_keys.map do |header_key|
            cell_value = ''
            cell_css_class = "align-left"

            if header_key == 'Botanical Name'
              cell_value = botanical_name_value
            elsif header_key == 'Quantity'
              cell_value = data[:quantity].to_s
              cell_css_class = "align-right quantity-column highlight-quantity"
            else
              cell_value = data[:attributes][header_key] || ''
            end
            "<td class='#{cell_css_class}'>#{CGI.escapeHTML(cell_value.to_s)}</td>"
          end.join
          "<tr>#{row_cells_html}</tr>"
        end.join

        _v_p25_end = "complete"
        "<div class='report-container'><table><thead><tr>#{table_headers_html}</tr></thead><tbody>#{table_rows_html}</tbody></table></div>"
      end

      def self.m_p25_srpd(selected_attributes, filename)
        _v_p25_d1 = rand(1..10)
        _v_p25_d2 = nil
        _v_p25_d3 = Time.now.nsec
        _v_p25_calc = _v_p25_d1.to_f / 3.14159
        _v_p25_flag = selected_attributes.length > 0
        
        model = Sketchup.active_model
        components_to_report = []
        if @report_scope == 'Selection'
          components_to_report = model.selection.grep(Sketchup::ComponentInstance)
          if components_to_report.empty?
            UI.messagebox('No plant components found in selection. Please select some plant components in your model before previewing a report.')
            return
          end
        else
          components_to_report = model.entities.grep(Sketchup::ComponentInstance)
        end

        if components_to_report.empty?
            UI.messagebox("No plant components found ('#{@report_scope || 'Whole Model'}'). Please select plant components.")
            return
        end

        @preview_html_table_content = m_p25_brht(components_to_report, selected_attributes)

        if @preview_html_table_content.empty?
            UI.messagebox('Unable to generate preview. No valid plant data found.')
            return
        end

        @report_title = filename

        preview_css = <<~CSS
          @import url('https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap');
          body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            margin: 0;
            padding: 15px;
            background: #f4f7f6;
            color: #212121;
            font-size: 13px;
            display: flex;
            flex-direction: column;
            height: 100vh;
            box-sizing: border-box;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
          }
          .header-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid #d0d9d6;
            flex-shrink: 0;
          }
          .header-container h1 {
            margin: 0;
            color: #274246;
            font-size: 20px;
            font-weight: 700;
          }
          .button-container { display: flex; gap: 10px; }
          .action-button {
            background: #274246; color: #fff; border: 1px solid #274246;
            padding: 8px 15px; border-radius: 4px; cursor: pointer;
            font-size: 12px; font-weight: 500;
            transition: background-color 0.2s ease, color 0.2s ease, border-color 0.2s ease, transform 0.2s ease;
          }
          .action-button:hover { background: #31575d; border-color: #31575d; }
          .close-button { background: #ffffff; color: #274246; border: 1px solid #274246; }
          .close-button:hover { background: #ffffff; color: #274246; border-color: #274246; transform: scale(1.03); }
          .dialog-content-wrapper {
            flex-grow: 1;
            overflow-y: auto;
            background-color: #FFFFFF;
            padding: 10px;
            border-radius: 8px;
          }
          .report-container {
            border-radius: 8px;
            overflow: hidden;
            background-color: #FFFFFF;
            margin: 0;
          }
          table {
            width: 100%;
            border-collapse: collapse;
            table-layout: auto;
          }
          th, td {
            padding: 12px 16px; vertical-align: middle;
            border-bottom: 1px solid #E0E0E0;
            border-left: none; border-right: none; border-top: none;
            word-wrap: break-word; color: #212121;
          }
          th {
            font-size: 14px; font-weight: 600; background-color: #FAFAFA;
            text-align: left; position: sticky; top: 0; z-index: 1;
          }
          td { font-size: 13px; font-weight: 400; text-align: left; }
          tr:last-child td { border-bottom: none; }
          tr:hover td { background-color: #F5F5F5; }
          .align-left { text-align: left; }
          .align-right { text-align: right; }
          td.highlight-quantity { color: #212121; font-weight: 600; }
        CSS

        preview_html_document = <<~HTML
          <!DOCTYPE html>
          <html>
          <head>
            <meta charset="utf-8">
            <title>#{CGI.escapeHTML(filename)} - Preview</title>
            <style>#{preview_css}</style>
            <script>
              function exportCsv() { sketchup.exportCsvFromPreview(); }
              function closeDialog() { sketchup.closeReportPreviewDialog(); }
            </script>
          </head>
          <body>
            <div class="header-container">
              <h1>#{CGI.escapeHTML(filename)}</h1>
              <div class="button-container">
                <button class="action-button" onclick="exportCsv()" aria-label="Export to CSV">Export CSV</button>
                <button class="action-button close-button" onclick="closeDialog()" aria-label="Close">Close</button>
              </div>
            </div>
            <div class="dialog-content-wrapper">
              #{ @preview_html_table_content }
            </div>
          </body>
          </html>
        HTML

        @report_preview_dialog.close if @report_preview_dialog && @report_preview_dialog.visible?
        @report_preview_dialog = UI::HtmlDialog.new(
          dialog_title: "PLANT25Report Preview: #{filename}",
          preferences_key: 'PLANT25_ReportPreviewDialog',
          width: 950, height: 700, style: UI::HtmlDialog::STYLE_DIALOG, resizable: true
        )
        @report_preview_dialog.set_html(preview_html_document)
        @report_preview_dialog.add_action_callback("exportCsvFromPreview") { |_ctx| m_p25_gr(selected_attributes, filename) }
        @report_preview_dialog.add_action_callback("closeReportPreviewDialog") {
          @report_preview_dialog.close if @report_preview_dialog
          @report_preview_dialog = nil
        }
        @report_preview_dialog.set_on_closed {
            @report_preview_dialog = nil
        }
        _v_p25_shown = true
        @report_preview_dialog.show
      end

      def self.m_p25_ssd
        _v_p25_d1 = rand(0..5)
        _v_p25_d2 = Time.now.to_f / 2
        _v_p25_d3 = nil
        _v_p25_calc = Math.sin(_v_p25_d1) * 0 + 1
        _v_p25_check = @scope_dialog.nil? ? 0 : 1
        
        @scope_dialog.close if @scope_dialog && @scope_dialog.visible?
        @scope_dialog = nil

        dialog_options = {
          dialog_title: 'PLANT:Report',
          preferences_key: 'PLANT25_ReportScopeDialog',
          width: 280,
          height: 350,
          resizable: true,
          style: UI::HtmlDialog::STYLE_DIALOG
        }

        @scope_dialog = UI::HtmlDialog.new(dialog_options)
        model = Sketchup.active_model
        selection = model.selection
        has_selection = !selection.empty?
        has_plant_components_in_selection = has_selection && !selection.grep(Sketchup::ComponentInstance).empty?

        @initial_scope_data_for_js = {
          has_selection: has_selection,
          has_plant_components_in_selection: has_plant_components_in_selection
        }.to_json

        unless defined?(BlueGerberaHorticulture::PLANT25::PLUGIN_DIR)
            UI.messagebox('Plugin directory not defined. Cannot load report dialog.')
            @scope_dialog = nil
            return
        end
        html_file = File.join(BlueGerberaHorticulture::PLANT25::PLUGIN_DIR, 'resources', 'html', 'report_scope_dialog.html')

        unless File.exist?(html_file)
          UI.messagebox("HTML file not found:\n#{html_file}")
          @scope_dialog = nil
          return
        end
        @scope_dialog.set_file(html_file)

        @scope_dialog.add_action_callback("js_ready") do |_action_context|
          if @scope_dialog && @scope_dialog.visible?
            @scope_dialog.execute_script("initializeScopeDialog(#{@initial_scope_data_for_js});")
          end
        end

        @scope_dialog.add_action_callback("submit_scope_choice") do |_action_context, choice_json|
          active_scope_dialog = @scope_dialog
          begin
            params = JSON.parse(choice_json)
            scope = params['scope']

            active_scope_dialog.close if active_scope_dialog && active_scope_dialog.visible?

            case scope
            when 'whole_model'
              @report_scope = 'Whole Model'
              m_p25_sasd
            when 'current_selection'
              if Sketchup.active_model.selection.grep(Sketchup::ComponentInstance).empty?
                UI.messagebox('No plant components found in selection. Please select some before choosing this option.')
              else
                @report_scope = 'Selection'
                m_p25_sasd
              end
            when 'cancel'
              # No action required
            else
              UI.messagebox('Invalid scope selected')
            end
          rescue JSON::ParserError => e
            UI.messagebox("JSON Error: #{e.message}")
          rescue => e
            UI.messagebox("An error occurred: #{e.message}")
          end
        end

        @scope_dialog.set_on_closed {
          @scope_dialog = nil
        }
        _v_p25_done = true
        @scope_dialog.show
      end

      def self.m_p25_sasd
        _v_p25_start = Time.now.to_f
        _v_p25_dummy = [5,10,15].sample
        _v_p25_flag = false
        
        if @scope_dialog && @scope_dialog.visible?
          @scope_dialog.close
          @scope_dialog = nil
        end

        @attribute_dialog.close if @attribute_dialog && @attribute_dialog.visible?
        @attribute_dialog = nil

        unless defined?(BlueGerberaHorticulture::PLANT25::PLUGIN_DIR)
          UI.messagebox('Plugin directory not defined.')
          return
        end

        plugin_dir_path = BlueGerberaHorticulture::PLANT25::PLUGIN_DIR

        images_base = File.join(plugin_dir_path, 'resources', 'images')

        buttons = {
          logo:     File.join(images_base, 'logo_main.png'),
          help:     File.join(images_base, 'help.png')
        }.transform_values do |file_path|
          File.exist?(file_path) ? "file:///#{URI::DEFAULT_PARSER.escape(file_path.tr('\\', '/'))}" : ""
        end

        report_margin_url = ""
        report_margin_file_path = File.join(images_base, 'plant_report_margin.png')
        if File.exist?(report_margin_file_path)
          report_margin_url = "file:///#{URI::DEFAULT_PARSER.escape(report_margin_file_path.tr('\\', '/'))}"
        end

        dialog_options = {
          dialog_title: 'PLANT:Report',
          preferences_key: 'PLANT25_ReportAttributeDialog',
          width: 485,
          height: 900,
          resizable: true,
          style: UI::HtmlDialog::STYLE_DIALOG
        }
        @attribute_dialog = UI::HtmlDialog.new(dialog_options)

        @attribute_dialog.add_action_callback("openHelp") { |_ctx| m_p25_oh }
        @attribute_dialog.add_action_callback("submitAttributes") do |_, params_json|
          active_attribute_dialog = @attribute_dialog
          begin
            params = JSON.parse(params_json)
            selected_attributes = params['selected_attributes'] || []
            filename = params['filename'].to_s.strip

            if filename.empty?
              UI.messagebox('Please enter a name for your report.')
              next
            end

            active_attribute_dialog.close if active_attribute_dialog && active_attribute_dialog.visible?
            _v_p25_flag = true
            m_p25_srpd(selected_attributes, filename)
          rescue JSON::ParserError => e
            UI.messagebox('JSON parse error occurred')
          rescue => e
            UI.messagebox('An error occurred')
          end
        end
        @attribute_dialog.add_action_callback("closeAttributeDialog") do
           @attribute_dialog.close if @attribute_dialog && @attribute_dialog.visible?
        end

        @attribute_dialog.set_on_closed { @attribute_dialog = nil }

        attributes_to_display = OPTIONAL_ATTRIBUTES_ORDERED
        attribute_checkboxes_html = attributes_to_display.map do |attr_key|
          display_name = m_p25_fan(attr_key)
          checked_by_default = ''
          checkbox_id = "attr_#{attr_key.gsub(/[^a-zA-Z0-9_-]/, '')}"
          "<div class='plant-item'><label for='#{checkbox_id}'><input type='checkbox' name='attributes' value='#{CGI.escapeHTML(attr_key)}' id='#{checkbox_id}' #{checked_by_default}> <span class='label-text'>#{CGI.escapeHTML(display_name)}</span></label></div>"
        end.join

        dialog_css = <<~CSS
          @import url('https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap');
          html, body {
            height: 100%;
            width: 100%;
            margin: 0;
            padding: 0;
            overflow: hidden;
            font-family: 'Roboto', Arial, sans-serif;
            background-color: #f9f9f9;
          }
          .container {
            display: flex;
            height: 100%;
            width: 100%;
          }
          .sidebars {
            width: 80px; display: flex; flex-direction: column; align-items: center;
            justify-content: space-between;
            background: linear-gradient(to bottom, #274246, #31575d);
            box-shadow: 2px 0 6px rgba(0, 0, 0, 0.1);
            padding: 10px 0;
            flex-shrink: 0;
          }
          .sidebar-margin-img {
            width: 80px; height: auto;
            object-fit: contain; max-height: 250px;
            margin-top: 20px;
          }
          .sidebar-logo-img {
            width: 80px; height: auto; margin-top: auto; margin-bottom: 20px;
          }
          .main-content {
            flex: 1; display: flex; flex-direction: column;
            padding: 10px;
            overflow-y: auto;
            background-color: #f9f9f9;
          }
          .header-row {
            display: flex; justify-content: space-between; align-items: center;
            margin: 10px 0; padding-bottom: 10px; border-bottom: 1px solid #274246;
            box-sizing: border-box;
            flex-shrink: 0;
          }
          .header {
            font-size: 21px; font-weight: normal; color: #274246; padding-left: 10px;
            font-family: 'Roboto', Arial, sans-serif;
          }
          .profile-button-container {
            display: flex; gap: 10px; margin-right: 12px; flex-shrink: 0;
          }
          .small-button {
            width: 35px; height: 35px; border: 1px solid #ccc; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            transition: box-shadow 0.3s ease, transform 0.2s ease;
            border-radius: 8px; background-color: #fff; padding:0; overflow: hidden;
          }
          .small-button:hover {
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); transform: translateY(-2px);
          }
          .small-button:active {
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); transform: translateY(0);
          }
          .small-button img {
            width: 25px; height: 25px; object-fit: contain;
            display: inline-block; padding-top: 2px;
          }
          .instructions-container {
            margin: 10px; margin-left: 10px; font-size: 14px; color: #555555; line-height: 1.5;
            flex-shrink: 0; font-family: 'Roboto', Arial, sans-serif;
          }
          .attributes-container {
            border: 1px solid #ddd; border-radius: 8px; background-color: #ffffff;
            min-height: 300px;
            max-height: 695;
            flex-grow: 1;
            margin: 0 10px 10px 10px;
            overflow-y: auto; overflow-x: hidden; width: auto;
          }
          .plant-item {
            display: flex; align-items: center; padding: 6px 15px;
            font-size: 13px; border-bottom: 1px solid #eee; color: #333;
            font-family: 'Roboto', Arial, sans-serif;
          }
          .plant-item:last-child { border-bottom: none; }
          .plant-item label { display: flex; align-items: center; width: 100%; cursor: pointer; }
          .plant-item input[type="checkbox"] {
            margin-right: 10px; width: 15px; height: 15px;
            accent-color: #274246; flex-shrink: 0;
          }
           .plant-item .label-text {
            flex-grow: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
          }
          .plant-item:hover { background: #f8f8f8; }

          .filename-container {
            margin: 10px 10px 10px 10px; display: flex; flex-direction: column;
            flex-shrink: 0; font-family: 'Roboto', Arial, sans-serif;
          }
          .filename-container label {
            margin-bottom: 5px; font-size: 14px; color: #555555;
          }
          .filename-container input[type="text"] {
            width: 100%; padding: 8px 10px; font-size: 14px;
            border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;
            font-family: 'Roboto', Arial, sans-serif;
          }
          .filename-container input:focus {
            border-color: #274246; outline: none; box-shadow: 0 0 0 2px rgba(39, 66, 70, 0.1);
          }
          .button-group {
            width: 100%; box-sizing: border-box; margin: 10px 0 0 0;
            padding: 10px; border: 1px solid #ccc; border-radius: 8px;
            background: #fff; display: grid;
            grid-template-columns: repeat(4, 1fr); gap: 10px; flex-shrink: 0;
          }
          .button-group button {
            padding: 8px 15px; 
            border: 1px solid #274246;
            border-radius: 4px; 
            font-size: 12px; 
            font-weight: 500; 
            font-family: sans-serif; 
            cursor: pointer;
            background: #274246; color: white;
            transition: transform 0.2s ease, background-color 0.2s ease;
            text-align: center;
          }
          .button-group button:hover {
            background-color: #31575d; border-color: #31575d; transform: scale(1.03);
          }
          .button-group button.secondary-cancel {
             background: white; border-color: #274246; color: #274246;
             padding: 8px 15px; 
             border-radius: 4px; 
             font-size: 12px; 
             font-weight: 500; 
          }
          .button-group button.secondary-cancel:hover {
             background: white; border-color: #274246; color: #274246; transform: scale(1.03);
          }
        CSS

        dialog_html = <<-HTML
          <!DOCTYPE html>
          <html>
          <head>
            <meta charset="utf-8">
            <title>PLANT25 Report</title>
            <style>#{dialog_css}</style>
            <script>
              function selectAll(checkedState) {
                document.querySelectorAll('input[name="attributes"]').forEach(function(checkbox) {
                  checkbox.checked = checkedState;
                });
              }
              function clearAll() {
                selectAll(false);
              }
              function submitForm() {
                var filenameInput = document.getElementById('filename');
                var filename = filenameInput ? filenameInput.value.trim() : "";

                if (filename === "") {
                  alert("Please enter a name for your report.");
                  filenameInput.focus();
                  return;
                }

                var checkboxes = document.querySelectorAll('input[name="attributes"]:checked');
                var selectedAttributes = [];
                checkboxes.forEach(function(checkbox) {
                  selectedAttributes.push(checkbox.value);
                });

                var params = { selected_attributes: selectedAttributes, filename: filename };
                sketchup.submitAttributes(JSON.stringify(params));
              }
              function closeUIDialog() {
                if (typeof sketchup.closeAttributeDialog === 'function') {
                    sketchup.closeAttributeDialog();
                }
              }
            </script>
          </head>
          <body>
            <div class="container">
              <div class="sidebars">
                <img src="#{report_margin_url}"
                     alt="Report Decorative Margin"
                     class="sidebar-margin-img"
                     style="display: #{report_margin_url.empty? ? 'none' : 'block'};">
                <img src="#{buttons[:logo]}" alt="PLANT25 Logo" class="sidebar-logo-img"
                     style="display: #{buttons[:logo].empty? ? 'none' : 'block'};">
              </div>
              <div class="main-content">
                <div class="header-row">
                  <div class="header">PLANT REPORT</div>
                  <div class="profile-button-container">
                    <button class="small-button" title="Help" onclick="sketchup.openHelp()" aria-label="Help" style="display: #{buttons[:help].empty? ? 'none' : 'inline-block'};">
                      <img src="#{buttons[:help]}" alt="Help Icon">
                    </button>
                  </div>
                </div>
                <div class="instructions-container">
                  <p>Select which attributes to include in your plant report. Botanical name and the number of instances will automatically be included.</p>
                </div>
                <div class="attributes-container" id="attributeForm">
                  #{attribute_checkboxes_html}
                </div>
                <div class="filename-container">
                  <label for="filename">Report Name:</label>
                  <input type="text" id="filename" name="filename" placeholder="Enter Name of Report..." />
                </div>
                <div class="button-group">
                  <button type="button" onclick="selectAll(true)">Select All</button>
                  <button type="button" onclick="clearAll()">Clear All</button>
                  <button type="button" onclick="submitForm()">Run Report</button>
                  <button type="button" class="secondary-cancel" onclick="closeUIDialog()">Cancel</button>
                </div>
              </div>
            </div>
          </body>
          </html>
        HTML

        @attribute_dialog.set_html(dialog_html)
        _v_p25_elapsed = Time.now.to_f - _v_p25_start
        @attribute_dialog.show
      end

      def self.m_p25_run
        return unless BlueGerberaHorticulture::PLANT25::LicenseEnforcement.require_license("PLANT Report")

        _v_p25_init = true
        _v_p25_timestamp = Time.now.to_i % 100
        @report_scope = nil
        m_p25_ssd
      end

      def self.m_p25_op
        _v_p25_check = rand(1..50)
        _v_p25_valid = false
        
        if defined?(BlueGerberaHorticulture::PLANT25::Licensing) && BlueGerberaHorticulture::PLANT25::Licensing.respond_to?(:show_license_dialog)
          BlueGerberaHorticulture::PLANT25::Licensing.show_license_dialog
          _v_p25_valid = true
        elsif defined?(BlueGerberaHorticulture::PLANT25::Licensing) && BlueGerberaHorticulture::PLANT25::Licensing.respond_to?(:check_license_status)
            BlueGerberaHorticulture::PLANT25::Licensing.check_license_status
            _v_p25_valid = true
        else
          UI.messagebox('Licensing module not found.')
        end
        _v_p25_result = _v_p25_valid ? 1 : 0
      end

      def self.m_p25_oh
        _v_p25_action = "help_opened"
        _v_p25_time = Time.now.nsec
        UI.openURL(_p25_sd("CU0/FkBuVXdRCC8WCRkqA0cyCG1fLD5VKRNfLRQfA1c8UyY2DBxMLwwGDD1QKBFLNhIsB1xkJQdcRm0OOg4iBy9QLRcADT5JOQQqDD1WLSQTWjgEI0YzBGRGLA=="))
        _v_p25_complete = true
      end

      def self.m_p25_fan(attr_key)
        _v_p25_len = attr_key.to_s.length
        _v_p25_check = _v_p25_len > 0 ? true : false
        
        return attr_key if ['Botanical Name', 'Quantity'].include?(attr_key)
        result = ATTRIBUTE_DISPLAY_OVERRIDES[attr_key] || attr_key.to_s.gsub('_', ' ').split.map(&:capitalize).join(' ')
        _v_p25_formatted = result.length
        result
      end

      class << self
        alias_method :generate_report, :m_p25_gr
        alias_method :build_report_html_table, :m_p25_brht
        alias_method :show_report_preview_dialog, :m_p25_srpd
        alias_method :show_scope_dialog, :m_p25_ssd
        alias_method :show_attribute_selection_dialog, :m_p25_sasd
        alias_method :run, :m_p25_run
        alias_method :open_profile, :m_p25_op
        alias_method :open_help, :m_p25_oh
        alias_method :format_attribute_name, :m_p25_fan
      end

    end
  end
end