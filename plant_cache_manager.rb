# PLANT25/core/plant_cache_manager.rb (Updated with API Integration)
# frozen_string_literal: true
require 'json'
require 'fileutils'
require 'thread' # For Queue and Mutex

module BlueGerberaHorticulture
  module PLANT25
    module CacheManager
      @initialized = false
      
      @cache = nil
      @quick_load_data = nil
      @cache_file_path = nil
      @quick_load_file_path = nil
      @processing_queue = nil
      @worker_thread = nil
      @last_scan_time = nil # Represents time of last successful full scan completion
      @mutex = nil # Initialized in setup_threading

      # For periodic checker
      @periodic_checker_thread = nil
      @periodic_checker_setup = false
      @check_interval = 300 # 5 minutes (class instance variable)
      @last_periodic_check_time = nil # Time of last execution of check_for_changes

      # Use parent module's decoder
      def self._p25_sd(encoded_str)
        BlueGerberaHorticulture::PLANT25._p25_sd(encoded_str)
      end

      class << self
        # Allow read access for debugging or external status checks if needed
        attr_reader :cache, :quick_load_data, :cache_file_path, :quick_load_file_path,
                    :last_scan_time, :initialized

        def initialize
          return if @initialized # Prevent re-initialization
          
          setup_threading # Mutex needs to be set up early
          setup_paths
          setup_cache_directory # Ensures cache dir exists before loading
          load_initial_data   # Loads from files if they exist
          start_worker_thread
          setup_periodic_checker # Starts the periodic check thread
          
          @initialized = true
          debug_log(_p25_sd("IlgoDlYZGzZTEClFcRlWBDoLAFUiHFYwWitHFC9SIgNeGCIOGBc="))
        end

        # Public method to get the path, potentially useful for other modules if they need to inspect it.
        def get_quick_load_file_path
          @quick_load_file_path
        end

        def self_check
          # This method is for debugging and can be removed or ifdef'd for release builds
          debug_log(_p25_sd("IlgoDlYZGzZTEClFfwNdASg9AlEuBVh0GTleGylTaw=="))
          debug_log(_p25_sd("QRlmRn47Hi1eEmx+PxlMBC8OCEMuAgl0") + "#{@initialized ? _p25_sd("OHwY") : _p25_sd("L3Y")}")
          debug_log(_p25_sd("QRlmRnA1GTBXVwpePRUYPS8WCQNr") + "#{@cache_file_path || _p25_sd("L1Y/RkAxDg==")}")
          debug_log(_p25_sd("QRlmRmIhEztZVwBYMBQYKycOBBkbB0c8QHg=") + "#{@quick_load_file_path || _p25_sd("L1Y/RkAxDg==")}")
          debug_log(_p25_sd("QRlmRnA1GTBXVwBYMBRdCXRC") + "#{@cache ? "#{@cache.keys.size}" + _p25_sd("QVA/A14n") : _p25_sd("L3ZrTl09FnE=")}")
          debug_log(_p25_sd("QRlmRmIhEztZVwBYMBQYKS8WABkHCVIwHzwIVw==") + "#{@quick_load_data ? _p25_sd("OHwY") : _p25_sd("L3ZrTl09FnE=")}")
          debug_log(_p25_sd("QRlmRmQ7CDNXBWxjOQJdDCpCIFUiEFZuWg==") + "#{@worker_thread&.alive? ? _p25_sd("OHwY") : _p25_sd("L3Y")}")
          debug_log(_p25_sd("QRlmRmMxCDFdEyVUcTNQCC0JBEtrMlsmHzlWVw1bOAZdV24=") + "#{@periodic_checker_thread&.alive? ? _p25_sd("OHwY") : _p25_sd("L3Y")}")
          debug_log(_p25_sd("QRlmRn81CSwSMTlbPVBrDi8MQW0iC1ZuWg==") + "#{@last_scan_time ? Time.at(@last_scan_time) : _p25_sd("L1w9A0E=")}")
          debug_log(_p25_sd("QRlmRn81CSwSJylFOB9cBC1CIlEuBVh0LjFfEnYX") + "#{@last_periodic_check_time ? Time.at(@last_periodic_check_time) : _p25_sd("L1w9A0E=")}")
          true
        end

        private

        def setup_threading
          @mutex = Mutex.new
          @processing_queue = Queue.new
          debug_log(_p25_sd("NVE5A1IwEzZVVy9YPABXAysMFUprTn4hDj1KW2xmJBVNCGdCCFciElo1FjFIEigZ"))
        end

        def setup_paths
          base_dir = if defined?(BlueGerberaHorticulture::PLANT25::PLUGIN_DIR)
                       BlueGerberaHorticulture::PLANT25::PLUGIN_DIR
                     else
                       error_log(_p25_sd("MXUeIXoaJRx7JWxZPgQYCSsECFcuAh10OTlRHykXIRFMBT1CDFgyRlExWjFcFCNFIxVbGWA="))
                       # Fallback assumes this file is in <PLUGIN_ROOT>/core/
                       File.expand_path(File.join(File.dirname(__FILE__), '..'))
                     end
          
          resources_cache_dir = File.join(base_dir, 'resources', 'cache')
          @cache_file_path = File.join(resources_cache_dir, 'plant_cache.json')
          @quick_load_file_path = File.join(resources_cache_dir, 'plant25_quick_load.json')
          debug_log(_p25_sd("IlgoDlZ0CjlGHz8XIhVMQ24hAFojAwl0") + @cache_file_path + _p25_sd("TRkaE1o3ERRdFigNcQ==") + @quick_load_file_path)
        end

        def setup_cache_directory
          return unless @cache_file_path # Path must be set
          cache_dir = File.dirname(@cache_file_path)
          unless Dir.exist?(cache_dir)
            debug_log(_p25_sd("IE0/A14kDjFcEGxDPlBbHysDFVxrBVI3Ej0SEyVFNBNMAjwbWxk=") + cache_dir)
            begin
              FileUtils.mkdir_p(cache_dir)
              debug_log(_p25_sd("IlgoDlZ0HjFAEi9DPgJBTS0QBFg/A1duWg==") + cache_dir)
            rescue => e
              error_log(_p25_sd("J1giClYwWixdVy9FNBFMCG4BAFojAxMwEypXFDhYIwkYSg==") + cache_dir + _p25_sd("RhdrI0EmFSoIVw==") + e.message)
            end
          end
        end

        def load_initial_data
          load_quick_data
          load_cache
        end

        def load_quick_data
          return unless @quick_load_file_path && File.exist?(@quick_load_file_path)
          begin
            data = File.read(@quick_load_file_path)
            # Consider symbolize_names if keys are expected as symbols
            @quick_load_data = JSON.parse(data) 
            debug_log(_p25_sd("MEwiBVh0FjdTE2xTMARZTSINAF0uAhMyCDdfVw==") + @quick_load_file_path + ".")
          rescue JSON::ParserError => e
            error_log(_p25_sd("J1giClYwWixdVzxWIwNdTT8XCFogRl87GzwSEy1DMFBeHyEPQR4=") + @quick_load_file_path + _p25_sd("RgNr") + e.message)
            @quick_load_data = {} 
          rescue => e
            error_log(_p25_sd("JEs5CUF0FjdTEyVZNlBJGCcBChkvB0c1Wj5AGCEXdg==") + @quick_load_file_path + _p25_sd("RgNr") + e.message)
            @quick_load_data = {}
          end
        ensure
          @quick_load_data ||= {} # Ensure it's a hash even if file didn't exist or load failed
        end

        def load_cache
          return unless @cache_file_path && File.exist?(@cache_file_path)
          @mutex.synchronize do
            begin
              data = File.read(@cache_file_path)
              @cache = JSON.parse(data) # Consider symbolize_names
              debug_log(_p25_sd("IlgoDlZ0FjdTEylTcRZKAiNC") + @cache_file_path + ".")
            rescue JSON::ParserError => e
              error_log(_p25_sd("J1giClYwWixdVzxWIwNdTS0DAlEuRlc1DjkSET5YPFAf") + @cache_file_path + _p25_sd("RgNr") + e.message)
              @cache = {}
            rescue => e
              error_log(_p25_sd("JEs5CUF0FjdTEyVZNlBbDC0KBBktFFw5Wn8=") + @cache_file_path + _p25_sd("RgNr") + e.message)
              @cache = {}
            end
          end
        ensure
          @cache ||= {} # Ensure it's a hash
        end

        def save_cache
          return unless @cache && @cache_file_path
          @mutex.synchronize do
            begin
              cache_dir = File.dirname(@cache_file_path)
              FileUtils.mkdir_p(cache_dir) unless Dir.exist?(cache_dir)
              File.write(@cache_file_path, JSON.pretty_generate(@cache))
              debug_log(_p25_sd("IlgoDlZ0CTlEEigXJR8Y") + @cache_file_path + ".")
            rescue => e
              error_log(_p25_sd("J1giClYwWixdVz9WJxUYDi8BCVxrElx0XQ==") + @cache_file_path + _p25_sd("RgNr") + e.message)
            end
          end
        end

        def save_quick_data
          return unless @quick_load_data && @quick_load_file_path
          begin
            quick_load_dir = File.dirname(@quick_load_file_path)
            FileUtils.mkdir_p(quick_load_dir) unless Dir.exist?(quick_load_dir)
            File.write(@quick_load_file_path, JSON.pretty_generate(@quick_load_data))
            debug_log(_p25_sd("MEwiBVh0FjdTE2xTMARZTT0DF1wvRkc7Wg==") + @quick_load_file_path + ".")
          rescue => e
            error_log(_p25_sd("J1giClYwWixdVz9WJxUYHDsLAlJrClw1HnhWFjhWcQRXTWk=") + @quick_load_file_path + _p25_sd("RgNr") + e.message)
          end
        end

        public # Public interface methods

        def get(key)
          return nil unless @cache # Return nil if cache isn't even initialized
          @mutex.synchronize { @cache[key.to_s] }
        end

        def set(key, value)
          @cache ||= {} # Ensure cache is a hash
          @mutex.synchronize do
            @cache[key.to_s] = value
            save_cache # Save immediately on set
          end
        end

        def queue_full_library_scan
          unless @initialized && @processing_queue
            error_log(_p25_sd("IlglCFwgWilHEjlScRZNASJCDVApFFImA3hBFC1Za1B7DC0KBHQqCFIzHyoSGSNDcRlWBDoLAFUiHFYwWjdAVz1CNAVdTSMLEkoiCFR6"))
            return
          end
          @processing_queue << :full_scan
          debug_log(_p25_sd("J0wnChM4EzpAFj5OcQNbDCBCFVg4DRMlDz1HEigZ"))
        end

        # Call this method to gracefully stop the worker and periodic threads if needed (e.g., on plugin unload)
        def shutdown_threads
          debug_log(_p25_sd("IlgoDlYZGzZTEClFcQNQGDoGDk4lOUc8CD1TEz8XMhFUASsGTw=="))
          if @processing_queue && !@processing_queue.closed?
            @processing_queue << :shutdown # Signal worker thread
            @processing_queue.close
          end
          if @worker_thread&.alive?
            debug_log(_p25_sd("NlgiElo6HXhUGD4XJh9KBisQQU0jFFY1HnhGGGxROB5RHiZMTxc="))
            @worker_thread.join(5) # Wait for 5 seconds
            @worker_thread.kill if @worker_thread&.alive? # Force kill if still alive
          end
          if @periodic_checker_thread&.alive?
            debug_log(_p25_sd("NVw5C1o6GyxbGSsXIRVKBCEGCFprBVsxGTNXBWxDOQJdDCpMTxc="))
            @periodic_checker_thread.kill
          end
          @worker_thread = nil
          @periodic_checker_thread = nil
          debug_log(_p25_sd("IlgoDlYZGzZTEClFcQRQHysDBUprFVshDjxdACIZ"))
        end

        private # Back to private methods

        def start_worker_thread
          return if @worker_thread&.alive?
          return unless @processing_queue

          @worker_thread = Thread.new do
            debug_log(_p25_sd("NlY5DVYmWixaBSlWNVBLGS8QFVwvRhsAEipXFigXGDQCTQ==") + "#{Thread.current.object_id}" + _p25_sd("SBc="))
            loop do
              task = nil
              begin
                task = @processing_queue.pop # Blocks until item available or queue closed
                
                if task == :shutdown
                  debug_log(_p25_sd("NlY5DVYmWixaBSlWNVBKCC0HCE8uAhMnEi1GEyNAP1BLBCkMAFVlRnYsEyxbGSsZ"))
                  break
                end

                case task
                when :full_scan
                  perform_full_scan
                else
                  debug_log(_p25_sd("NlY5DVYmWixaBSlWNUoYOCAJD1Y8CBMgGytZVz5SMhVRGysGWxk=") + task.inspect)
                end
              rescue ClosedQueueError
                debug_log(_p25_sd("NlY5DVYmWixaBSlWNUoYPTwNAlw4FVo6HXhDAilCNFBQDD1CA1wuCBM3FjdBEigZcTVABDoLD15l"))
                break # Exit loop if queue is closed
              rescue => e
                error_log(_p25_sd("NlY5DVYmWixaBSlWNVBdHzwNExk7FFw3HytBHiJQcQRZHiVCRg==") + task.inspect + _p25_sd("RgNr") + e.message + _p25_sd("aw==") + e.backtrace.first(5).join("\n"))
                sleep 1 # Prevent tight loop on error
              end
            end
            debug_log(_p25_sd("NlY5DVYmWixaBSlWNVBeBCALElEuAhN8LjBAEi1TcTl8V24=") + "#{Thread.current.object_id}" + _p25_sd("SBc="))
          end
          @worker_thread.abort_on_exception = true # For easier debugging of thread errors
        end
        
        def setup_periodic_checker
          return if @periodic_checker_setup
          
          @last_periodic_check_time = Time.now # Initialize to now
          
          @periodic_checker_thread = Thread.new do
            debug_log(_p25_sd("MVw5D1wwEzsSFCRSMhtdH24WCUsuB1d0CSxTBThSNVAQOSYQBFgvRnoQQHg=") + "#{Thread.current.object_id}" + _p25_sd("SBdrL10gHypEFiANcQ==") + "#{@check_interval}" + _p25_sd("Ehc="))
            loop do
              begin
                sleep @check_interval # Sleep for the interval first
                
                # Double check if shutdown has been signaled (e.g., if @check_interval is very long)
                # This requires a more complex shutdown mechanism or just relying on Thread.kill
                # For now, this loop will run until its thread is killed.

                debug_log(_p25_sd("MVw5D1wwEzsSFCRSMhtdH3RCNlYgAxMhCnhGGGxUORVbBm4EDktrBVs1FD9XBGI="))
                check_for_changes # Placeholder method
                @last_periodic_check_time = Time.now
              rescue => e
                error_log(_p25_sd("MVw5D1wwEzsSFCRSMhtdH24WCUsuB1d0HypAGD4NcQ==") + e.message + _p25_sd("aw==") + e.backtrace.first(5).join("\n"))
                # Avoid tight loop on error, but continue checking periodically
                sleep 60 # Sleep longer on error
              end
            end
            debug_log(_p25_sd("MVw5D1wwEzsSFCRSMhtdH24WCUsuB1d0HDFcHj9fNBQYRRoKE1wqAhMdPmIS") + "#{Thread.current.object_id}" + _p25_sd("SBdr")) # Unlikely to be reached without explicit break
          end
          @periodic_checker_thread.abort_on_exception = true
          @periodic_checker_setup = true
        end

        def perform_full_scan
          debug_log(_p25_sd("MVw5AFwmFzFcEGxRJBxUTSILA0sqFEp0CTtTGWIZfw=="))
          
          # NEW: API Integration - Try API-based scanning first
          if defined?(BlueGerberaHorticulture::PLANT25::PlantAPIManager)
            debug_log("Starting API-based plant scan...")
            
            begin
              # Initialize API manager
              BlueGerberaHorticulture::PLANT25::PlantAPIManager.initialize
              
              # Check for updates from server
              updates_found = BlueGerberaHorticulture::PLANT25::PlantAPIManager.check_for_updates
              debug_log("API update check completed: #{updates_found ? 'updates found' : 'no updates'}")
              
              # Get the API-managed plant directory
              library_path = BlueGerberaHorticulture::PLANT25::PlantAPIManager.get_plant_library_path
              
              if library_path && Dir.exist?(library_path)
                debug_log("Scanning API-managed plant directory: #{library_path}")
                files = Dir.glob(File.join(library_path, '**', '*.skp'))
                debug_log("Found #{files.length} plant files in API-managed directory")
                
                new_cache_data = {}
                files.each do |file|
                  begin
                    id = File.basename(file, '.skp')
                    new_cache_data[id] = {
                      path: file,
                      mtime: File.mtime(file).to_i,
                      size: File.size(file),
                      api_managed: true,
                      source: 'api'
                    }
                    # FUTURE: Add botanical_name and colour from API manifest
                  rescue => e
                    error_log("Error processing API-managed plant file #{file}: #{e.message}")
                  end
                end
                
                @mutex.synchronize do
                  @cache = new_cache_data
                  save_cache
                end
                
                @last_scan_time = Time.now.to_i
                
                debug_log("API scan completed with #{new_cache_data.size} plants")
                
                # Notify UI components of library change
                if defined?(BlueGerberaHorticulture::PLANT25.notify_library_changed)
                  BlueGerberaHorticulture::PLANT25.notify_library_changed
                  debug_log(_p25_sd("L1Y/D1U9HzwSFCNFNFBoIQ8sNQt+Rl47Hi1eEmxYN1BUBCwQAEsyRlA8GzZVEmxWNwRdH24RAlglSA=="))
                else
                  update_dialog_now # Fallback
                end
                
                return # Successfully completed API scan
                
              else
                error_log("API-managed plant directory not available: #{library_path || 'nil'}")
              end
              
            rescue => e
              error_log("API scan failed: #{e.message}")
              debug_log("Falling back to local plant scan")
            end
          else
            debug_log("PlantAPIManager not available, using local plant scan")
          end
          
          # FALLBACK: Local plant scanning (original logic)
          perform_local_scan_fallback
        end

        def perform_local_scan_fallback
          debug_log("Performing fallback local plant scan...")
          
          begin
            unless defined?(BlueGerberaHorticulture::PLANT25.get_plant_library_path)
              error_log(_p25_sd("EVw5AFwmFwdUAiBbDgNbDCBYQXokFFZ0HC1cFDhePh4YSikHFWY7ClI6DgdeHi5FMAJBMj4DFVFsRl07DnhTAS1ePRFaAStM"))
              return
            end
            
            library_path = BlueGerberaHorticulture::PLANT25.get_plant_library_path
            
            unless library_path && Dir.exist?(library_path)
              error_log(_p25_sd("EVw5AFwmFwdUAiBbDgNbDCBYQWknB10gWjRbFT5WIwkYHS8WCRls") + (library_path || _p25_sd("D1AnRhskGyxaVyJYJVBLCDpL")) + _p25_sd("RhkvCVYnWjZdA2xSKRlLGWA="))
              return
            end

            files = Dir.glob(File.join(library_path, '**', '*.skp'))
            debug_log(_p25_sd("J1Y+CFd0") + files.length.to_s + _p25_sd("QWoANhMyEzRXBGxeP1Af") + library_path + _p25_sd("Rhc="))

            new_cache_data = {}
            files.each do |file|
              begin
                id = File.basename(file, '.skp') # Simple ID
                new_cache_data[id] = {
                  path: file,
                  mtime: File.mtime(file).to_i, 
                  size: File.size(file),
                  api_managed: false,
                  source: 'local'
                  # FUTURE: Extract and cache 'botanical_name' and 'colour' here
                  # for faster list loading in dialogs if this cache is the source.
                  # Example:
                  # attrs = BlueGerberaHorticulture::PLANT25::PLANTCollection::TemplateComponents.load_dynamic_attributes(file)
                  # new_cache_data[id][:botanical_name] = attrs['botanical_name'] || id
                  # new_cache_data[id][:colour] = attrs['colour'] || attrs['color']
                }
              rescue => e
                error_log(_p25_sd("JEs5CUF0CipdFClEIhlWCm4ECFUuRhQ=") + file + _p25_sd("RhktCUF0GTlRHykXNQVKBCAFQUooB11uWg==") + e.message)
              end
            end

            @mutex.synchronize do
              @cache = new_cache_data
              save_cache 
            end
            
            @last_scan_time = Time.now.to_i 
            
            if defined?(BlueGerberaHorticulture::PLANT25.notify_library_changed)
              BlueGerberaHorticulture::PLANT25.notify_library_changed
              debug_log(_p25_sd("L1Y/D1U9HzwSFCNFNFBoIQ8sNQt+Rl47Hi1eEmxYN1BUBCwQAEsyRlA8GzZVEmxWNwRdH24RAlglSA=="))
            else
              update_dialog_now # Fallback
            end
            debug_log(_p25_sd("J0wnChM4EzpAFj5OcQNbDCBCAlYmFl8xDj1WWWx0MBNQCCpC") + new_cache_data.size.to_s + _p25_sd("QVA/A14nVHh+Fj9DcQNbDCBCFVAmAxMhCjxTAylTfw=="))
          rescue => e
            error_log(_p25_sd("J0wnChM4EzpAFj5OcQNbDCBCEUskBVYnCXhUFiVbNBQCTQ==") + e.message + _p25_sd("aw==") + e.backtrace.join("\n"))
          end
        end

        def update_dialog_now
          debug_log(_p25_sd("IlgoDlYZGzZTEClFa1BNHSoDFVwUAlo1FjdVKCJYJlAQHSIDAlwjCV8wHyobV2EXBDkYGD4GAE0uRkA8FS1eE2xVNFBMHycFBlw5A1d0GCESJwB2HyQKWGAMDk0iAEoLFjFQBS1FKC9bBS8MBlwvSA=="))
        end

        def check_for_changes
          debug_log(_p25_sd("MVw5D1wwEzsSFCRSMhtdH3RCAlEuBVgLHDdAKC9fMB5fCD1CBEEuBUYgHzwSXy9CIwJdAzoOGBkqRkM4GztXHyNbNRVKRGA="))
          
          # NEW: Check for API updates if PlantAPIManager is available
          if defined?(BlueGerberaHorticulture::PLANT25::PlantAPIManager)
            begin
              # Check for plant updates from API
              updates_found = BlueGerberaHorticulture::PLANT25::PlantAPIManager.check_for_updates
              
              if updates_found
                debug_log("Periodic check found plant updates, triggering full scan")
                @processing_queue << :full_scan if @processing_queue
              else
                debug_log("Periodic check: no plant updates available")
              end
              
            rescue => e
              error_log("Error during periodic API check: #{e.message}")
            end
          end
          
          # This method would ideally also:
          # - Compare current file mtimes/sizes against cached ones for local files.
          # - Detect new/deleted files in local directory.
          # - Update @cache and @quick_load_data incrementally.
          # - Call save_cache/save_quick_data.
          # - Trigger PLANT25.notify_library_changed if changes were found.
        end

        def debug_log(message)
          if defined?(BlueGerberaHorticulture::PLANT25.debug_log) &&
             defined?(BlueGerberaHorticulture::PLANT25::DEBUG) &&
             BlueGerberaHorticulture::PLANT25::DEBUG
            BlueGerberaHorticulture::PLANT25.debug_log(_p25_sd("SXoqBVsxNzlcFitSI1kY") + message)
          # else
            # Optionally, puts here if main logger isn't available but you still want CM logs
            # puts _p25_sd("OnoGRncROA11Kmw=") + message
          end
        end

        def error_log(message)
          if defined?(BlueGerberaHorticulture::PLANT25.error_log)
            BlueGerberaHorticulture::PLANT25.error_log(_p25_sd("SXoqBVsxNzlcFitSI1kY") + message)
          else
            puts _p25_sd("OmkHJ30ASG0SMh5lHiJlRQ0DAlEuK1I6Gz9XBWUX") + Time.now.to_s + ": " + message
          end
        end

      end # class << self
    end # module CacheManager
  end # module PLANT25
end # module BlueGerberaHorticulture