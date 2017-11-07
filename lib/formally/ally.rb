module Formally
  class Ally
    def initialize schema, object
      @schema, @object = schema, object
    end

    def call data
      injections = { _self: @object }
      @object.class.formally.fields.each do |name|
        injections[name] = @object.send name
      end

      result  = @schema.with(injections).call data
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
  end
end
