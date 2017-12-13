module Formally
  module ClassMethods
    attr_writer :formally

    def formally &block
      if block
        @formally.schema = block
      end
      @formally
    end

    def build **opts
      new(**opts).tap do |instance|
        instance.formally = formally.build(**opts)
      end
    end
  end
end
