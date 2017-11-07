module Formally
  module Overrides
    def initialize *args
      super(*args)
      @formally = self.class.formally.new self
    end

    def fill data={}
      if data.respond_to?(:permit!)
        # Assume ActionController::Parameters or similar
        # The schema will handle whitelisting allowed attributes
        data = data.permit!.to_h.deep_symbolize_keys
      end

      formally.call data

      if formally.valid?
        super formally.data
      end

      self
    end

    def save
      return false unless formally.valid?
      super
      true
    end
  end
end
