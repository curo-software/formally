module Formally
  class Config < Manioc.mutable(:base, :predicates, :transaction, :klass)
    attr_accessor :schema

    def new instance
      Formally::State.new \
        schema:      schema_for(instance),
        transaction: transaction
    end

    private

    def schema_for instance
      if schema.arity.zero?
        @_cached_schema ||= build_schema instance
      else
        build_schema instance
      end
    end

    def build_schema *args
      _schema = schema
      Dry::Validation.Form base do
        instance_exec(*args, &_schema)
      end
    end
  end
end
