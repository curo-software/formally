module Formally
  class State
    def initialize schema:, transaction:
      @schema, @transaction = schema, transaction
      @callbacks = { after_commit: [] }
    end

    def call data
      result  = @schema.call(data || {})
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
      @transaction.call(&block)
    end

    def after_commit &block
      @callbacks[:after_commit].push block
    end

    def callbacks key
      @callbacks.fetch key, []
    end
  end
end
