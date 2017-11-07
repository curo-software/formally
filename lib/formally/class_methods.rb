module Formally
  module ClassMethods
    attr_writer :formally

    def formally *fields, &block
      if block
        @formally.schema = block
        @formally.fields += fields
      end
      @formally
    end
  end
end
