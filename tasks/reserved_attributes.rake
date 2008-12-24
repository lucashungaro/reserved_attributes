desc "Check your models for attributes named with Ruby/Rails reserved words"

task :check_reserved_attributes do
   require File.join(File.dirname(__FILE__), "../lib/reserved_attributes.rb")
   ReservedAttributes.check
end
