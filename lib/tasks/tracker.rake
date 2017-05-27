namespace :tracker do
  task get_rate: :environment do
    TrackNotifyService.new.call
  end
end
