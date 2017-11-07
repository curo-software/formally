module Formally
  class State
    def initialize config, object
      @config, @object = config, object
    end

    def call data
      injections = { _self: @object }
      @config.fields.each do |name|
        injections[name] = @object.send name
      end

      result  = @config.finalized_schema.with(injections).call data
      @data   = result.output
      @errors = result.errors
      @filled = true
    end

    def data
      @filled ? @data : raise(Formally::Unfilled)
    end

    def errors
      @filled ? @errors : raise(Formally::Unfilled)
    end

    def valid?
      errors.empty?
    end

    def transaction &block
      @config.transaction.call(&block)
    end
  end
end
