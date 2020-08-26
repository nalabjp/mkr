module Mkr
  class User
    def self.from_env
      new(ENV['USER_NAME'])
    end

    attr_reader :name

    def initialize(name)
      @name = (name || 'You').freeze
    end
  end
end
