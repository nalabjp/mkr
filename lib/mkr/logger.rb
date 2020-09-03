module Mkr
  class Logger
    include Singleton

    def initialize
      @logger = ::Logger.new($stdout)
      $stdout.sync = true
    end

    def info(message)
      @logger.info(message)
    end

    def success(message)
      @logger.info("[Success] #{message}")
    end

    def failure(msg_or_err)
      msg_or_err = "[Failure] #{msg_or_err}" unless msg_or_err.is_a?(Exception)
      @logger.error(msg_or_err)
    end
  end
end
