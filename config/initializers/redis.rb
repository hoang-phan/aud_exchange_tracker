$redis = Rails.env.production? ? Redis.new(ENV['REDISTOGO_URL']) : Redis.new
