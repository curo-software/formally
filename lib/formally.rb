require 'dry-validation'

require 'formally/errors'
require 'formally/version'

require 'formally/ally'
require 'formally/class_methods'
require 'formally/config'
require 'formally/overrides'

module Formally
  def self.included base
    base.extend  Formally::ClassMethods
    base.prepend Formally::Overrides
    base.formally = Formally::Config.new(base)
  end

  attr_reader :formally

  extend Forwardable

  def_delegators :@formally, :errors, :valid?
end
