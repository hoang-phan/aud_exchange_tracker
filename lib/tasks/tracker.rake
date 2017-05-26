require 'open-uri'

namespace :tracker do
  task get_rate: :environment do
    include ActionView::Helpers::DateHelper

    amount = Nokogiri::HTML(open('https://www.vietcombank.com.vn/exchangerates/')).css('.rateTable tr:contains("AUST") td:nth-child(4)').text.gsub(',', '').to_f
    nearest_higher = Price.where('amount > ?', amount).maximum('created_at') || Price.minimum('created_at') || Time.parse('2017/05/26')
    now = Time.now
    highest_in = distance_of_time_in_words(now, nearest_higher)
    message = "Exchange Rate at #{now.in_time_zone('Asia/Ho_Chi_Minh').strftime('%H:%M %d/%m/%Y')} 1 AUD = #{amount} VND"
    message += ". Highest in #{highest_in}" unless highest_in == 'about 1 hour'
    Slack::Notifier.new(ENV['SLACK_HOOK'], username: 'VCB', icon_url: 'http://saigonfs.com/media/upload/lienket/a49745fbe2a7cae270b2.png').ping(message)
    Price.create!(amount: amount)
  end
end
