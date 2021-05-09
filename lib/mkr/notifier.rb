module Mkr
  class Notifier
    class << self
      def success(user_name, action)
        return unless enabled?

        attachment = success_attachment(user_name, action)
        Slack::Notifier.new(webhook_url).post(attachment)
      end

      def failure(user_name, action, exception)
        return unless enabled?

        attachment = failure_attatchment(user_name, action, exception)
        Slack::Notifier.new(webhook_url).post(attachment)
      end

      private

      def enabled?
        ENV.key?('SLACK_WEBHOOK_URL')
      end

      def webhook_url
        ENV['SLACK_WEBHOOK_URL']
      end

      def punch_text(action)
        case action
        when :clock_in
          '出勤'
        when :clock_out
          '退勤'
        end
      end

      def punch_emoji(action)
        case action
        when :clock_in
          ':office::runner::dash:'
        when :clock_out
          ':runner::dash::office:'
        end
      end

      def success_attachment(user_name, action)
        msg = "`#{user_name}` の `#{punch_text(action)}` を打刻しました！"

        {
          fallback: msg,
          pretext: msg,
          color: 'good',
          fields: [
            {
              title: 'Success',
              value: punch_emoji(action)
            }
          ]
        }
      end

      def failure_attatchment(user_name, action, exception)
        msg = "`#{user_name}` の `#{punch_text(action)}` が打刻できませんでした..."

        {
          fallback: msg,
          pretext: msg,
          color: 'danger',
          fields: [
            {
              title: 'Failure',
              value: "#{exception.message}\n#{exception.backtrace.join("\n")}"
            }
          ]
        }
      end
    end
  end
end
