module Formally
  class Config
    attr_accessor :schema, :fields

    def initialize klass
      @klass  = klass
      @fields = []
    end

    def self.all_method_names klass
      (klass.instance_methods + klass.private_instance_methods).grep(/\?$/)
    end

    IGNORED_METHODS = all_method_names Object

    def finalized_schema
      raise SchemaUndefined unless @schema
      return @finalized_schema if @finalized_schema

      _schema = @schema
      _fields = @fields || []
      _predicates = (self.class.all_method_names(@klass) - IGNORED_METHODS).map do |name|
        @klass.instance_method name
      end.select { |m| m.arity == 0 || m.arity == 1 }

      @finalized_schema = Dry::Validation.Form do
        configure do
          config.messages_file = File.expand_path('../../spec/messages.yml', __dir__)

          _fields.each do |name|
            option name
          end

          option :_self

          _predicates.each do |method|
            if method.arity == 0
              define_method method.name do
                method.bind(_self).call
              end
            else
              define_method method.name do |arg|
                method.bind(_self).call arg
              end
            end
          end

          # class_exec(&_configure) if _configure
        end

        instance_exec(&_schema)
      end

      freeze

      @finalized_schema
    end

    def new object
      unless object.is_a? @klass
        raise ClassMismatch, "#{object.class} is not a #{@klass}"
      end
      Ally.new finalized_schema, object
    end
  end
end
