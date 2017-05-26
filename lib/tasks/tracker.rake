require 'open-uri'

namespace :tracker do
  task get_rate: :environment do
    amount = Nokogiri::HTML(open('https://www.vietcombank.com.vn/exchangerates/')).css('.rateTable tr:contains("AUST") td:nth-child(4)').text.gsub(',', '').to_f.round
    Price.create!(amount: amount)
    Slack::Notifier.new(ENV['SLACK_HOOK'])
                   .ping("VCB Exchange Rate at #{Time.now.in_time_zone('Asia/Ho_Chi_Minh').strftime('%H:%M %d/%m/%Y')} 1 AUD = #{amount} VND")
  end
end
