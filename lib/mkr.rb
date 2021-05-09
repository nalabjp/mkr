require 'json'
require 'singleton'
require 'slack-notifier'
require_relative 'mkr/logger'
require_relative 'mkr/user'
require_relative 'mkr/job'
require_relative 'mkr/notifier'

module Mkr
  class << self
    def run(action)
      Job.new(Mkr::User.new, action).execute
    end

    def logger
      Logger.instance
    end

    private

    def execute(user, action)
    end
  end
end
