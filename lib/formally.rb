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

    def prepended base
      base.extend Formally::ClassMethods
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

  attr_reader :formally

  extend Forwardable

  def_delegators :@formally, :errors, :valid?

  def initialize *args
    super
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
    formally.transaction do
      super
    end
    formally.callbacks(:after_commit).each(&:call)
    true
  end

  def save!
    unless save
      ex = Formally::Invalid.new
      ex.form   = self
      ex.errors = errors
      raise ex
    end
    true
  end
end
