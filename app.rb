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
    if action
      info("Process `#{params['action']}` action")
      Mkr.run(action)
      success("Process `#{params['action']}` action")
      Mkr.run(action)
      # TODO: notify success?
    else
      failure("Not found action: `#{params['action']}`")
      # TODO: notify failure?
    end
  end
end
