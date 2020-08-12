# Capybara configuration
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, { js_errors: false, timeout: 5000 })
end

module Mkr
  class Job
    def initialize(user, action)
      @user = user
      @action = action
      @session = create_session
    end

    def execute
      Mkr.logger.info("Mkr::Job begin for #{@user.name}")
      with_signed_in_mf_attendance do
        record_clock
      end
      true
    ensure
      Mkr.logger.info("Mkr::Job end for #{@user.name}")
    end

    private

    def create_session
      Capybara::Session.new(:poltergeist).tap do |s|
        s.driver.headers = {
          'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36'
        }
      end
    end

    def with_signed_in_mf_attendance
      visit_mf_attendance

      begin
        sign_in

        yield
      ensure
        clear_session
      end
    end

    def visit_mf_attendance
      @session.visit('https://attendance.moneyforward.com/employee_session/new')
      Mkr.logger.success('Visit `attendance.moneyforward.com`')
    end

    def sign_in
      @session.within('form') do
        @session.find('#employee_session_form_office_account_name').set(@user.company_id)
        @session.find('#employee_session_form_account_name_or_email').set(@user.id)
        @session.find('#employee_session_form_password').set(@user.pw)
        @session.find('input[type="submit"]').click
        Mkr.logger.success('Sign in')
      end
    rescue Capybara::ElementNotFound => e
      Mkr.logger.error(e)
    end

    def clear_session
      @session.reset!
      Mkr.logger.success('Clear session')
    end

    def record_clock
      @session.within('ul.attendance-card-time-stamp-list') do
        @session.all('li')[record_selector_index].click
        Mkr.logger.success("Record clock for `:#{@action}`")
      end
    end

    def record_selector_index
      case @action
      when :punch_in
        0
      when :punch_out
        1
      end
    end
  end
end
