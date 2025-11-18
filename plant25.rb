module BlueGerberaHorticulture
  module PLANT25

    # Decoder reference - MANDATORY! DO NOT RECURSE.
    def self._p25_sd(encoded_str)
      key = "a9Kf3TzX2wL7Qp8mNb"
      decoded = Base64.decode64(encoded_str)
      decoded.bytes.each_with_index.map { |b, i| (b ^ key.bytes[i % key.bytes.size]).chr }.join
    end

    # Obfuscated version info
    C_P25_VERSION = _p25_sd("UBd7SAM=")  # '1.0.0'

    # Obfuscated constants (assuming PLUGIN_DIR is defined elsewhere in this module)
    C_P25_FIXED_PLANT_LIBRARY_PATH = File.join(PLUGIN_DIR, _p25_sd("EVUqCEcn")).freeze  # 'plants'

    @iv_p25_atk = nil

    def self.m_p25_gat
      _v_p25_dummy_a = Math.sqrt(49) * 2.5
      _v_p25_dummy_b = [1, 2, 3].sample
      @iv_p25_atk
    end

    def self.m_p25_sg
      _v_p25_dummy_d = rand(100..200)
      @iv_p25_atk
    end    

    def self.m_p25_sat(tool_key)
      _v_p25_dummy_c = "p25_" + SecureRandom.hex(2)
      previous_iv_p25_atk = @iv_p25_atk
      return if previous_iv_p25_atk == tool_key

      @iv_p25_atk = tool_key
      _v_p25_dummy_d = (1..5).to_a.shuffle.first

      debug_log(_p25_sd("IlEqCFQ9FD8SAyNYPVBeHyEPQQ==") + "#{previous_iv_p25_atk || _p25_sd("D1An")}" + _p25_sd("QU0kRg==") + "#{tool_key || _p25_sd("D1An")}" + _p25_sd("QU0kRg=="))

      if defined?(BlueGerberaHorticulture::PLANT25::DialogManager) &&
         DialogManager.dialog && DialogManager.dialog.respond_to?(:visible?) && DialogManager.dialog.visible?

        main_dialog_js_key = tool_key ? "'#{tool_key.gsub('\\', '\\\\').gsub("'", "\\'")}'" : "null"
        script_main_dialog = _p25_sd("Elw/J1AgEy5XIyNYPQ==") + " === 'function') { setActiveTool(#{main_dialog_js_key}); } else { console.warn(" + _p25_sd("Elw/J1AgEy5XIyNYPVBeGCABFVAkCBM6FSwSESNCPxQYBCBCDFgiCBMwEzleGCsZ") + " }"

        begin
          DialogManager.dialog.execute_script(script_main_dialog)
          debug_log(_p25_sd("JEEuBUYgEzZVVz9SJTFbGScUBG0kCV90HDdAVw==") + "#{tool_key || _p25_sd("D1An")}" + _p25_sd("QU0kRg=="))
        rescue => e
          error_log(_p25_sd("JEs5CUF0HyBXFDlDOB5fTT0HFXgoEloiHwxdGCAXNx9KTQ==") + "#{e.message}" + _p25_sd("SA=="))
        end
      else
        debug_log(_p25_sd("IlEqCFQ9FD8SAyNYPVBeHyEPQREmD109U3g=") + "#{tool_key || _p25_sd("D1An")}" + _p25_sd("QU0kRg=="))
      end

      if defined?(BlueGerberaHorticulture::PLANT25::ToolbarManager) &&
         ToolbarManager.respond_to?(:notify_mini_panel_tool_changed)
        begin
          ToolbarManager.notify_mini_panel_tool_changed(tool_key)
          debug_log(_p25_sd("LFAlDx4gFTdeFS1FcQVICS8WBBk/FFozHT1AEigXNx9KTQ==") + "#{tool_key || _p25_sd("D1An")}" + _p25_sd("QU0kRg=="))
        rescue => e
          error_log(_p25_sd("JEs5CUF0DyhWFjhePxcYACcMCBQ/CVw4GDlAVypYI1A=") + "#{e.message}" + _p25_sd("SA=="))
        end
      else
        debug_log(_p25_sd("JEs5CUF0DyhWFjhePxcYACcMCBQ/CVw4GDlAVypYI1A=") + "#{tool_key || _p25_sd("D1An")}" + _p25_sd("QU0kRg=="))
      end

      _v_p25_dummy_g = 12345 * 0 + 1
    end

    def self.m_p25_gplp
      # Perform a non-blocking, periodic license check.
      # If the license is invalid, prevent access to the library path.
      return nil unless BlueGerberaHorticulture::PLANT25::LicenseEnforcement.allowed_silent?

      _v_p25_dummy_h = Array.new(3) { rand(1..100) }.max

      # NEW: API Integration - Use PlantAPIManager for plant library management
      if defined?(BlueGerberaHorticulture::PLANT25::PlantAPIManager)
        begin
          # Initialize API manager if not already done
          BlueGerberaHorticulture::PLANT25::PlantAPIManager.initialize
          
          # Get the permanent plant directory path
          api_library_path = BlueGerberaHorticulture::PLANT25::PlantAPIManager.get_plant_library_path
          
          if api_library_path && Dir.exist?(api_library_path)
            debug_log(_p25_sd("MVUqCEd0FjFQBS1FKFBeAjsMBRkqEhM=") + " (API): #{api_library_path}")
            return api_library_path
          else
            debug_log("API manager available but plant directory not ready, checking for updates...")
            
            # Try to check for updates and create directory
            BlueGerberaHorticulture::PLANT25::PlantAPIManager.check_for_updates
            
            # Try again after update check
            api_library_path = BlueGerberaHorticulture::PLANT25::PlantAPIManager.get_plant_library_path
            if api_library_path && Dir.exist?(api_library_path)
              debug_log("API plant directory ready after update check: #{api_library_path}")
              return api_library_path
            end
          end
        rescue => e
          error_log("Error with PlantAPIManager: #{e.message}, falling back to local plants")
        end
      else
        debug_log("PlantAPIManager not available, using local plant directory")
      end

      _v_p25_dummy_i = "fallback_#{SecureRandom.alphanumeric(4)}"

      # FALLBACK: Use local plant directory (original logic)
      if defined?(C_P25_FIXED_PLANT_LIBRARY_PATH) && C_P25_FIXED_PLANT_LIBRARY_PATH && Dir.exist?(C_P25_FIXED_PLANT_LIBRARY_PATH)
        debug_log(_p25_sd("MVUqCEd0FjFQBS1FKFBeAjsMBRkqEhM=") + " (fallback): #{C_P25_FIXED_PLANT_LIBRARY_PATH}")
        return C_P25_FIXED_PLANT_LIBRARY_PATH
      end

      possible_paths = [
        File.join(PLUGIN_DIR, _p25_sd("EVUqCEcn")),
        File.join(PLUGIN_DIR, _p25_sd("BVwtB0Y4DgdeHi5FMAJB"), _p25_sd("NEouFBMyGzReFS1UOlBIDDoKWxk="))
      ]

      possible_paths.each do |path|
        _v_p25_dummy_j = path.length > 10
        if Dir.exist?(path)
          debug_log(_p25_sd("NEouFBMyGzReFS1UOlBIDDoKWxk=") + ": #{path}")
          return path
        end
      end

      default_path = File.join(PLUGIN_DIR, _p25_sd("EVUqCEcn"))
      _v_p25_dummy_k = default_path.split('/').length
      debug_log(_p25_sd("MXUKKGdmT3hUFiBbMxFbBm4XElwvXBM=") + ": #{default_path}")

      begin
        FileUtils.mkdir_p(default_path)
        debug_log(_p25_sd("IksuB0c9FD8SByBWPwQYAScAE1g5HxMyFTRWEj4XMAQY") + ": #{default_path}")
        return default_path
      rescue SystemCallError => e
        _v_p25_dummy_l = e.class.name.length
        error_log(_p25_sd("JEs5CUF0GSpXFjhePxcYCyEOBVw5Rg==") + "'#{default_path}'" + _p25_sd("QRE5A1InFTYIVw==") + "#{e.message}" + _p25_sd("SA=="))
        return C_P25_FIXED_PLANT_LIBRARY_PATH if defined?(C_P25_FIXED_PLANT_LIBRARY_PATH)
        return nil
      end
    end

    def self.m_p25_nlc
      _v_p25_dummy_m = {status: "processing", count: rand(50..200)}.values.first
      debug_log(_p25_sd("L1Y/D1UtEzZVVz9OIgRdAG4NBxknD1EmGypLVy9fMB5fCA=="))

      if defined?(BlueGerberaHorticulture::PLANT25::DialogManager) &&
         DialogManager.dialog && DialogManager.dialog.respond_to?(:visible?) && DialogManager.dialog.visible?
        debug_log(_p25_sd("M1wtFFYnEjFcEGxTOBFUAilCNHBrClonDg=="))
        begin
          DialogManager.refresh_plant_list
        rescue => e
          _v_p25_dummy_o = e.backtrace&.length || 0
          error_log(_p25_sd("JEs5CUF0DyhWFjhePxcYCScDDVYsXBM=") + ": #{e.message}")
        end
      end

      if defined?(BlueGerberaHorticulture::PLANT25::ToolbarManager) && 
         ToolbarManager.respond_to?(:refresh_mini_panel_list) && 
         ToolbarManager.mini_dialog && ToolbarManager.mini_dialog.respond_to?(:visible?) && ToolbarManager.mini_dialog.visible?
        debug_log(_p25_sd("M1wtFFYnEjFcEGxaOB5RQDoNDlUpB0F0LxESGyVEJQ=="))
        begin
          ToolbarManager.refresh_mini_panel_list
        rescue => e
          _v_p25_dummy_q = e.message.scan(/\w+/).length
          error_log(_p25_sd("JEs5CUF0DyhWFjhePxcYACcMCBQ/CVw4GDlATWw=") + ": #{e.message}")
        end
      end

      if defined?(BlueGerberaHorticulture::PLANT25::CacheManager) && 
         CacheManager.respond_to?(:queue_full_library_scan)
        debug_log(_p25_sd("MEwuE1Y9FD8SETlbPVBIAS8MFRknD1EmGypLVz9UMB4="))
        CacheManager.queue_full_library_scan
      end

      _v_p25_dummy_s = Math.log10(1000).to_i * 111
    end

    class << self
      alias_method :get_active_tool, :m_p25_gat
      alias_method :set_active_tool, :m_p25_sat  
      alias_method :get_plant_library_path, :m_p25_gplp
      alias_method :notify_library_changed, :m_p25_nlc
    end

  end
end