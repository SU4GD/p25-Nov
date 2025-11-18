require 'sketchup.rb'
require 'fileutils' unless defined?(FileUtils)
require 'base64'
require 'json'

module BlueGerberaHorticulture
  module PLANT25

    # PUBLIC decode method - unified for hex + Base64 using one key
    def self._p25_sd(encoded_str)
      begin
        require 'base64'

        # Unified XOR key used for all encoded strings
        key = "a9Kf3TzX2wL7Qp8mNb"
        key_bytes = key.bytes

        decoded =
          if encoded_str.match?(/\A[0-9a-fA-F]+\z/)
            # HEX FORMAT
            packed_str = [encoded_str].pack('H*')
            packed_str.bytes.map.with_index { |b, i| b ^ key_bytes[i % key_bytes.length] }.pack('C*')
          else
            # BASE64 FORMAT
            Base64.strict_decode64(encoded_str).bytes.map.with_index { |b, i| b ^ key_bytes[i % key_bytes.length] }.pack('C*')
          end

        # Enhanced debugging to catch the problematic string
        if DEBUG
          puts "[PLANT25 DEBUG] Decoded string: '#{decoded}'"
          
          # Check for the gibberish pattern
          if decoded.include?("PlintHUqXM") || decoded.include?("[@9Dsdcbe") || decoded.include?("gempting")
            puts "=" * 60
            puts "[PLANT25 FOUND PROBLEMATIC STRING!]"
            puts "  Encoded input: #{encoded_str}"
            puts "  Decoded output: #{decoded}"
            puts "  String length: #{decoded.length}"
            puts "  Bytes: #{decoded.bytes.inspect}"
            puts "=" * 60
          end
        end
        
        decoded
      rescue => e
        puts "[PLANT25 ERROR] Decode error for input '#{encoded_str}': #{e.message}"
        puts "  Error type: #{e.class}"
        puts "  Backtrace: #{e.backtrace.first(3).join("\n  ")}"
        encoded_str # fallback: return original
      end
    end

    # CORRECTED: Alias decode method IMMEDIATELY to ensure it's public before any other file needs it.
    class << self
      alias_method :decode_string, :_p25_sd
      public :decode_string
      public :_p25_sd
    end

    PLUGIN_DIR = File.dirname(__FILE__).freeze
    DEBUG = false  # Set to false for production
    C_P25_VERSION = "2.0.0".freeze  # Add version constant for migration tracking

    @iv_p25_eif = false

    # --- LOGGING ---
    def self.m_p25_dlog(msg)
      dummy_log_var = 3.14 * 22 # dummy
      puts("[PLANT25 DEBUG] #{msg}") if DEBUG
    end

    def self.m_p25_elog(msg)
      timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S.%3N')
      puts("[PLANT25 ERROR][#{timestamp}] #{msg}")
    end

    # CORRECTED: Add aliases for the logging methods IMMEDIATELY after defining them.
    class << self
      alias_method :debug_log, :m_p25_dlog
      alias_method :error_log, :m_p25_elog
    end

    # --- MIGRATION HANDLER (FIXED) ---
    # Handles migration of plants from old location to new location
    module MigrationHandler
      MIGRATION_FLAG_FILE = ".migration_v3_complete"  # Changed to v3 to force re-run
      
      def self.check_and_migrate
        old_plants_dir = File.join(PLUGIN_DIR, "plants")
        new_plants_dir = File.join(File.dirname(PLUGIN_DIR), "Plant25_Plants", "plants")  # FIXED: Plant25_Plants not PLANT25_Plants
        migration_flag = File.join(File.dirname(new_plants_dir), MIGRATION_FLAG_FILE)
        
        # Skip if already migrated AND plants actually exist in new location
        if File.exist?(migration_flag)
          # Double-check plants are actually there
          new_plant_count = Dir.glob(File.join(new_plants_dir, "*.skp")).count
          old_plant_count = Dir.exist?(old_plants_dir) ? Dir.glob(File.join(old_plants_dir, "*.skp")).count : 0
          
          # If flag exists but no plants in new location and plants exist in old location, remove flag and migrate
          if new_plant_count == 0 && old_plant_count > 0
            File.delete(migration_flag)
            BlueGerberaHorticulture::PLANT25.m_p25_dlog("Migration flag found but plants missing - removing flag and re-migrating")
          else
            return  # Plants already migrated successfully
          end
        end
        
        # Skip if no old plants directory
        return unless Dir.exist?(old_plants_dir)
        
        # Check if there are actually plants to migrate
        plant_files = Dir.glob(File.join(old_plants_dir, "*.skp"))
        return if plant_files.empty?
        
        # Perform migration
        begin
          # Log migration start instead of using notifications
          puts "[PLANT25] Migrating #{plant_files.length} plants to new location..."
          BlueGerberaHorticulture::PLANT25.m_p25_dlog("Starting migration of #{plant_files.length} plants")
          
          # Create backup
          backup_dir = old_plants_dir + "_backup_#{Time.now.to_i}"
          FileUtils.cp_r(old_plants_dir, backup_dir)
          BlueGerberaHorticulture::PLANT25.m_p25_dlog("Created backup at: #{backup_dir}")
          
          # Ensure new directory exists
          FileUtils.mkdir_p(new_plants_dir)
          
          # Migrate files
          migrated_count = 0
          skipped_count = 0
          
          plant_files.each do |old_file|
            filename = File.basename(old_file)
            new_file = File.join(new_plants_dir, filename)
            
            if File.exist?(new_file)
              skipped_count += 1
              BlueGerberaHorticulture::PLANT25.m_p25_dlog("Skipped (already exists): #{filename}")
            else
              FileUtils.cp(old_file, new_file)
              migrated_count += 1
              BlueGerberaHorticulture::PLANT25.m_p25_dlog("Migrated: #{filename}")
            end
          end
          
          # Mark migration as complete
          File.write(migration_flag, {
            migrated_at: Time.now.to_s,
            migrated_count: migrated_count,
            skipped_count: skipped_count,
            from_version: "1.x",
            to_version: C_P25_VERSION
          }.to_json)
          
          # Clean up old directory
          FileUtils.rm_rf(old_plants_dir)
          BlueGerberaHorticulture::PLANT25.m_p25_dlog("Removed old plants directory")
          
          # Remove backup after successful migration
          FileUtils.rm_rf(backup_dir)
          BlueGerberaHorticulture::PLANT25.m_p25_dlog("Removed backup directory")
          
          # Show user-friendly completion message
          message = if skipped_count > 0
            "PLANT25 Update Complete!\n\n" +
            "Your custom plants have been moved to a new protected location to keep them safe during future updates.\n\n" +
            "✓ #{migrated_count} plants successfully moved\n" +
            "✓ #{skipped_count} plants already in safe location\n" +
            "✓ All your plants are preserved\n\n" +
            "This is a one-time process. Your plants will now remain safe through all future updates."
          else
            "PLANT25 Update Complete!\n\n" +
            "Your #{migrated_count} custom plant#{migrated_count > 1 ? 's have' : ' has'} been moved to a new protected location to keep them safe during future updates.\n\n" +
            "This is a one-time process. Your plants will now remain safe through all future updates."
          end
          
          puts "[PLANT25] #{message}"
          BlueGerberaHorticulture::PLANT25.m_p25_dlog("Migration complete")
          
          # Show a simple messagebox to notify user
          UI.messagebox(message) if defined?(UI.messagebox)
          
        rescue => e
          # Restore from backup on failure
          if backup_dir && Dir.exist?(backup_dir)
            FileUtils.rm_rf(old_plants_dir) if Dir.exist?(old_plants_dir)
            FileUtils.mv(backup_dir, old_plants_dir)
            BlueGerberaHorticulture::PLANT25.m_p25_elog("Migration failed, restored backup: #{e.message}")
          end
          
          puts "[PLANT25] Plant migration failed. Your plants are safe in the original location."
          BlueGerberaHorticulture::PLANT25.m_p25_elog("Migration error: #{e.message}")
          
          # Don't mark as complete so it can retry next time
          raise e
        end
      end
    end

    @iv_p25_atk = nil # active tool key

    def self.m_p25_gatk
      d_dirs = 1 if true # dummy always-true
      @iv_p25_atk
    end

    def self.m_p25_satk(tool_key)
      dummy_var_x = 7*11 # dummy
      previous_tool_key = @iv_p25_atk
      return if previous_tool_key == tool_key

      @iv_p25_atk = tool_key
      if defined?(BlueGerberaHorticulture::PLANT25.m_p25_dlog)
        BlueGerberaHorticulture::PLANT25.m_p25_dlog("### Main: set_active_tool changing from [#{previous_tool_key || 'nil'}] to [#{tool_key || 'nil'}] ###")
      end

      # NOW WE CAN NOTIFY DIALOG/TOOLBAR MANAGERS (if they're loaded)
      if defined?(BlueGerberaHorticulture::PLANT25::DialogManager)
        m_p25_dlog("Notifying DialogManager of tool change...")
        # DialogManager notification would go here
      end
      
      if defined?(BlueGerberaHorticulture::PLANT25::ToolbarManager)
        m_p25_dlog("Notifying ToolbarManager of tool change...")
        # ToolbarManager notification would go here
      end
      
      dummy_final_g = 12345 * 0 + 1 # Final dummy operation
      d2b = 1 if 1 == 1 # always-true branch
    end

    # CORRECTED: Add aliases for the active tool methods IMMEDIATELY after defining them.
    class << self
      alias_method :get_active_tool, :m_p25_gatk
      alias_method :set_active_tool, :m_p25_satk
    end

    # Load ALL files including UI files
    begin
      m_p25_dlog("DEBUG: PLUGIN_DIR = " + PLUGIN_DIR.to_s)
      m_p25_dlog("Loading ALL files (core + modules + UI)...")
      
      # IMPORTANT: _p25_sd method must be defined and PUBLIC before loading obfuscated files
      m_p25_dlog("Decode method _p25_sd is available as: #{self.respond_to?(:_p25_sd) ? 'public' : 'not found'}")
      m_p25_dlog("Using XOR key: a9Kf3TzX2wL7Qp8mNb with Base64 wrapper")
      
      # PHASE 1: Load core files
      m_p25_dlog("=== PHASE 1: Loading core files ===")
      
      cache_manager_path = File.join(PLUGIN_DIR, "core", "plant_cache_manager.rb")
      m_p25_dlog("Loading plant_cache_manager.rb from: #{cache_manager_path}")
      require cache_manager_path
      m_p25_dlog("Successfully loaded plant_cache_manager.rb")
      
      # NEW: Load PlantAPIManager - handles API communication with plant server
      plant_api_manager_path = File.join(PLUGIN_DIR, "core", "plant_api_manager.rb")
      m_p25_dlog("Loading plant_api_manager.rb from: #{plant_api_manager_path}")
      require plant_api_manager_path
      m_p25_dlog("Successfully loaded plant_api_manager.rb")
      
      plant25_path = File.join(PLUGIN_DIR, "core", "plant25.rb")
      m_p25_dlog("Loading plant25.rb from: #{plant25_path}")
      require plant25_path
      m_p25_dlog("Successfully loaded plant25.rb")
      
      # *** NEW: Load machine fingerprint (ADDED FOR MACHINE LOCKING) ***
      machine_fingerprint_path = File.join(PLUGIN_DIR, "core", "machine_fingerprint.rb")
      m_p25_dlog("Loading machine_fingerprint.rb from: #{machine_fingerprint_path}")
      require machine_fingerprint_path
      m_p25_dlog("Successfully loaded machine_fingerprint.rb")
      # *** END NEW SECTION ***
      
      licensing_path = File.join(PLUGIN_DIR, "core", "licensing.rb")
      m_p25_dlog("Loading licensing.rb from: #{licensing_path}")
      require licensing_path
      m_p25_dlog("Successfully loaded licensing.rb")

      # Load license enforcement module
      enforcement_path = File.join(PLUGIN_DIR, "core", "license_enforcement.rb")
      m_p25_dlog("Loading license_enforcement.rb from: #{enforcement_path}")
      require enforcement_path
      m_p25_dlog("Successfully loaded license_enforcement.rb")
      
      m_p25_dlog("All core files loaded successfully!")
      m_p25_dlog("Note: XOR encoding should now work properly with Base64 wrapper")
      
      # PHASE 2: Load module files
      m_p25_dlog("=== PHASE 2: Loading module files ===")
      
      module_files = [
        ["PLANTPath/plant_path.rb", "PLANTPath", false],
        ["PLANTPlace/plant_place.rb", "PLANTPlace", true],  # obfuscated
        ["PLANTArray/plant_array.rb", "PLANTArray", false],
        ["PLANTCreate/plant_create.rb", "PLANTCreate", false],
        ["PLANTCollection/plant_collection.rb", "PLANTCollection", false],
        ["PLANTReport/plant_report.rb", "PLANTReport", false]
      ]
      
      module_files.each do |file_path, module_name, is_obfuscated|
        full_path = File.join(PLUGIN_DIR, file_path)
        m_p25_dlog("Loading #{file_path}#{is_obfuscated ? ' (obfuscated)' : ''}...")
        require full_path
        m_p25_dlog("Successfully loaded #{file_path}")
        
        # Check if module was defined
        if defined?(BlueGerberaHorticulture::PLANT25.const_get(module_name))
          m_p25_dlog("✓ #{module_name} module defined successfully")
        else
          m_p25_elog("✗ #{module_name} module NOT defined - check #{file_path}")
        end
      end
      
      m_p25_dlog("All module files loaded successfully!")
      
      # PHASE 3: Load UI files
      m_p25_dlog("=== PHASE 3: Loading UI files ===")
      
      # Load dialog_manager.rb (obfuscated)
      dialog_manager_path = File.join(PLUGIN_DIR, "ui", "dialog_manager.rb")
      m_p25_dlog("Loading ui/dialog_manager.rb (obfuscated)...")
      begin
        require dialog_manager_path
        m_p25_dlog("Successfully loaded ui/dialog_manager.rb")
        
        # Check if DialogManager was defined
        if defined?(BlueGerberaHorticulture::PLANT25::DialogManager)
          m_p25_dlog("✓ DialogManager module defined successfully")
        else
          m_p25_elog("✗ DialogManager module NOT defined - check dialog_manager.rb")
        end
      rescue => e
        m_p25_elog("Failed to load dialog_manager.rb: #{e.message}")
        m_p25_elog("Check if obfuscated strings need conversion to Base64 format")
      end
      
      # Load toolbar_manager.rb (not obfuscated)
      toolbar_manager_path = File.join(PLUGIN_DIR, "ui", "toolbar_manager.rb")
      m_p25_dlog("Loading ui/toolbar_manager.rb...")
      begin
        require toolbar_manager_path
        m_p25_dlog("Successfully loaded ui/toolbar_manager.rb")
        
        # Check if ToolbarManager was defined
        if defined?(BlueGerberaHorticulture::PLANT25::ToolbarManager)
          m_p25_dlog("✓ ToolbarManager module defined successfully")
        else
          m_p25_elog("✗ ToolbarManager module NOT defined - check toolbar_manager.rb")
        end
      rescue => e
        m_p25_elog("Failed to load toolbar_manager.rb: #{e.message}")
      end
      
      m_p25_dlog("=== ALL FILES LOADED! ===")
      m_p25_dlog("All files loaded (core + modules + UI)")
      
      # NEW: Run migration check BEFORE initializing managers
      # This ensures plants are in the correct location before anything else runs
      begin
        m_p25_dlog("Checking for plant migration needs...")
        BlueGerberaHorticulture::PLANT25::MigrationHandler.check_and_migrate
      rescue => e
        m_p25_elog("Migration check failed but continuing: #{e.message}")
        # Don't block extension loading if migration fails
      end
      
      # Initialize CacheManager
      if defined?(BlueGerberaHorticulture::PLANT25::CacheManager)
        if BlueGerberaHorticulture::PLANT25::CacheManager.respond_to?(:initialize)
          m_p25_dlog("Initializing CacheManager...")
          BlueGerberaHorticulture::PLANT25::CacheManager.initialize
          m_p25_dlog("CacheManager initialized.")
        end
      end
      
      # NEW: Initialize PlantAPIManager
      if defined?(BlueGerberaHorticulture::PLANT25::PlantAPIManager)
        if BlueGerberaHorticulture::PLANT25::PlantAPIManager.respond_to?(:initialize)
          m_p25_dlog("Initializing PlantAPIManager...")
          BlueGerberaHorticulture::PLANT25::PlantAPIManager.initialize
          m_p25_dlog("PlantAPIManager initialized.")
        end
      end
      
      # Initialize UI managers if they loaded
      if defined?(BlueGerberaHorticulture::PLANT25::DialogManager)
        m_p25_dlog("DialogManager is available for initialization")
      end
      
      if defined?(BlueGerberaHorticulture::PLANT25::ToolbarManager)
        m_p25_dlog("ToolbarManager is available for initialization")
      end
      
    rescue LoadError => e
      log_msg = "ERROR loading files in PLANT25/main.rb: " + e.message + "\n" + e.backtrace.join("\n")
      if defined?(BlueGerberaHorticulture::PLANT25.m_p25_elog) && BlueGerberaHorticulture::PLANT25.respond_to?(:m_p25_elog)
        BlueGerberaHorticulture::PLANT25.m_p25_elog(log_msg)
      else
        puts "[PLANT25 FATAL LOAD ERROR] " + log_msg
      end
      UI.messagebox("PLANT25 failed to load files: " + e.message + ". See Ruby Console for details.")
    rescue StandardError => e
      log_msg = "UNEXPECTED ERROR during file loading in PLANT25/main.rb: " + e.message + "\n" + e.backtrace.join("\n")
      if defined?(BlueGerberaHorticulture::PLANT25.m_p25_elog) && BlueGerberaHorticulture::PLANT25.respond_to?(:m_p25_elog)
        BlueGerberaHorticulture::PLANT25.m_p25_elog(log_msg)
      else
        puts "[PLANT25 FATAL LOAD ERROR] " + log_msg
      end
      UI.messagebox("PLANT25 encountered an unexpected error. See Ruby Console for details.")
    end

    def self.m_p25_iext
      return if @iv_p25_eif

      m_p25_dlog("Initializing extension UI (toolbar and menu)...")

      # Create command that directly opens the dialog
      cmd_open_main_dialog = UI::Command.new("PLANT25") do
        m_p25_dlog("PLANT25 menu item clicked - Opening dialog.")
        
        # Actually open the dialog
        if defined?(BlueGerberaHorticulture::PLANT25::DialogManager)
          BlueGerberaHorticulture::PLANT25::DialogManager.create_html_dialog
        else
          UI.messagebox("DialogManager not loaded properly!")
        end
      end

      cmd_open_main_dialog.tooltip = "Open PLANT25"
      cmd_open_main_dialog.menu_text = "PLANT25"

      begin
        extensions_menu = UI.menu("Extensions")
        # Add PLANT25 as a direct menu item, not a submenu
        extensions_menu.add_item(cmd_open_main_dialog)
        m_p25_dlog("PLANT25 added as direct menu item to Extensions menu.")
      rescue StandardError => e
        m_p25_elog("ERROR adding PLANT25 menu item: " + e.message + "\n" + e.backtrace.join("\n"))
        UI.messagebox("Error setting up PLANT25 menu: " + e.message)
      end

      # Create toolbar
      if defined?(BlueGerberaHorticulture::PLANT25::ToolbarManager)
        m_p25_dlog("Creating toolbar...")
        BlueGerberaHorticulture::PLANT25::ToolbarManager.create_toolbar
        m_p25_dlog("Toolbar created successfully")
      else
        m_p25_dlog("ToolbarManager not loaded - skipping toolbar creation")
      end

      @iv_p25_eif = true
      m_p25_dlog("Extension UI initialization completed.")
    end

    def self.m_p25_dirs
      required_dirs = [
        File.join(PLUGIN_DIR, "resources"),
        File.join(PLUGIN_DIR, "resources", "cache"),
        File.join(PLUGIN_DIR, "resources", "html"),
        File.join(PLUGIN_DIR, "resources", "html", "css"),
        File.join(PLUGIN_DIR, "resources", "html", "js"),
        File.join(PLUGIN_DIR, "resources", "images"),
        # NOTE: Removed plants directory - now uses Plant25_Plants outside the plugin
      ]
      required_dirs.each do |dir|
        unless Dir.exist?(dir)
          m_p25_dlog("Attempting to create directory: " + dir)
          begin
            FileUtils.mkdir_p(dir)
            m_p25_dlog("Successfully created directory: " + dir)
          rescue StandardError => e
            m_p25_elog("ERROR creating directory " + dir + ": " + e.message + ". Check permissions.")
          end
        end
        d_dirs = 1 if true # dummy always-true
      end
    end

    def self.m_p25_vres
      required_images = [
        'margin.png', 'logo_main.png', 'profile.png', 'help.png', 'mini.png',
        'plant_place.png', 'plant_path.png', 'plant_array.png', 'plant_create.png',
        'collection.png', 'plant_report.png', 'plant_footer.png',
        'toolbar.png', 'close.png', 'plant_report_margin.png'
      ]
      m_p25_dlog("Verifying required resources...")
      images_dir = File.join(PLUGIN_DIR, "resources", "images")
      missing_resources = []

      required_images.each do |image_filename|
        path = File.join(images_dir, image_filename)
        exists = File.exist?(path)
        m_p25_dlog("Checking #{image_filename}: #{exists ? 'Found' : 'Missing'} at #{path}")
        missing_resources << image_filename unless exists
      end

      unless missing_resources.empty?
        error_message = "PLANT25 is missing required image resources: #{missing_resources.join(', ')}.\n\n" \
                        "These should be in the folder: '#{images_dir}'.\n\n" \
                        "Please check your installation or reinstall the extension."
        m_p25_elog(error_message)
        # Show warning but don't block execution
        puts "[PLANT25 WARNING] Missing resources: #{missing_resources.join(', ')}"
      end
    end

  end # module PLANT25
