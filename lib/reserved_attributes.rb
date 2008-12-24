# Based on code from Dave Thomas (Pragmatic Programmers) for the Annotate Models plugin
# www.pragprog.com

require "config/environment"

MODEL_DIR = File.join(RAILS_ROOT, "app/models")
RESERVED_WORDS = %w(accept action attributes application connection database dispatcher
 display drive format key link new notify open public quote render request responses
 scope send session system template test timeout to_s type URI visits)

module ReservedAttributes

  # Given the name of an ActiveRecord class, 
  # check its attributes against the reserved words list
  def self.verify_attributes(klass)
    columns = klass.column_names

    columns.select{|c| RESERVED_WORDS.any? {|r| r==c} }
  end

  # Return a list of the model files to annotate. If we have 
  # command line arguments, they're assumed to be either
  # the underscore or CamelCase versions of model names.
  # Otherwise we take all the model files in the 
  # app/models directory.
  def self.get_model_names
    models = ARGV.dup
    models.shift
    
    if models.empty?
      Dir.chdir(MODEL_DIR) do 
        models = Dir["**/*.rb"]
      end
    end
    models
  end

  def self.check
    RESERVED_WORDS << Object.methods
    self.get_model_names.each do |m|
      class_name = m.sub(/\.rb$/,'').camelize
      begin
        klass = class_name.split('::').inject(Object){ |klass,part| klass.const_get(part) }
        if klass < ActiveRecord::Base && !klass.abstract_class?
          puts "Checking #{class_name} model"

          #checking attributes
          warnings = self.verify_attributes(klass)
          unless warnings.empty?
            puts "  The following attributes are named after reserved words:"
            warnings.each do |w|
              if w == 'type'
                w += " (ignore if you're using Single Table Inheritance)"
              end

              puts "    #{w}"
            end
            puts
          else
            puts "  All clear\n\n"
          end
        else
          puts "Skipping #{class_name}"
        end
      rescue Exception => e
        puts "Unable to check #{class_name}: #{e.message}"
      end
      
    end
  end
end
