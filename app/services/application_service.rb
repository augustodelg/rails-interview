class ApplicationService
  attr_reader :result, :errors

  def initialize
    @result = nil
    @errors = {
      messages: [],
      status: :unprocessable_entity
    }
  end

  def self.call(*args, **kwargs, &block)
    new(*args, **kwargs, &block).call
  end

  def call
    raise NotImplementedError, "#{self.class} must implement the method #call"
  end

  def success?
    @errors[:messages].empty?
  end

  def failure?
    !success?
  end

  private

  def add_error(message)
    Rails.logger.error("[Error] #{message}")
    @errors[:messages] << message
  end

  def set_error_status(status)
    @errors[:status] = status
  end

  def set_result(result)
    @result = result
  end
end