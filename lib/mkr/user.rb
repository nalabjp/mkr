module Mkr
  class User
    def self.from_env
      new(ENV.fetch('MF_ATTENDANCE_ID'), ENV.fetch('MF_ATTENDANCE_PW'), ENV.fetch('MF_ATTENDANCE_COMPANY_ID'), ENV['USER_NAME'])
    end

    attr_reader :id, :pw, :company_id, :name

    def initialize(id, pw, company_id, name)
      @id = id.freeze
      @pw = pw.freeze
      @company_id = company_id.freeze
      @name = (name || id.to_s).freeze
    end
  end
end
