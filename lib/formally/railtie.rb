module Formally
  class Railtie < ::Rails::Railtie
    config.after_initialize do |app|
      if defined? ApplicationRecord
        Formally.config.transaction = ->(&block) { ApplicationRecord.transaction(&block) }
      end
    end
  end
end
