module Formally
  Error = Class.new StandardError

  ClassMismatch   = Class.new Error
  SchemaUndefined = Class.new Error
  Unfilled        = Class.new Error

  Invalid = Class.new Error do
    attr_accessor :form, :errors

    def to_s
      %|<Invalid(#{errors})>|
    end
  end
end
