# machine_fingerprint.rb
# This file creates a unique ID for each computer

module BlueGerberaHorticulture
  module PLANT25
    module MachineFingerprint

      # This creates a unique ID for this computer
      def self.get_machine_id
        begin
          # Get computer information
          if Sketchup.platform == :platform_win
            # Windows computer
            computer_name = ENV['COMPUTERNAME'] || 'unknown'
            user_name = ENV['USERNAME'] || 'unknown'
            platform_info = RUBY_PLATFORM
          else
            # Mac computer  
            computer_name = `hostname`.strip rescue 'unknown'
            user_name = ENV['USER'] || 'unknown'
            platform_info = RUBY_PLATFORM
          end
          
          # Combine information and make it into a unique code
          combined_info = "#{computer_name}|#{user_name}|#{platform_info}|#{Sketchup.version}"
          
          # Turn it into a shorter, unique code
          require 'digest'
          machine_id = Digest::SHA256.hexdigest(combined_info)[0..15]
          
          puts "Machine ID generated: #{machine_id}" # For testing
          return machine_id
          
        rescue => e
          puts "Error creating machine ID: #{e.message}"
          return "fallback_id_#{Time.now.to_i}"
        end
      end
      
      # This gets a friendly name for the computer
      def self.get_friendly_name
        if Sketchup.platform == :platform_win
          computer = ENV['COMPUTERNAME'] || 'Windows PC'
          user = ENV['USERNAME'] || 'User'
          return "#{computer} (#{user})"
        else
          computer = `hostname`.strip rescue 'Mac'
          user = ENV['USER'] || 'User'
          return "#{computer} (#{user})"
        end
      end
      
    end
  end
end