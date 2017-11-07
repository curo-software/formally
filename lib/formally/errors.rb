module Formally
  Error = Class.new StandardError

  ClassMismatch   = Class.new Error
  SchemaUndefined = Class.new Error
  Unfilled        = Class.new Error
end
