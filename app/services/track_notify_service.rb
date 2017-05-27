require 'open-uri'

class TrackNotifyService
  include ActionView::Helpers::DateHelper

  def call
    return if amount == latest_amount

    notifier.ping(full_message)
    Price.create!(amount: amount)
  end

  private

  def amount
    @amount ||= Nokogiri::HTML(page_html).css('.rateTable tr:contains("AUST") td:nth-child(4)').text.gsub(',', '').to_f
  end

  def latest_amount
    @latest_amount ||= latest_price&.amount.to_f
  end

  def full_message
    "#{exchange_rate_message}#{highest_message}"
  end

  def notifier
    Slack::Notifier.new(ENV['SLACK_HOOK'], username: ENV['SLACK_USER'], icon_url: ENV['SLACK_ICON'])
  end

  def page_html
    open('https://www.vietcombank.com.vn/exchangerates/')
  end

  def latest_price
    @latest_price ||= Price.order(created_at: :desc).first
  end

  def nearest_higher
    Price.where('amount > ?', amount).maximum('created_at') || Price.minimum('created_at') || Time.parse('2017/05/26')
  end

  def now
    @now ||= Time.now.in_time_zone(ENV['TIME_ZONE'])
  end

  def highest_in
    distance_of_time_in_words(now, nearest_higher)
  end

  def exchange_rate_message
    "Exchange Rate at #{now.strftime('%H:%M %d/%m/%Y')} 1 AUD = #{amount} VND"
  end

  def highest_message
    ". Highest in #{highest_in}" if latest_amount < amount
  end
end
