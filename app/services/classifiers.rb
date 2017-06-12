# Classifiers module will be extracted into a Gem in the future
module Classifiers
  require 'bigdecimal/util'
  require_relative 'classifiers/naive_bayes_classifier'

  class ClassifiersError < StandardError
  end
end
