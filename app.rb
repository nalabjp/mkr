require 'sinatra'
require_relative 'lib/mkr'

class App < Sinatra::Base
  IFTTT_ACTIONS = {
    'entered' => :punch_in,
    'exited'  => :punch_out
  }.freeze

  post '/' do
    params = JSON.parse(request.body.read)
    action = IFTTT_ACTIONS[params['action']]

    unless valid?(action)
      Mkr.logger.failure("Invalid parameters: #{params.inspect}")
      return
    end

    Mkr.logger.info("Process `:#{action}` action")
    begin
      user = User.from_env
      Mkr.run(user, action)
      Mkr.logger.success("Process `:#{action}` action")
      Notifier.success(user.name, action)
    rescue => e
      Mkr.logger.failure(e.message, e)
      Notifier.failure(user.name, action, e)
      raise e
    end
  end

  private

  def valid?(action)
    validate_action(action) &&
      send("validate_#{action}")
  end

  def validate_action(action)
    IFTTT_ACTIONS.values.include?(action)
  end

  def validate_punch_in
    now = Time.now
    now < Time.local(now.year, now.month, now.day, 15, 0)
  end

  def validate_punch_out
    now = Time.now
    Time.local(now.year, now.month, now.day, 15, 0) <= now
  end
end
