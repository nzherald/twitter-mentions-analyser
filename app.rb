require 'json'

require 'bundler'
Bundler.require

Dotenv.load

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV.fetch('CONSUMER_KEY')
  config.consumer_secret     = ENV.fetch('CONSUMER_SECRET')
  config.access_token        = ENV.fetch('ACCESS_TOKEN')
  config.access_token_secret = ENV.fetch('ACCESS_SECRET')
end

client.search('@sparknz', result_type: 'recent').each do |result|
  tweet_id = result.id.to_s
  print "Getting #{tweet_id}"
  filename = 'tweets/' + tweet_id + '.json'
  if File.exists?(filename)
    print " - already exists\n"
    next
  end
  print "\n"
  File.open(filename, 'w') do |file|
    file.write JSON.dump result.to_h
  end
end

