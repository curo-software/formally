module Formally
  class Config < Manioc.mutable(:base, :transaction, :klass, :fields)
    attr_accessor :schema
    attr_reader :finalized_schema

    def finalize
      return if @finalized_schema

      _schema     = schema
      _fields     = fields || []
      _predicates = Formally::PredicateFinder.call klass

      @finalized_schema = Dry::Validation.Form base do
        configure do
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
    end

    def new object
      unless object.is_a? klass
        raise ClassMismatch, "#{object.class} is not a #{@klass}"
      end
      finalize
      State.new self, object
    end
  end
end
