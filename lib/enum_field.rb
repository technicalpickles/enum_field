module EnumField
  def self.included(klass)
    klass.class_eval { extend EnumField::ClassMethods }
  end
  
  module ClassMethods
    # enum_field encapsulates a validates_inclusion_of and automatically gives you a 
    # few more goodies automatically.
    # 
    #     class Computer < ActiveRecord:Base
    #       enum_field :status, ['on', 'off', 'standby', 'sleep', 'out of this world']
    # 
    #       # Optionally with a message to replace the default one
    #       # enum_field :status, ['on', 'off', 'standby', 'sleep'], :message => "incorrect status"
    # 
    #       #...
    #     end
    # 
    # This will give you a few things:
    # 
    # - add a validates_inclusion_of with a simple error message ("invalid #{field}") or your custom message
    # - define the following query methods, in the name of expressive code:
    #   - on?
    #   - off?
    #   - standby?
    #   - sleep?
    #   - out_of_this_world?
    # - define the STATUSES constant, which contains the acceptable values
    def enum_field(field, possible_values, options={})
      message = options[:message] || "invalid #{field}"
      const_name = field.to_s.pluralize.upcase

      const_set const_name, possible_values unless const_defined?(const_name)
  
      possible_values.each do |current_value|
        method_name = current_value.downcase.gsub(/[-\s]/, '_')
        define_method("#{method_name}?") do
          self.send(field) == current_value
        end
      end

      options_for_validates = { :in => possible_values, :message => message }
      options_for_validates[:allow_blank] = true if options[:allow_blank]
      options_for_validates[:allow_nil] = true if options[:allow_nil]
  
      validates_inclusion_of field, options_for_validates
    end
  end
end
