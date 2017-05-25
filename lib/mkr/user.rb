module Mkr
  class User
    def self.from_env
      new(ENV.fetch('KOT_ID'), ENV.fetch('KOT_PW'), ENV['USER_NAME'])
    end

    attr_reader :id, :pw, :name

    def initialize(id, pw, name)
      @id = id.freeze
      @pw = pw.freeze
      @name = (name || id.to_s).freeze
    end
  end
end
