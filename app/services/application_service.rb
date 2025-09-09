class ApplicationService
  
  attr_reader :result, :errors

  def initialize
    @result = nil
    @errors = []
  end

  def self.call(*args, &block)
    new(*args, &block).call
  end

  def call
    raise NotImplementedError, "#{self.class} must implement the method #call"
  end

  def success?
    @errors.empty?
  end

  def failure?
    !success?
  end

  private

  def add_error(message)
    Rails.logger.error("[Error] #{message}")
    @errors << message
  end
  
  def set_result(result)
    @result = result
  end
end