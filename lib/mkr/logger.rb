module Mkr
  class Logger
    include Singleton

    def initialize
      @failure = false
      @logger = ::Logger.new($stdout)
      $stdout.sync = true
    end

    def info(message)
      @logger.info(message)
    end

    def success(message, extra: nil)
      @logger.info("[Success] #{message}")
      @logger.info(extra) if extra
    end

    def failure(message, extra: nil)
      @failure = true
      @logger.error("[Failure] #{message}")
      @logger.error(extra) if extra
    end

    def success?
      !@failure
    end
  end
end
