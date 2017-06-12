module ErrorValue
  attr_accessor :error

  def error?
    error.present?
  end
end
