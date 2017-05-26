module Mkr
  module Logging
    def self.included(klass)
      klass.class_eval do
        extend Forwardable
        def_delegators :logger, *Logger.public_instance_methods(false)
      end
    end

    def logger
      Logger.instance
    end
  end
end
