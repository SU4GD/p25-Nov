# PLANT25/core/version_check.rb
# Version checking and update notification system for PLANT25

module PLANT25
  module VersionCheck
    
    CURRENT_VERSION = "1.3.1"
    CHECK_INTERVAL = 24 * 60 * 60  # 24 hours in seconds
    VERSION_CHECK_URL = "https://api.sketchupforgardendesign.com/api/extension/version"
    DOWNLOAD_URL = "https://api.sketchupforgardendesign.com/api/extension/download"
    
    class << self
      
      def initialize_version_check
        # Check on startup
        check_for_updates(silent: true)
        
        # Schedule periodic checks
        schedule_periodic_check
      end
      
      def check_for_updates(silent: false)
        # Skip if checked recently (within last hour for manual checks)
        if !silent && recently_checked?(3600)
          return
        end
        
        # Perform version check in background thread
        Thread.new do
          begin
            response = fetch_version_info
            
            if response && response[:success]
              process_version_response(response[:data], silent)
            end
            
          rescue => e
            puts "[PLANT25] Version check failed: #{e.message}" if $PLANT25_DEBUG
          end
        end
      end
      
      private
      
      def fetch_version_info
        require 'net/http'
        require 'json'
        require 'uri'
        
        uri = URI.parse(VERSION_CHECK_URL)
        uri.query = URI.encode_www_form({ current_version: CURRENT_VERSION })
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        http.open_timeout = 5
        http.read_timeout = 5
        
        request = Net::HTTP::Get.new(uri)
        request['User-Agent'] = "PLANT25/#{CURRENT_VERSION} SketchUp/#{Sketchup.version}"
        
        response = http.request(request)
        
        if response.code == '200'
          data = JSON.parse(response.body, symbolize_names: true)
          { success: true, data: data }
        else
          { success: false, error: "HTTP #{response.code}" }
        end
        
      rescue => e
        puts "[PLANT25] Network error: #{e.message}" if $PLANT25_DEBUG
        { success: false, error: e.message }
      end
      
      def process_version_response(data, silent)
        latest_version = data[:latest_version]
        
        # Compare versions
        if version_newer?(latest_version, CURRENT_VERSION)
          # Save update info
          save_update_info(data)
          
          # Show notification unless silent mode
          unless silent
            show_update_notification(data)
          else
            # In silent mode, show subtle indicator
            show_update_indicator
          end
          
        elsif !silent
          # Manual check with no update available
          UI.messagebox(
            "PLANT25 is up to date!\n\nCurrent version: #{CURRENT_VERSION}",
            MB_OK,
            "PLANT25 Update Check"
          )
        end
        
        # Update last check time
        Sketchup.write_default('PLANT25', 'last_version_check', Time.now.to_i)
      end
      
      def version_newer?(version_a, version_b)
        # Parse semantic versions (e.g., "1.3.1")
        a_parts = version_a.split('.').map(&:to_i)
        b_parts = version_b.split('.').map(&:to_i)
        
        # Pad with zeros if needed
        max_length = [a_parts.length, b_parts.length].max
        a_parts += [0] * (max_length - a_parts.length)
        b_parts += [0] * (max_length - b_parts.length)
        
        # Compare each part
        a_parts.zip(b_parts).each do |a, b|
          return true if a > b
          return false if a < b
        end
        
        false  # Versions are equal
      end
      
      def save_update_info(data)
        Sketchup.write_default('PLANT25', 'update_available', true)
        Sketchup.write_default('PLANT25', 'update_version', data[:latest_version])
        Sketchup.write_default('PLANT25', 'update_notes', data[:release_notes])
        Sketchup.write_default('PLANT25', 'update_url', data[:download_url])
      end
      
      def show_update_notification(data)
        message = "A new version of PLANT25 is available!\n\n"
        message += "Current version: #{CURRENT_VERSION}\n"
        message += "New version: #{data[:latest_version]}\n\n"
        message += "What's new:\n#{data[:release_notes]}\n\n"
        message += "Would you like to download the update now?"
        
        result = UI.messagebox(message, MB_YESNO, "PLANT25 Update Available")
        
        if result == IDYES
          open_download_page(data[:download_url])
        end
      end
      
      def show_update_indicator
        # Add a subtle indicator to the toolbar or menu
        # This will be called from the UI module
        PLANT25::UI::ToolbarManager.show_update_badge if defined?(PLANT25::UI::ToolbarManager)
        
        # Also add to status text
        Sketchup.status_text = "PLANT25: Update available (v#{Sketchup.read_default('PLANT25', 'update_version')})"
      end
      
      def open_download_page(url = nil)
        url ||= DOWNLOAD_URL
        
        # Show download instructions
        message = "The download page will open in your browser.\n\n"
        message += "Installation instructions:\n"
        message += "1. Download the PLANT25.rbz file\n"
        message += "2. In SketchUp, go to Window > Extension Manager\n"
        message += "3. Click 'Install Extension' button\n"
        message += "4. Select the downloaded PLANT25.rbz file\n"
        message += "5. Restart SketchUp\n\n"
        message += "Click OK to open the download page."
        
        result = UI.messagebox(message, MB_OKCANCEL, "PLANT25 Update Instructions")
        
        if result == IDOK
          UI.openURL(url)
        end
      end
      
      def recently_checked?(interval)
        last_check = Sketchup.read_default('PLANT25', 'last_version_check', 0)
        Time.now.to_i - last_check < interval
      end
      
      def schedule_periodic_check
        # Check every 24 hours
        UI.start_timer(CHECK_INTERVAL, false) do
          check_for_updates(silent: true)
          # Reschedule for next check
          schedule_periodic_check
        end
      end
      
    end # class << self
    
    # Public API methods
    
    def self.manual_check
      check_for_updates(silent: false)
    end
    
    def self.get_current_version
      CURRENT_VERSION
    end
    
    def self.has_update?
      Sketchup.read_default('PLANT25', 'update_available', false)
    end
    
    def self.get_update_info
      if has_update?
        {
          version: Sketchup.read_default('PLANT25', 'update_version'),
          notes: Sketchup.read_default('PLANT25', 'update_notes'),
          url: Sketchup.read_default('PLANT25', 'update_url')
        }
      else
        nil
      end
    end
    
    def self.clear_update_notification
      Sketchup.write_default('PLANT25', 'update_available', false)
    end
    
  end # module VersionCheck
end # module PLANT25