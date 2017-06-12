module Classifiers
  class ClassifiersError < StandardError; end
  class CouldNotCalculateError < ClassifiersError; end
  class EngineNotFoundError < ClassifiersError; end
end
