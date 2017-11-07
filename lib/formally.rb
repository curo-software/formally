require 'dry-validation'
require 'manioc'

require 'formally/errors'
require 'formally/version'

require 'formally/class_methods'
require 'formally/config'
require 'formally/overrides'
require 'formally/predicate_finder'
require 'formally/state'

require 'formally/railtie' if defined? Rails::Railtie

module Formally
  module Predicates
  end

  class << self
    attr_accessor :config

    def predicates &block
      Predicates.class_exec(&block)
    end

    def included base
      base.extend  Formally::ClassMethods
      base.prepend Formally::Overrides
      base.formally = Formally.config.with(klass: base)
    end
  end

  self.config = Formally::Config.new \
    klass: nil, # will be completed at include time
    base:  nil,
    fields: [],
    transaction: ->(&block) { block.call }

  attr_reader :formally

  extend Forwardable

  def_delegators :@formally, :errors, :valid?
end
