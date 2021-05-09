require 'sinatra'
require_relative 'lib/mkr'

class App < Sinatra::Base
  IFTTT_ACTIONS = {
    'entered' => :clock_in,
    'exited'  => :clock_out
  }.freeze

  post '/' do
    params = JSON.parse(request.body.read)
    action = nil

    if card_action?(params['action'])
      action = params['action'].to_sym
    else
      unless valid_ifttt_action?(params['action'])
        Mkr.logger.failure("Invalid parameters: #{params.inspect}")
        return
      end

      unless valid_clock?(action)
        Mkr.logger.failure("Off hour: `:#{action}`")
        raise "Off hour: `:#{action}`"
      end

      action = IFTTT_ACTIONS[params['action']]
    end

    Mkr.run(action)
  end

  private

  def card_action?(action)
    action == 'card'
  end

  def valid_ifttt_action?(action)
    IFTTT_ACTIONS.keys.include?(action)
  end

  def valid_clock?(action)
    send("validate_#{action}")
  end

  def validate_clock_in
    now = Time.now
    now < Time.local(now.year, now.month, now.day, 13, 0)
  end

  def validate_clock_out
    now = Time.now
    Time.local(now.year, now.month, now.day, 15, 0) <= now
  end
end
