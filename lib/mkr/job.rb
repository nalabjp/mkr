module Mkr
  class Job
    def initialize(user, action)
      @user = user
      @action = action
    end

    def execute
      Mkr.logger.info("Mkr::Job begin for #{@user.name}")
      record_clock
      true
    ensure
      Mkr.logger.info("Mkr::Job end for #{@user.name}")
    end

    private

    def record_clock
      url = 'https://attendance.moneyforward.com/api/external/beta_feature/me/attendance_records'
      payload =  {
        event: @action,
        user_time: Time.now.strftime("%Y-%m-%dT%H:%M:%S%z")
      }

      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      req = Net::HTTP::Post.new(uri.request_uri)
      req["Content-Type"] = "application/json"
      # generate from https://attendance.moneyforward.com/my_page/settings/employee_api_token
      req["Authorization"] = "Token #{@user.api_token}"
      req.body = payload.to_json
      res = http.request(req)

      if res.code == '200'
        Mkr.logger.success("Record clock for `:#{@action}`")
      else
        raise res.message
      end
    end
  end
end
