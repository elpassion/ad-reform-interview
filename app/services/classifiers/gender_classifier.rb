class GenderClassifier
  def initialize(height:, weight:)
    validate_height(height)
    validate_weight(weight)
    @height = height
    @weight = weight
  end

  def call

  end

  private

  def validate_height(height)
    raise(TypeError.new('height must be Integer')) unless height.is_a?(Integer)
  end

  def validate_weight(weight)
    raise(TypeError.new('weight must be Integer')) unless weight.is_a?(Integer)
  end

  class << self
    def call(*args)
      new(*args).call
    end
  end
end
