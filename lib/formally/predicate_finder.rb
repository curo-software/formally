module Formally
  module PredicateFinder
    def self.all_method_names klass
      (klass.instance_methods + klass.private_instance_methods).grep(/\?$/)
    end

    IGNORED_METHODS = all_method_names Object

    def self.call klass
      predicates = []
      (all_method_names(klass) - IGNORED_METHODS).each do |name|
        method = klass.instance_method name
        predicates.push method if method.arity == 0 || method.arity == 1
      end
      Formally::Predicates.instance_methods.each do |name|
        predicates.push Formally::Predicates.instance_method name
      end
      predicates
    end
  end
end
