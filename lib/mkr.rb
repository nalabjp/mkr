require 'capybara/poltergeist'
require 'singleton'
require_relative 'mkr/logger'
require_relative 'mkr/logging'
require_relative 'mkr/user'
require_relative 'mkr/job'

module Mkr
  class << self
    def run(action)
      user = User.from_env
      Job.new(user, action).execute
    end
  end
end
