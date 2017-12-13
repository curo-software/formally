module Formally
  class Config < Manioc.mutable(:base, :predicates, :transaction, :klass)
    attr_accessor :schema

    def build **opts
      Formally::State.new \
        schema:      schema_for(**opts),
        transaction: transaction
    end

    private

    def schema_for **opts
      if opts.none? && schema.arity.zero?
        @_cached_schema ||= build_schema
      else
        build_schema opts
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
