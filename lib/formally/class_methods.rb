module Formally
  module ClassMethods
    attr_writer :formally

    def formally &block
      if block
        @formally.schema = block
      end
      @formally
    end
  end
end
