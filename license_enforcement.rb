# frozen_string_literal: true
# core/license_enforcement.rb - Central module for enforcing license checks.

module BlueGerberaHorticulture
  module PLANT25
    module LicenseEnforcement
      # Track if activation dialog is currently showing
      @activation_in_progress = false

      class << self
        attr_accessor :activation_in_progress

        # Performs the actual license check by calling the core licensing module.
        # This is the single source of truth for license validity.
        # It includes error handling to prevent crashes if the check fails.
        def allowed?
          BlueGerberaHorticulture::PLANT25::Licensing.check_license_status
        rescue => e
          BlueGerberaHorticulture::PLANT25.error_log("License check error: #{e.message}")
          false
        end

        # A non-blocking, cached version of the license check for frequent use.
        # It only performs a real check once every 5 minutes (300 seconds) to ensure
        # high performance and avoid spamming the license server.
        # Returns true/false without showing any UI.
        def allowed_silent?
          return true if defined?(@last_silent_check) && (Time.now.to_i - @last_silent_check) < 300
          @last_silent_check = Time.now.to_i
          allowed?
        end

        # The main user-facing enforcement method.
        # It checks for a license and, if invalid, shows a dialog box asking the
        # user to activate. This should be called at the entry point of any licensed feature.
        def require_license(feature_name = nil)
          # CRITICAL FIX: Block if activation is in progress
          if @activation_in_progress
            BlueGerberaHorticulture::PLANT25.debug_log("License activation in progress, blocking feature access")
            return false
          end

          # If the license is valid, allow the action and return true.
          return true if allowed?

          # If the license is invalid, construct and show the message box.
          feature_text = feature_name || "this feature"
          result = UI.messagebox(
            "A valid PLANT25 license is required to use #{feature_text}.\n\nWould you like to activate your license now?",
            MB_YESNO,
            "License Required"
          )

          # If the user clicks "Yes", open the activation dialog.
          if result == IDYES
            # CRITICAL FIX: Set flag BEFORE showing activation dialog
            @activation_in_progress = true
            BlueGerberaHorticulture::PLANT25.debug_log("Starting license activation process")
            BlueGerberaHorticulture::PLANT25::Licensing.activate_license_via_ui
          end

          # Return false to block the feature from running.
          false
        end

        # Call this when activation completes successfully
        def activation_complete
          BlueGerberaHorticulture::PLANT25.debug_log("License activation completed successfully")
          @activation_in_progress = false
          
          # If the main dialog was trying to open, open it now
          if defined?(BlueGerberaHorticulture::PLANT25::DialogManager) && 
             BlueGerberaHorticulture::PLANT25::DialogManager.respond_to?(:create_html_dialog)
            BlueGerberaHorticulture::PLANT25::DialogManager.create_html_dialog
          end
        end

        # Call this when activation is cancelled or fails
        def activation_cancelled
          BlueGerberaHorticulture::PLANT25.debug_log("License activation cancelled or failed")
          @activation_in_progress = false
        end
      end
    end
  end
end