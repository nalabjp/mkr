require 'sinatra'
require_relative 'lib/mkr'

class App < Sinatra::Base
  ACTIONS = {
    entered: :punch_in,
    exited: :punch_out
  }.freeze

  post '/' do
    params = JSON.parse(request.body.read)
    action = ACTIONS.fetch(params['action'].to_sym)

    unless action
      Mkr.logger.failure("Not found action: `#{params['action']}`")
      return
    end

    Mkr.logger.info("Process `#{params['action']}` action")
    unless valid?(action)
      Mkr.logger.failure("Off hours for `#{action}`")
      return
    end

    begin
      user = User.from_env
      Mkr.run(user, action)
      Mkr.logger.success("Process `#{params['action']}` action")
      Notifier.success(user.name, action)
    rescue => e
      Mkr.logger.failure(e.message, e)
      Notifier.failure(user.name, action, e)
      raise e
    end
  end

  private

  def valid?(action)
    send("validate_#{action}")
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
