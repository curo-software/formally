require 'dry-validation'
require 'manioc'

require 'formally/errors'
require 'formally/version'

require 'formally/class_methods'
require 'formally/config'
require 'formally/overrides'
require 'formally/state'

require 'formally/railtie' if defined? Rails::Railtie

module Formally
  class << self
    attr_accessor :config

    def included base
      base.extend  Formally::ClassMethods
      base.prepend Formally::Overrides
      base.formally = Formally.config.with(klass: base)
    end

    def predicates with: []
      _predicates = config.predicates
      Module.new do
        include Dry::Logic::Predicates
        (_predicates + with).each do |predicate|
          instance_exec(&predicate)
        end
      end
    end
  end

  self.config = Formally::Config.new \
    klass: nil, # will be completed at include time
    base:  nil,
    predicates: [],
    transaction: ->(&block) { block.call }

  attr_writer :formally

  def formally
    @formally ||= self.class.formally.build
  end

  extend Forwardable

  def_delegators :@formally, :errors, :valid?
end
