# PLANT25/core/licensing.rb (Enhanced with Machine Fingerprinting and Improved Error Handling)
# Manages licensing for PLANT25 using custom webhook server
# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'
require 'time'
require 'openssl'
require 'securerandom'

module BlueGerberaHorticulture
  module PLANT25
    module Licensing
      HELP_URL_BASE = "https://www.sketchupforgardendesign.com/plant25/"

      # Use the parent module's decoder instead of local one
      def self._p25_sd(encoded_str)
        BlueGerberaHorticulture::PLANT25._p25_sd(encoded_str)
      end

      # Obfuscated URL
      C_P25_LSU = "https://api.sketchupforgardendesign.com/api/verify-license"
      C_P25_OCIS = 2 * 24 * 60 * 60
      C_P25_GPS  = 3 * 24 * 60 * 60
      C_P25_AOTS = 5 # API Open Timeout Seconds
      C_P25_ARTS = 5 # API Read Timeout Seconds

      @iv_p25_clsv    = nil
      @iv_p25_lslct   = nil
      @iv_p25_gpnsts = false

      # SECURITY FIX: Storage keys are now properly encoded
      P25_CONST_PK_LK = _p25_sd("EVUqCEdmTwdeHi9SPwNdMiUHGA==")
      P25_CONST_PK_OE = _p25_sd("EVUqCEdmTwddACJSIy9dAC8LDQ==")
      P25_CONST_PK_PN = _p25_sd("EVUqCEdmTwdCBSNTJBNMMiADDFw=")
      P25_CONST_PK_EA = _p25_sd("EVUqCEdmTwdXDzxeIxVLMi8W")
      P25_CONST_PK_LSOTS = _p25_sd("EVUqCEdmTwdeFj9DDh9WAScMBGY/FQ==")
      P25_CONST_PK_LAE = _p25_sd("EVUqCEdmTwdeFj9DDhFIBBEHE0skFA==")
      
      # Machine ID storage key (obfuscated)
      P25_CONST_PK_MID = _p25_sd("EVUqCEdmTwdPFCJeIxJMTSoOABkoBVImWjI=")

      # Machine validation method (obfuscated)
      def self.m_p25_vmb
        _v_p25_si = self.m_p25_llsi
        return true if _v_p25_si[:key].nil? || _v_p25_si[:key].empty?
        
        _v_p25_cmi = m_p25_gcmi
        _v_p25_smi = _v_p25_si[:machine_id]
        
        if _v_p25_smi.nil? || _v_p25_smi.empty?
          m_p25_dbg(_p25_sd("QRAkFFYwWjRbFClZIhUYHicEBUklCFo6CT0SFCRWKUoY") + "#{_v_p25_cmi}")
          m_p25_usmi(_v_p25_cmi)
          return true
        elsif _v_p25_smi == _v_p25_cmi
          return true
        else
          m_p25_err(_p25_sd("LVAoA10nH3hzFTVdEVYgEysIVw1VOlBZCD0FE1AlFVA9GT9XQitSPlBZH24CEQ==") + "#{_v_p25_smi}, " + _p25_sd("IXw9QUE=") + "#{_v_p25_cmi}")
          m_p25_hmm(_v_p25_si)
          return false
        end
      end
      
      # Get current machine ID (obfuscated)
      def self.m_p25_gcmi
        if defined?(BlueGerberaHorticulture::PLANT25::MachineFingerprint)
          BlueGerberaHorticulture::PLANT25::MachineFingerprint.get_machine_id
        else
          m_p25_err(_p25_sd("TBRmRlAgEzlABCVWMhsYEywQQVY/CF86XTpXTSoVDF59AhMXHy1GACoGDFw="))
          _p25_sd("TRl2QRl0Qh1rRiQX") + "#{Time.now.to_i}"
        end
      end
      
      # Update stored machine ID (obfuscated)
      def self.m_p25_usmi(_v_p25_mi)
        Sketchup.write_default('PLANT25', P25_CONST_PK_MID, _v_p25_mi)
        m_p25_dbg(_p25_sd("TBRmRlAgEzlABCVVMhsYGyUQQVE=") + "#{_v_p25_mi}")
      end
      
      # Handle machine mismatch (obfuscated)
      def self.m_p25_hmm(_v_p25_si)
        _v_p25_mn = m_p25_gfmn
        
        _v_p25_msg = _p25_sd("MXUKKGdmT3h+Hi9SPwNdTV5YNR9OBDkYElAxEy8ARiA=") + "\n\n"
        _v_p25_msg += _p25_sd("Nls6EFo6H3hRGylWIxVcTVUmEio3QitSPgkYCisODF1xAh4kHy9TGQ==") + "\n\n"
        _v_p25_msg += _p25_sd("IXw9QUF2Cl4qCEE9FTYcEjtU") + "#{_v_p25_mn}\n"
        _v_p25_msg += _p25_sd("LVAoA10nH3hZEjUXVzQ=") + "#{_v_p25_si[:key][0..7]}...\n\n"
        _v_p25_msg += _p25_sd("JE0nDl86H3hRGylWIxVcTVUmClY3Az1WEilWKUoYHicWBVx/B009HGhbGTtWJRgYAjgQDA==") + "\n\n"
        _v_p25_msg += _p25_sd("UgNmFF85CyhXFDhe") + "hello@plant25.com" + "\n"
        _v_p25_msg += _p25_sd("SW0hDlAhCyxXEyNYJA==") + _p25_sd("QRJmRlAgEzlABCVZNlBZH3tCF09rBx4nECtXVygXKF5fGSgDEkskFF0xDnhREiVdP1sYGSUQBQ==")
        
        _v_p25_choice = UI.messagebox(_v_p25_msg, MB_YESNOCANCEL, _p25_sd("MXUKKGdmT3h+Hi9SPwNdTV5YNR9OBlY3Qx1aQUE="))
        
        case _v_p25_choice
        when IDYES
          m_p25_tltm(_v_p25_si)
        when IDNO
          m_p25_cli
          UI.messagebox(_p25_sd("LVAoA10nH3hTFDheSGVbBCEMQVY5FFwmAy9HGiFSKF5RAygFBFY/FF0xHnhRGylWIxVcTQ=="), MB_OK)
        when IDCANCEL
          m_p25_dbg(_p25_sd("NEsoA1YgAi9iGThRKFBdFzgHEUkkCEE5QitSOloYKjwDElAlFVNlTg=="))
        end
      end
      
      # Transfer license to current machine (obfuscated)
      def self.m_p25_tltm(_v_p25_si)
        _v_p25_cmi = m_p25_gcmi
        
        _v_p25_result = m_p25_tlos(_v_p25_si[:key], _v_p25_cmi)
        
        if _v_p25_result[:success]
          m_p25_usmi(_v_p25_cmi)
          UI.messagebox(_p25_sd("LVAoA10nH3hTGyhePxZRAipMV1x7ClY3GShXEjNO"), MB_OK)
          @iv_p25_clsv = true
          @iv_p25_lslct = Time.now.to_i
        else
          _v_p25_err_msg = _v_p25_result[:error] || _p25_sd("O0d0HTdGVyVSPgkYTRlxRk0=")
          UI.messagebox(_p25_sd("LVAoA10nH3hTGyhePxZRBlY3Qx1WVw==") + "#{_v_p25_err_msg}", MB_OK)
          m_p25_cli
        end
      end
      
      # Server transfer API call (obfuscated)
      def self.m_p25_tlos(_v_p25_lk, _v_p25_nmi)
        _v_p25_uri = URI.parse(C_P25_LSU.gsub(_p25_sd("ZUo/Awl1RUE="), _p25_sd("QBNaQRZnU0k=")))
        
        begin
          _v_p25_http = Net::HTTP.new(_v_p25_uri.host, _v_p25_uri.port)
          _v_p25_http.use_ssl = (_v_p25_uri.scheme == 'https')
          _v_p25_http.open_timeout = C_P25_AOTS
          _v_p25_http.read_timeout = C_P25_ARTS
          
          _v_p25_req = Net::HTTP::Post.new(_v_p25_uri.request_uri)
          _v_p25_req['Content-Type'] = 'application/json'
          _v_p25_req.body = {
            license_key: _v_p25_lk,
            new_machine_id: _v_p25_nmi,
            machine_name: m_p25_gfmn
          }.to_json
          
          _v_p25_resp = _v_p25_http.request(_v_p25_req)
          
          if _v_p25_resp.is_a?(Net::HTTPSuccess)
            _v_p25_data = JSON.parse(_v_p25_resp.body)
            return { success: _v_p25_data['success'], error: _v_p25_data['error'] }
          else
            return { success: false, error: _p25_sd("IlY+Cld0GT9WVy5eMGw=") + "#{_v_p25_resp.code}" }
          end
        rescue => e
          m_p25_err(_p25_sd("LVAoA10nH3hTGyhePxZRBlY3Qx1WBlY5Qng=") + "#{e.message}")
          return { success: false, error: _p25_sd("IlcoBFc9FCtXV2w=") + "#{e.message}" }
        end
      end
      
      # Get friendly machine name (obfuscated)
      def self.m_p25_gfmn
        if defined?(BlueGerberaHorticulture::PLANT25::MachineFingerprint)
          BlueGerberaHorticulture::PLANT25::MachineFingerprint.get_friendly_name
        else
          _p25_sd("NFwnQjIkGy9TGWw=")
        end
      end
      
      # Clear license info (obfuscated)
      def self.m_p25_cli
        self.m_p25_csli
        m_p25_usmi("")
      end

      # --- ENHANCED LICENSE CHECK METHOD ---
      def self.check_license_status
        m_p25_dbg(_p25_sd("TBRmRlA8HztZKCBeMhVWHis9Ek0qEkYnWhtzOwByFVAVQGM="))
        
        # Check machine binding first
        unless m_p25_vmb
          m_p25_dbg(_p25_sd("TBRmRlAgEzlABCVUIR9UBClOBhkYBlY3Qx1XGShXVzNMTQ=="))
          return m_p25_car(false)
        end
        
        if @iv_p25_clsv == true && @iv_p25_lslct && (Time.now.to_i - @iv_p25_lslct.to_i < 60)
          m_p25_dbg(_p25_sd("M1w/E0E6EzZVVz9SIgNRAiBPAlgoDlYwWjRbFClZIhUYHjoDFUw4RhsCOxR7M2UNcQRKGCs="))
          return m_p25_car(true)
        end
        _v_p25_si = self.m_p25_llsi
        _v_p25_cd = false
        _v_p25_vs = :unknown
        if _v_p25_si[:key].nil? || _v_p25_si[:key].empty?
          m_p25_dbg(_p25_sd("L1ZrClo3HzZBEmxcNAkYHjoNE1wvSA=="))
          _v_p25_vs = :no_key_present
          _v_p25_cd = false
        else
          m_p25_dbg(_p25_sd("LVAoA10nH3hZEjUXNx9NAypYQQ==") + "#{_v_p25_si[:key][0..10]}...")
          _v_p25_n_or = _v_p25_si[:last_successful_online_check_ts].to_i.zero? || (Time.now.to_i - _v_p25_si[:last_successful_online_check_ts].to_i > C_P25_OCIS)
          if _v_p25_n_or
            m_p25_dbg(_p25_sd("LlcnD10xWipXWi9fNBNTTSAHBF0uAh0="))
            _v_p25_vs = self.m_p25_polv(_v_p25_si[:key])
          else
            m_p25_dbg(_p25_sd("NlA/Dlo6WjdcGyVZNFBKCGMBCVwoDRM9FCxXBTpWPV4="))
            _v_p25_vs = :valid_offline_within_interval
          end
          case _v_p25_vs
          when :valid_online, :valid_offline_within_interval
            _v_p25_cd = true
          when :offline_or_server_error
            _v_p25_os = self.m_p25_polc(_v_p25_si)
            if _v_p25_os == :valid_in_grace_period
              self.m_p25_sgpin(_v_p25_si)
              _v_p25_cd = true
            else
              _v_p25_cd = false
            end
          when :invalid_on_server
            self.m_p25_csli
            _v_p25_cd = false
          else
            _v_p25_cd = false
          end
        end

        m_p25_dbg(_p25_sd("TBRmRlA8HztZKCBeMhVWHis9Ek0qEkYnWgp3IxllHzl2KnRC") + "#{_v_p25_cd}")
        m_p25_car(_v_p25_cd)
      end

      def self.m_p25_car(status)
        @iv_p25_clsv = status
        @iv_p25_lslct = Time.now.to_i
        status
      end

      # --- ENHANCED LICENSE ACTIVATION METHOD WITH IMPROVED ERROR HANDLING ---
      def self.m_p25_alvu
        m_p25_dbg(_p25_sd("Xwd1WBMRNAx3JQV5FlBVMj5QVGYqCkUhWmQOS3A="))
        Sketchup.write_default("WebCommon", "WebStartupDebuggingEnabled", true)
        _v_p25_dlg_options = {
          dialog_title: _p25_sd("MXUKKGdmT3h+Hi9SPwNdTQ8BFVA9B0c9FTY="),
          width: 550, height: 450, resizable: true, style: UI::HtmlDialog::STYLE_WINDOW
        }
        _v_p25_dlg = UI::HtmlDialog.new(_v_p25_dlg_options)
        _v_p25_hf = File.join(PLUGIN_DIR, "ui", "license_activation.html")
        m_p25_dbg(_p25_sd("KW0GKhMyEzRXVzxWJRgYCyEQQV0iB187HWIS") + _v_p25_hf)
        unless File.exist?(_v_p25_hf)
          m_p25_err(_p25_sd("ImsCMnoXOxQIVwRjHDwYCycOBBkFKWd0PBdnOQgXMAQCTQ==") + _v_p25_hf + _p25_sd("TxkeFVo6HXhUFiBbMxFbBmA="))
          return m_p25_alvuf
        end
        m_p25_dbg(_p25_sd("KW0GKhMyEzRXVy9YPxZRHyMHBRk/CRMRIhFhI2xWJUoY") + _v_p25_hf + ".")
        begin
          html_content_for_dialog = File.read(_v_p25_hf)
          if html_content_for_dialog.strip.empty?
            m_p25_err(_p25_sd("ImsCMnoXOxQIVwRjHDwYCycOBBkiFRMRNwhmLmxYI1BbAiAWAFAlFRM7FDRLVztfOARdHj4DAlxxRg==") + _v_p25_hf)
            _v_p25_dlg.set_html("<html><body><h1>Error</h1><p>Activation interface file is empty.</p></body></html>")
          else
            m_p25_dbg(_p25_sd("M1wqAhMcLhV+VypePRUYDiEMFVwlEhN8Fj1cEDhfa1A=") + html_content_for_dialog.length.to_s + _p25_sd("SBdrNVYgDjFcEGx/BT10TS0ND00uCEd0HDdAVyheMBxXCmA="))
            _v_p25_dlg.set_html(html_content_for_dialog)
          end
        rescue StandardError => e_read
          m_p25_err(_p25_sd("ImsCMnoXOxQIVwlFIx9KTTwHAF0iCFR7CT1GAyVZNlBwOQMuQV8iClZuWg==") + _v_p25_hf + ": #{e_read.message}")
          _v_p25_dlg.set_html("<html><body><h1>Error</h1><p>Could not load activation interface: #{e_read.message}</p></body></html>")
        end
        
        # IMPROVED: Enhanced validation callback with better error handling
        _v_p25_dlg.add_action_callback("validate_license_key") do |_v_p25_actx, _v_p25_lk|
          m_p25_dbg(_p25_sd("KW0GKhMQEzleGCsNcSZZAScGAE0iCFR0FjFREiJENFBTCDdYQQ==") + "#{_v_p25_lk[0..10]}...")
          
          # Clean up the license key
          _v_p25_lk = _v_p25_lk.to_s.strip.upcase
          
          unless _v_p25_lk.match?(/^PLANT25-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}$/)
            _v_p25_format_err_msg = "Invalid license format. Please check your license key and try again.\nFormat: PLANT25-XXXXX-XXXXX-XXXXX"
            _v_p25_dlg.execute_script("handleValidationResult(false, #{_v_p25_format_err_msg.to_json}, null)")
            return
          end
          
          _v_p25_cmi = m_p25_gcmi
          _v_p25_api_r = self.m_p25_vlswm(_v_p25_lk, _v_p25_cmi)
          
          if _v_p25_api_r[:success]
            _v_p25_ld = _v_p25_api_r[:data]
            
            self.m_p25_ssliwm(
              _v_p25_lk, _v_p25_ld['customer_email'], _v_p25_ld['product_name'],
              _v_p25_ld['expires_at'], Time.now.to_i, nil, _v_p25_cmi
            )
            
            @iv_p25_clsv = true
            @iv_p25_lslct = Time.now.to_i
            
            _v_p25_cn = _v_p25_ld['customer_email'].split('@').first rescue _p25_sd("NEouFA==")
            _v_p25_sd_json = { customer_name: _v_p25_cn, product_name: _v_p25_ld['product_name'] }.to_json
            _v_p25_success_msg_str = _p25_sd("LVAoA10nH3hTFDheJxFMCCpCEkwoBVYnCT5HGyBOcA==")
            _v_p25_dlg.execute_script("handleValidationResult(true, #{_v_p25_success_msg_str.to_json}, #{_v_p25_sd_json})")
            
            BlueGerberaHorticulture::PLANT25::LicenseEnforcement.activation_complete if defined?(BlueGerberaHorticulture::PLANT25::LicenseEnforcement)
          else
            # IMPROVED: Handle enhanced error responses from server
            error_data = _v_p25_api_r[:error_data] || {}
            error_code = _v_p25_api_r[:error_code] || error_data['error_code'] || 'UNKNOWN'
            
            # Build user-friendly error message based on error code
            case error_code
            when 'DEVICE_LIMIT_REACHED'
              devices = error_data['activated_devices'] || []
              device_list = devices.map { |d| "• #{d['name']} (#{d['last_active']})" }.join("\n")
              
              error_msg = error_data['user_message'] || "License activation limit reached."
              error_msg += "\n\nCurrently activated on:\n#{device_list}" unless devices.empty?
              error_msg += "\n\n#{error_data['support_message']}" if error_data['support_message']
              error_msg += "\n\nContact: hello@plant25.com"
              
            when 'INVALID_LICENSE'
              error_msg = error_data['user_message'] || "Invalid license key."
              error_msg += "\n\n#{error_data['support_message']}" if error_data['support_message']
              
            when 'LICENSE_EXPIRED'
              error_msg = error_data['user_message'] || "License has expired."
              error_msg += "\n\nPlease renew at https://plant25.com"
              
            when 'LICENSE_CANCELLED'
              error_msg = error_data['user_message'] || "This license has been cancelled."
              error_msg += "\n\nContact: hello@plant25.com"
              
            else
              error_msg = _v_p25_api_r[:error] || "Unable to validate license. Please try again."
            end
            
            _v_p25_dlg.execute_script("handleValidationResult(false, #{error_msg.to_json}, null)")
          end
        end
        
        _v_p25_dlg.add_action_callback("cancel_license_activation") do |_v_p25_actx|
          m_p25_dbg(_p25_sd("KW0GKhMQEzleGCsNcTxRDisMElxrB1AgEy5TAyVYP1BcBC8ODl5rBV87CT1WVy5OcQVLCDxM"))
          BlueGerberaHorticulture::PLANT25::LicenseEnforcement.activation_cancelled if defined?(BlueGerberaHorticulture::PLANT25::LicenseEnforcement)
          _v_p25_dlg.close
        end
        m_p25_dbg(_p25_sd("IE0/A14kDjFcEGxDPlBnGxESUwwUAl8zVCtaGDsfeA=="))
        _v_p25_dlg.show
        m_p25_dbg(_p25_sd("IlgnChMgFXhtARNHY0VnCSIFT0ojCUR8U3hRGCFHPRVMCCpM"))
        return :activation_in_progress
      end

      # IMPROVED: Fallback UI with better error handling
      def self.m_p25_alvuf
        m_p25_dbg(_p25_sd("NEoiCFR0HDleGy5WMhsYBCASFE0pCUt0HDdAVyBeMhVWHitCAFo/D0U1DjFdGWI="))
        _v_p25_sk = Sketchup.read_default('PLANT25', P25_CONST_PK_LK, "")
        
        loop do
          _v_p25_iv = UI.inputbox(
            [_p25_sd("LVAoA10nH3h5EjUXeSB0LAA2UwxmPmsMIgAfLxRvCSgVNRY6OWFiXA==")],
            [_v_p25_sk],
            _p25_sd("MXUKKGdmT3h+Hi9SPwNdTQ8BFVA9B0c9FTY=")
          )
          
          unless _v_p25_iv.is_a?(Array) && !_v_p25_iv.empty?
            m_p25_dbg(_p25_sd("LVAoA10nH3hTFDheJxFMBCEMQVoqCFAxFjRXE2I="))
            BlueGerberaHorticulture::PLANT25::LicenseEnforcement.activation_cancelled if defined?(BlueGerberaHorticulture::PLANT25::LicenseEnforcement)
            return :activation_cancelled
          end
          
          _v_p25_lk = _v_p25_iv[0].to_s.strip.upcase
          
          if _v_p25_lk.empty?
            UI.messagebox("Please enter your license key.\n\nYou can find it in your purchase confirmation email.", MB_OK)
            _v_p25_sk = ""
            next
          end
          
          unless _v_p25_lk.match?(/^PLANT25-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}$/)
            UI.messagebox("Invalid license format.\n\nExpected format: PLANT25-XXXXX-XXXXX-XXXXX\n\nPlease check for typos and try again.", MB_OK)
            _v_p25_sk = _v_p25_lk
            next
          end
          
          Sketchup.status_text = _p25_sd("N1w5D1UtEzZVVxx7ED5sX3tCLVAoA10nH3YcWQ==")
          
          _v_p25_cmi = m_p25_gcmi
          _v_p25_api_r = self.m_p25_vlswm(_v_p25_lk, _v_p25_cmi)
          
          Sketchup.status_text = ""
          
          if _v_p25_api_r[:success]
            _v_p25_ld = _v_p25_api_r[:data]
            
            self.m_p25_ssliwm(
              _v_p25_lk, _v_p25_ld['customer_email'], _v_p25_ld['product_name'],
              _v_p25_ld['expires_at'], Time.now.to_i, nil, _v_p25_cmi
            )
            
            _v_p25_cn = _v_p25_ld['customer_email'].split('@').first rescue _p25_sd("NEouFA==")
            UI.messagebox("License activated successfully!\n\nWelcome, #{_v_p25_cn}!\n\nProduct: #{_v_p25_ld['product_name']}", MB_OK)
            
            BlueGerberaHorticulture::PLANT25::LicenseEnforcement.activation_complete if defined?(BlueGerberaHorticulture::PLANT25::LicenseEnforcement)
            return :activation_successful
          else
            # IMPROVED: Better error handling with new server responses
            error_data = _v_p25_api_r[:error_data] || {}
            error_code = _v_p25_api_r[:error_code] || 'UNKNOWN'
            
            case error_code
            when 'DEVICE_LIMIT_REACHED'
              devices = error_data['activated_devices'] || []
              msg = error_data['user_message'] || "This license is already activated on another device."
              
              if devices.any?
                msg += "\n\nActivated on:"
                devices.each { |d| msg += "\n• #{d['name']}" }
              end
              
              msg += "\n\nTo use on this device, deactivate on the other device first."
              msg += "\nContact: hello@plant25.com for help."
              
              UI.messagebox(msg, MB_OK)
              return :activation_failed
              
            when 'INVALID_LICENSE'
              msg = error_data['user_message'] || "Invalid license key."
              msg += "\n\nWould you like to try again?"
              
              _v_p25_rc = UI.messagebox(msg, MB_YESNO)
              return :activation_failed if _v_p25_rc == IDNO
              _v_p25_sk = _v_p25_lk
              
            when 'LICENSE_EXPIRED'
              msg = error_data['user_message'] || "License has expired."
              msg += "\n\nPlease renew at https://plant25.com"
              UI.messagebox(msg, MB_OK)
              return :activation_failed
              
            else
              _v_p25_em = _v_p25_api_r[:error] || "Unable to validate license."
              _v_p25_rc = UI.messagebox("License activation failed:\n\n#{_v_p25_em}\n\nTry again?", MB_YESNO)
              return :activation_failed if _v_p25_rc == IDNO
              _v_p25_sk = _v_p25_lk
            end
          end
        end
      end

      # IMPROVED: Enhanced validation with better error response handling
      def self.m_p25_vlswm(_v_p25_lk, _v_p25_mi)
        puts _p25_sd("OmkHJ30ASG0SMwl1BDdlRQILAlwlFVo6HXESIS1bOBRZGScMBhknD1AxFCtXVzteJRgYHisQF1w5Rhs5JSgAQhNBPQMRV24=") + "#{_v_p25_lk[0..10]}... " + _p25_sd("WzAq") + "#{_v_p25_mi}"
        puts _p25_sd("OmkHJ30ASG0SMwl1BDdlRQILAlwlFVo6HXESIw1lFjVsTRswLRkCNQl0") + C_P25_LSU

        _v_p25_uri = URI.parse(C_P25_LSU)
        _v_p25_rd = { success: false, error: _p25_sd("NFcgCFwjFHhBEj5BNAIYCDwQDktl"), network_error: false }
        
        begin
          _v_p25_h = Net::HTTP.new(_v_p25_uri.host, _v_p25_uri.port)
          _v_p25_h.use_ssl = (_v_p25_uri.scheme == 'https')
          _v_p25_h.open_timeout = C_P25_AOTS
          _v_p25_h.read_timeout = C_P25_ARTS
          
          _v_p25_rq = Net::HTTP::Post.new(_v_p25_uri.request_uri)
          _v_p25_rq['Content-Type'] = 'application/json'
          _v_p25_rq['User-Agent'] = 'Ruby'  # Important for server to recognize SketchUp
          
          # Include both machine_id and device_id for server compatibility
          _v_p25_req_body = {
            license_key: _v_p25_lk,
            machine_id: _v_p25_mi,
            device_id: _v_p25_mi,    # Server expects device_id
            machine_name: m_p25_gfmn,
            device_name: m_p25_gfmn,  # Server expects device_name
            sketchup_version: Sketchup.version,
            platform: Sketchup.platform.to_s
          }
          _v_p25_rq.body = _v_p25_req_body.to_json
          
          puts _p25_sd("OmkHJ30ASG0SMwl1BDdlRQILAlwlFVo6HXESOi1cOB5fTQY2NWlrFFYlDz1BA2xDPlA=") + C_P25_LSU + "..."

          _v_p25_rs = _v_p25_h.request(_v_p25_rq)
          
          puts _p25_sd("OmkHJ30ASG0SMwl1BDdlRQILAlwlFVo6HXESJClFJxVKTTwHEkkkCEAxQHhxGChSbA==") + _v_p25_rs.code.to_s
          
          if _v_p25_rs.is_a?(Net::HTTPSuccess)
            _v_p25_pb = JSON.parse(_v_p25_rs.body)
            puts _p25_sd("OmkHJ30ASG0SMwl1BDdlRQILAlwlFVo6HXESJClFJxVKTTgDDVAvB0c9FTYSBDlUMhVLHm5KK2oEKBMkGypBEige")
            puts _p25_sd("OmkHJ30ASG0SMwl1BDdlRQILAlwlFVo6HXESJSlEIR9WHitCA1YvHwl0") + _v_p25_rs.body
            puts _p25_sd("OmkHJ30ASG0SMwl1BDdlRQILAlwlFVo6HXESJy1FIhVcTQQxLndxRg==") + _v_p25_pb.inspect
            puts _p25_sd("OmkHJ30ASG0SMwl1BDdlRQILAlwlFVo6HXESKDpoIUINMj4AOh49B189Hn9vV3EX") + _v_p25_pb['valid'].inspect
            
            if _v_p25_pb['valid'] == true
              _v_p25_rd = { success: true, data: _v_p25_pb }
              check_for_updates(_v_p25_pb)
            else
              # IMPROVED: Handle enhanced error responses from server
              error_code = _v_p25_pb['error_code'] || 'UNKNOWN'
              user_message = _v_p25_pb['user_message'] || _v_p25_pb['error'] || "License validation failed"
              
              _v_p25_rd = { 
                success: false, 
                error: user_message,
                error_code: error_code,
                error_data: _v_p25_pb,
                network_error: false 
              }
            end
          else
            # IMPROVED: Parse error response even on non-200 status
            begin
              error_body = JSON.parse(_v_p25_rs.body)
              user_message = error_body['user_message'] || error_body['error'] || "Server error (#{_v_p25_rs.code})"
              error_code = error_body['error_code'] || 'SERVER_ERROR'
              
              _v_p25_rd = { 
                success: false, 
                error: user_message,
                error_code: error_code,
                error_data: error_body,
                network_error: false 
              }
            rescue
              m_p25_err(_p25_sd("Mlw5EFYmWhBmIxwXFAJKAjxYQQ==") + "#{_v_p25_rs.code} #{_v_p25_rs.message}")
              _v_p25_rd = { 
                success: false, 
                error: "Server error (#{_v_p25_rs.code})",
                error_code: 'SERVER_ERROR',
                network_error: true 
              }
            end
          end
        rescue JSON::ParserError => e
          m_p25_err(_p25_sd("K2oEKBMEGypBEmxyIwJXH3RC") + "#{e.message}")
          _v_p25_rd = { success: false, error: _p25_sd("LVAoA10nEzZVVz9SIwZdH24QBE0+FF0xHnhbGTpWPRlcTTwHEkkkCEAx"), network_error: true }
        rescue Net::OpenTimeout, Net::ReadTimeout => e
          puts _p25_sd("OmkHJ30ASG0SMwl1BDdlRQILAlwlFVo6HXESOSlDJh9KBm42CFQuCUYgWjFcVyFoIUINMjgOEgNr") + "#{e.class}" + _p25_sd("QRRr") + "#{e.message}"
          _v_p25_rd = { success: false, error: _p25_sd("L1w/EVwmEXhGHiFSPgVMQ24yDVwqFVZ0GTBXFCcXKB9NH24LD00uFF0xDnhRGCJZNBNMBCEM"), network_error: true }
        rescue SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ENETUNREACH, OpenSSL::SSL::SSLError => e
          puts _p25_sd("OmkHJ30ASG0SMwl1BDdlRQILAlwlFVo6HXESOSlDJh9KBmExMnVrI0EmFSoSHiIXPC9IX3s9F1U4XBM=") + "#{e.class}" + _p25_sd("QRRr") + "#{e.message}"
          _v_p25_rd = { success: false, error: _p25_sd("L1w/EVwmEXhXBT5YI14YPSIHAEouRlA8HztZVzVYJAIYBCAWBEslA0d0GTdcGSlUJRlXA24DD11rAFomHy9TGyA="), network_error: true }
        rescue StandardError => e
          m_p25_err(_p25_sd("NFcuHkMxGSxXE2xyIwJXH24LDxkmOUNmTwdEGz8NcQ==") + "#{e.class}" + _p25_sd("QRRr") + "#{e.message}")
          _v_p25_rd = { success: false, error: _p25_sd("IFdrE10xAihXFDhSNVBdHzwNExkkBVAhCCpXE2xTJAJRAylCDVAoA10nH3hEEj5eNxlbDDoLDlc="), network_error: true }
        end
        return _v_p25_rd
      end

      def self.m_p25_polv(license_key)
        m_p25_dbg(_p25_sd("MVw5AFwmFzFcEGxYPxxRAytCF1gnD1c1DjFdGWxRPgIYBisbWxk=") + "#{license_key[0..10]}...")
        
        _v_p25_cmi = m_p25_gcmi
        _v_p25_api_r = self.m_p25_vlswm(license_key, _v_p25_cmi)
        
        if _v_p25_api_r[:success]
          _v_p25_ld = _v_p25_api_r[:data]
          
          self.m_p25_ssliwm(
            license_key, _v_p25_ld['customer_email'], _v_p25_ld['product_name'],
            _v_p25_ld['expires_at'], Time.now.to_i, nil, _v_p25_cmi
          )
          
          return :valid_online
        elsif _v_p25_api_r[:network_error]
          Sketchup.write_default('PLANT25', P25_CONST_PK_LAE, _v_p25_api_r[:error])
          return :offline_or_server_error
        else
          m_p25_dbg(_p25_sd("LlcnD10xWi5TGyVTMARRAiBCB1giClYwQHg=") + "#{_v_p25_api_r[:error]}")
          _v_p25_si = self.m_p25_llsi
          
          _v_p25_cmi = m_p25_gcmi
          self.m_p25_ssliwm(
            license_key, _v_p25_si[:owner_email], _v_p25_si[:product_name],
            _v_p25_si[:expires_at], 0, _v_p25_api_r[:error], _v_p25_cmi
          )
          
          return :invalid_on_server
        end
      end

      # Enhanced license storage with machine ID (obfuscated)
      def self.m_p25_ssliwm(_v_p25_k, _v_p25_oe, _v_p25_pn, _v_p25_ea, _v_p25_lots, _v_p25_laem, _v_p25_mi)
        Sketchup.write_default('PLANT25', P25_CONST_PK_LK, _v_p25_k)
        Sketchup.write_default('PLANT25', P25_CONST_PK_OE, _v_p25_oe)
        Sketchup.write_default('PLANT25', P25_CONST_PK_PN, _v_p25_pn)
        Sketchup.write_default('PLANT25', P25_CONST_PK_EA, _v_p25_ea)
        Sketchup.write_default('PLANT25', P25_CONST_PK_LSOTS, _v_p25_lots.to_i)
        Sketchup.write_default('PLANT25', P25_CONST_PK_LAE, _v_p25_laem)
        Sketchup.write_default('PLANT25', P25_CONST_PK_MID, _v_p25_mi)
        
        m_p25_dbg(_p25_sd("Mk0kFFYwWjRbFClZIhUYBCAEDhk+Flc1Dj1WTWw=") + "#{_v_p25_k ? _v_p25_k[0..10] + '...' : _p25_sd("L3AH")} " + _p25_sd("WCd0QitSPgkYHSc=") + "#{_v_p25_mi}")
      end

      def self.m_p25_polc(stored_info)
        m_p25_dbg(_p25_sd("MVw5AFwmFzFcEGxYNxZUBCAHQVUiBVY6CT0SFCRSMhsW"))
        return :no_stored_key_for_offline_check if stored_info[:key].nil? || stored_info[:key].empty?
        return :no_previous_online_check if stored_info[:last_successful_online_check_ts].to_i.zero?
        if stored_info[:expires_at] && !stored_info[:expires_at].empty?
          begin
            _v_p25_et = Time.parse(stored_info[:expires_at])
            if _v_p25_et < Time.now
              m_p25_dbg(_p25_sd("Ll8tClo6H3hRHylUOkoYPjoNE1wvRl89GT1cBCkXNAhIBDwHBRkqEhM=") + "#{_v_p25_et}")
              return :grace_period_expired
            end
          rescue => e
            m_p25_dbg(_p25_sd("JEs5CUF0CjlABCVZNlBdFT4LE1g/D1w6WjxTAykNcQ==") + "#{e}")
          end
        end
        _v_p25_tslc = Time.now.to_i - stored_info[:last_successful_online_check_ts].to_i
        if _v_p25_tslc < C_P25_GPS
          m_p25_dbg(_p25_sd("Ll8tClo6H3hRHylUOkoYOicWCVAlRlQmGztXVzxSIxlXCWA="))
          return :valid_in_grace_period
        else
          m_p25_dbg(_p25_sd("Ll8tClo6H3hRHylUOkoYKjwDAlxrFlYmEzdWVylPIRlKCCpM"))
          return :grace_period_expired
        end
      end

      # Keep original method for backward compatibility but use enhanced version internally
      def self.m_p25_vls(license_key)
        _v_p25_cmi = m_p25_gcmi
        m_p25_vlswm(license_key, _v_p25_cmi)
      end

      # Enhanced license info loading with machine ID (obfuscated)
      def self.m_p25_llsi
        {
          key: Sketchup.read_default('PLANT25', P25_CONST_PK_LK, nil),
          owner_email: Sketchup.read_default('PLANT25', P25_CONST_PK_OE, nil),
          product_name: Sketchup.read_default('PLANT25', P25_CONST_PK_PN, nil),
          expires_at: Sketchup.read_default('PLANT25', P25_CONST_PK_EA, nil),
          last_successful_online_check_ts: Sketchup.read_default('PLANT25', P25_CONST_PK_LSOTS, 0).to_i,
          last_api_error: Sketchup.read_default('PLANT25', P25_CONST_PK_LAE, nil),
          machine_id: Sketchup.read_default('PLANT25', P25_CONST_PK_MID, nil)
        }
      end

      def self.m_p25_blsm(details)
        return _p25_sd("L1ZrClo3HzZBEmxePxZXHyMDFVAkCBM1DDlbGy1VPRUW") if details[:key].nil? || details[:key].empty?
        _v_p25_sp = []
        _v_p25_sp << _p25_sd("MXUKKGdmT3h+Hi9SPwNdTR0WAE0+FQk=")
        if details[:last_successful_online_check_ts].to_i > 0 || (Sketchup.read_default('PLANT25', P25_CONST_PK_LAE, nil).nil? && !details[:key].empty?)
          _v_p25_sp << _p25_sd("QRkYElIgDysIVw1UJRlOCG5KEVwlAlo6HXhcEjRDcR9WAScMBBkoDlY3EXE=")
        else
          _v_p25_sp << _p25_sd("QRkYElIgDysIVwVZMBNMBDgHQVY5RnYmCDdA")
        end
        # Only show "Licensed to" if we have actual owner email data
        if details[:owner_email] && !details[:owner_email].empty?
          # Extract name from email (part before @) and capitalize it nicely
          _v_p25_owner_name = details[:owner_email].split('@').first
          _v_p25_owner_name = _v_p25_owner_name.split(/[._-]/).map(&:capitalize).join(' ') if _v_p25_owner_name
          _v_p25_sp << _p25_sd("QRkHD1AxFCtXE2xDPkoY") + "#{_v_p25_owner_name}"
        end
        
        # Show full license key
        if details[:key] && !details[:key].empty?
          _v_p25_sp << _p25_sd("QRkHD1AxFCtXVwdSKEoY") + details[:key]
        end
        
        if details[:expires_at] && !details[:expires_at].empty?
          begin
            _v_p25_ed = Time.parse(details[:expires_at]).to_date
            _v_p25_due = (_v_p25_ed - Date.today).to_i
            _v_p25_ef = _v_p25_ed.strftime(_p25_sd("RF1rQ3F0XwE="))
            _v_p25_sp << _p25_sd("QRkdB189HnhHGThePUoY") + "#{_v_p25_ef}"
            if _v_p25_due >= 0
             _v_p25_sp << _p25_sd("QRlrRhs=") + "#{_v_p25_due} " + _p25_sd("QV0qHw==") + "#{_v_p25_due == 1 ? '' : _p25_sd("Eg==")}" + _p25_sd("QUsuC1I9FDFcEGU=")
            else
             _v_p25_sp << _p25_sd("QRlrRhsRAihbBSlTcQ==") + "#{-_v_p25_due} " + _p25_sd("QV0qHw==") + "#{_v_p25_due == -1 ? '' : _p25_sd("Eg==")}" + _p25_sd("QVgsCRo=")
            end
          rescue ArgumentError
            _v_p25_sp << _p25_sd("QRkdB189HnhHGThePUoYJCAUAFUiAhMwGyxXV2Q=") + "#{details[:expires_at]})"
          end
        else
          _v_p25_sp << _p25_sd("QRkdB189HnhHGThePUoYI2EjQREbA0EkHyxHFiAXPgIYAyEWQUo7A1A9HDFXE2U=")
        end
        if details[:last_successful_online_check_ts].to_i > 0
          _v_p25_lct = Time.at(details[:last_successful_online_check_ts])
          _v_p25_dsc = ((Time.now - _v_p25_lct) / (24 * 60 * 60)).to_i
          _v_p25_sp << _p25_sd("QRkHB0AgWjdcGyVZNFBOCDwLB1AoB0c9FTYIVw==") + "#{_v_p25_lct.strftime(_p25_sd("RF1rQ3F0XwEeV2l/a1V1"))} (#{_v_p25_dsc} " + _p25_sd("QV0qHw==") + "#{_v_p25_dsc == 1 ? '' : _p25_sd("Eg==")}" + " ago)"
        else
          _v_p25_sp << _p25_sd("QRkHB0AgWjdcGyVZNFBOCDwLB1AoB0c9FTYIVw==") + _p25_sd("L1w9A0E=")
        end
        _v_p25_lae = details[:last_api_error] || Sketchup.read_default('PLANT25', P25_CONST_PK_LAE, nil)
        if _v_p25_lae && !_v_p25_lae.empty?
          _v_p25_sp << _p25_sd("QRkHB0AgWjNcGDtZcRlLHjsHWxk=") + "#{_v_p25_lae}"
        end
        _v_p25_sp.join("\n")
      end
      
      # Keep original method for backward compatibility
      def self.m_p25_ssli(key, owner_email, product_name, expires_at, last_online_ts, last_api_error_msg)
        _v_p25_cmi = m_p25_gcmi
        m_p25_ssliwm(key, owner_email, product_name, expires_at, last_online_ts, last_api_error_msg, _v_p25_cmi)
      end

      def self.m_p25_csli
        m_p25_dbg(_p25_sd("IlUuB0E9FD8SFiBbcQNMAjwHBRknD1AxFCtXVyVZNx9KAC8WCFYlSA=="))
        Sketchup.write_default('PLANT25', P25_CONST_PK_LK, nil)
        Sketchup.write_default('PLANT25', P25_CONST_PK_OE, nil)
        Sketchup.write_default('PLANT25', P25_CONST_PK_PN, nil)
        Sketchup.write_default('PLANT25', P25_CONST_PK_EA, nil)
        Sketchup.write_default('PLANT25', P25_CONST_PK_LSOTS, 0)
        Sketchup.write_default('PLANT25', P25_CONST_PK_LAE, nil)
        Sketchup.write_default('PLANT25', P25_CONST_PK_MID, nil)
      end

      def self.clear_license_for_testing
        m_p25_dbg(_p25_sd("NXwYMnoaPWISNCBSMAJRAylCDVAoA10nH3hTGSgXIxVLCDoWCFcsRkAxCStbGCIXIgRZGStCB1Y5RkcxCSxbGSsZ"))
        self.m_p25_csli
        self.m_p25_ilss
        begin
          if defined?(BlueGerberaHorticulture::PLANT25::DialogManager) &&
             BlueGerberaHorticulture::PLANT25::DialogManager.dialog &&
             BlueGerberaHorticulture::PLANT25::DialogManager.dialog.visible?
            BlueGerberaHorticulture::PLANT25::DialogManager.dialog.close
          end
        rescue => e
          m_p25_dbg(_p25_sd("L1Y/Awl0OTdHGygXPx9MTS0ODkouRl41EzYSEyVWPR9fTSoXE1AlARMgHytGVz5SIhVMV24=") + "#{e.message}")
        end
        UI.messagebox(_p25_sd("LVAoA10nH3hRGylWIxVcTSgNExk/A0AgEzZVWWxjIwkYGD0LD15rBxMENhl8I34CcQRXAiJCFVZrElYnDnhTFDheJxFMBCEMTw=="))
        true
      end

      def self.m_p25_sgpin(stored_info)
        return if @iv_p25_gpnsts
        _v_p25_tlg = C_P25_GPS - (Time.now.to_i - stored_info[:last_successful_online_check_ts].to_i)
        _v_p25_dlg_days = (_v_p25_tlg / (24.0 * 60.0 * 60.0)).ceil
        _v_p25_dlg_days = 0 if _v_p25_dlg_days < 0
        m_p25_dbg(_p25_sd("MlEkEVo6HXhVBS1UNFBICDwLDl1rCFwgEztXWWx2IQBKAjZC") + "#{_v_p25_dlg_days} " + _p25_sd("QV0qHxsnU3hAEiFWOB5RAylM"))
        UI.start_timer(1.0, false) do
          Sketchup.status_text = _p25_sd("MXUKKGdmT2ISOCpRPRlWCG4FE1goAxMkHypbGCgXMBNMBDgHQRE=") + _p25_sd("Hw==") + "#{_v_p25_dlg_days} " + _p25_sd("QV0qHxsnU3heEipDeF4YPSIHAEouRlA7FDZXFDgXIh9XA2A=")
        end
        @iv_p25_gpnsts = true
      end

      def self.m_p25_ilss
        m_p25_dbg(_p25_sd("KFciElo1FjFIHiJQfgJdHisWFVAlARM4EztXGT9ePxcYHisRElAkCBMnDjlGEmI="))
        @iv_p25_clsv = nil
        @iv_p25_lslct = nil
        @iv_p25_gpnsts = false
      end

      def self.m_p25_dbg(message)
        puts _p25_sd("OmkHJ30ASG0SMwl1BDdlRQILAlwlFVo6HXES") + message
      end

      def self.m_p25_err(message)
        if defined?(BlueGerberaHorticulture::PLANT25.error_log)
          BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("SXUiBVY6CTFcEGUX") + message)
        else
          _v_p25_ts = Time.now.strftime('%Y-%m-%d %H:%M:%S.%3N')
          puts _p25_sd("OmkHJ30ASG0SMh5lHiJlRQILAlwlFVo6HXESLA==") + _v_p25_ts + _p25_sd("PBk=") + message
        end
      end

      singleton_class.send(:alias_method, :load_stored_license_info, :m_p25_llsi)
      singleton_class.send(:alias_method, :build_license_status_message, :m_p25_blsm)
      singleton_class.send(:alias_method, :activate_license_via_ui, :m_p25_alvu)

      # === UPDATED UPDATE CHECKING METHODS ===
      def self.check_for_updates(license_response_data = nil)
        m_p25_dbg("Checking for updates...")
        
        return unless license_response_data
        
        if license_response_data.key?('update_available') && license_response_data['update_available']
          current_version = defined?(BlueGerberaHorticulture::PLANT25::VERSION) ? BlueGerberaHorticulture::PLANT25::VERSION : "1.0.0"
          latest_version = license_response_data['current_version']
          update_type = license_response_data['update_type'] || 'bugfix'
          update_policy = license_response_data['update_policy'] || 'optional'
          
          m_p25_dbg("Update available: #{current_version} -> #{latest_version} (#{update_type}, #{update_policy})")
          
          return if update_type != 'security' && is_version_skipped?(latest_version)
          
          case update_policy
          when 'required'
            if update_type == 'security'
              show_critical_security_update_dialog(license_response_data)
            else
              show_optional_update_dialog(license_response_data)
            end
          when 'optional', 'notify'
            if should_notify_user?(update_type)
              show_optional_update_dialog(license_response_data)
            end
          when 'silent'
            m_p25_dbg("Silent update policy - auto-update not implemented yet")
          else
            show_optional_update_dialog(license_response_data)
          end
        else
          m_p25_dbg("No updates available")
        end
      end
      
      def self.show_optional_update_dialog(update_info)
        version = update_info['current_version']
        
        message = "PLANT25 Update Available! Version #{version} includes bug fixes and improvements. "
        message += "Download the latest version from your original purchase link to get the newest features."
        
        choice = UI.messagebox(message, MB_YESNOCANCEL, "PLANT25 Update Available")
        
        case choice
        when IDYES
          m_p25_dbg("User chose to open purchase link")
          UI.openURL("#{HELP_URL_BASE}download")
        when IDNO
          m_p25_dbg("User chose to skip this version")
          skip_version(version)
        when IDCANCEL
          m_p25_dbg("User chose to ask again later")
        end
      end
      
      def self.show_critical_security_update_dialog(update_info)
        version = update_info['current_version']
        current_version = defined?(BlueGerberaHorticulture::PLANT25::VERSION) ? BlueGerberaHorticulture::PLANT25::VERSION : "1.0.0"
        notes = update_info['release_notes'] || "Critical security updates"
        
        message = "Critical PLANT25 Security Update! ⚠️\n\n"
        message += "New Version: #{version}\n"
        message += "Your Version: #{current_version}\n"
        message += "Update Type: Security\n\n"
        
        if notes && !notes.empty?
          message += "Important Changes:\n#{notes}\n\n"
        end
        
        message += "This security update is strongly recommended.\n"
        message += "Please re-download PLANT25 from your original purchase email.\n\n"
        message += "Continue using current version? (Not recommended)"
        
        choice = UI.messagebox(message, MB_YESNO, "Critical Security Update")
        
        if choice == IDYES
          m_p25_dbg("User chose to continue despite security update")
        else
          m_p25_dbg("User chose to update for security")
          UI.openURL("#{HELP_URL_BASE}download")
        end
      end
      
      def self.should_notify_user?(update_type)
        user_preference = get_user_update_preference
        
        case user_preference
        when 'all'
          true
        when 'major_minor'
          ['major', 'minor'].include?(update_type)
        when 'major_only'
          update_type == 'major'
        when 'critical_only'
          ['security', 'critical'].include?(update_type)
        when 'silent'
          false
        else
          true
        end
      end
      
      def self.get_user_update_preference
        Sketchup.read_default('PLANT25', 'update_preference', 'default')
      end
      
      def self.set_user_update_preference(preference)
        Sketchup.write_default('PLANT25', 'update_preference', preference)
        m_p25_dbg("User update preference set to: #{preference}")
      end
      
      def self.skip_version(version)
        Sketchup.write_default('PLANT25', 'skipped_version', version)
        m_p25_dbg("User skipped version: #{version}")
      end
      
      def self.is_version_skipped?(version)
        skipped = Sketchup.read_default('PLANT25', 'skipped_version', nil)
        skipped == version
      end
      
    end # module Licensing
  end # module PLANT25
end # module BlueGerberaHorticulture

BlueGerberaHorticulture::PLANT25::Licensing.m_p25_ilss