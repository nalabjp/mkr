module Mkr
  class User
    attr_reader :name, :api_token

    def initialize
      @name = ENV.fetch('USER_NAME', 'You')
      @api_token = ENV.fetch('MF_ATTENDANCE_API_TOKEN')
    end
  end
end
