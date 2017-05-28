require 'singleton'
require 'capybara/poltergeist'
require 'slack-notifier'
require_relative 'mkr/logger'
require_relative 'mkr/logging'
require_relative 'mkr/user'
require_relative 'mkr/job'
require_relative 'mkr/notifier'

module Mkr
  class << self
    def run(user, action)
      Job.new(user, action).execute
    end
  end
end