end # module BlueGerberaHorticulture

begin
  # Initialize PLANT25
  BlueGerberaHorticulture::PLANT25.m_p25_dlog("=== PLANT25 INITIALIZATION ===")
  
  BlueGerberaHorticulture::PLANT25.m_p25_dlog("PLANT25/main.rb top-level execution starting...")
  BlueGerberaHorticulture::PLANT25.m_p25_dirs
  BlueGerberaHorticulture::PLANT25.m_p25_vres
  BlueGerberaHorticulture::PLANT25.m_p25_iext
  BlueGerberaHorticulture::PLANT25.m_p25_dlog("PLANT25/main.rb top-level execution finished.")
  BlueGerberaHorticulture::PLANT25.m_p25_dlog("=== PLANT25 READY ===")
  puts "[PLANT25 SUCCESS] Extension loaded! Check Extensions > PLANT25 menu or toolbar."
rescue StandardError => e
  fatal_error_msg = "[PLANT25 FATAL EXECUTION ERROR in PLANT25/main.rb] " + e.message + "\n" + e.backtrace.join("\n")
  puts fatal_error_msg
  begin
    UI.messagebox("A fatal error occurred initializing PLANT25 (main.rb): " + e.message + ". See Ruby Console for details.") if defined?(UI.messagebox)
  rescue StandardError
    puts "[PLANT25] Could not show messagebox for fatal error in main.rb."
  end
end