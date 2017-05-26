require 'sinatra'
require_relative 'lib/mkr'

class App < Sinatra::Base
  include Mkr::Logging

  ACTIONS = {
    entered: :punch_in,
    exited: :punch_out
  }.freeze

  post '/' do
    params = JSON.parse(request.body.read)
    action = ACTION.fetch(params['action'].to_sym)

    unless action
      failure("Not found action: `#{params['action']}`")
      # TODO: notify failure?
      return
    end

    info("Process `#{params['action']}` action")
    unless valid?(action)
      failure("Off hours for `#{action}`")
      return
    end

    Mkr.run(action)
    success("Process `#{params['action']}` action")
    # TODO: notify success?
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
