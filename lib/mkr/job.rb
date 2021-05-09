module Mkr
  class Job
    UncaughtError = Class.new(StandardError)

    def initialize(user, action)
      @user = user
      @action = action
    end

    def execute
      Mkr.logger.info("Mkr::Job begin for #{@user.name}")
      set_action if @action == :card
      Mkr.logger.info("Process #{@action}")
      record_clock
      Mkr::Notifier.success(@user.name, @action)
      true
    rescue => e
      Mkr.logger.failure(e)
      Mkr::Notifier.failure(@user.name, @action, e)
      raise e
    ensure
      Mkr.logger.info("Mkr::Job end for #{@user.name}")
    end

    private

    def set_action
      case last_event
      when 'clock_in'
        @action = :clock_out
      else
        @action = :clock_in
      end
    end

    def last_event
      current_state.dig('data', 'last_event')
    end

    def current_state
      url = 'https://attendance.moneyforward.com/api/external/beta_feature/me/current_state'
      res = request(:get, url)

      case res.code
      when '200'
        # e.g. {"data"=>{"date"=>"2021-05-11", "allowed_break_stamping"=>true, "last_event"=>"clock_in", "actual_time_events"=>[{"event"=>"clock_in", "time"=>"10:32"}, {"event"=>"clock_in", "time"=>"10:54"}]}}
        JSON.load(res.body)
      else
        raise UncaughtError.new(res.message)
      end
    end

    def record_clock
      url = 'https://attendance.moneyforward.com/api/external/beta_feature/me/attendance_records'
      payload =  {
        event: @action,
        user_time: Time.now.strftime("%Y-%m-%dT%H:%M:%S%z")
      }

      res = request(:post, url) {|req| req.body = payload.to_json }

      case res.code
      when '200'
        Mkr.logger.success("Record clock for `:#{@action}`")
      else
        raise UncaughtError.new(res.message)
      end
    end

    def request(method, url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      req = Net::HTTP.const_get(method.to_s.capitalize).new(uri.request_uri)
      req["Content-Type"] = "application/json"
      # generate from https://attendance.moneyforward.com/my_page/settings/employee_api_token
      req["Authorization"] = "Token #{@user.api_token}"
      yield(req) if block_given?
      http.request(req)
    end
  end
end
