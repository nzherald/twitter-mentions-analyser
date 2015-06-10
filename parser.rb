require 'bundler'
Bundler.require

require 'active_support/core_ext/time'
require 'active_support/values/time_zone'
require 'csv'


POSITIVE = ':)'
NEGATIVE = ':('
NEUTRAL  = ':|'

Sentimentalizer.setup


CSV.open('output.csv', 'w') do |csv|
  csv << ['created_at', 'in_reply_to_screen_name', 'in_reply_to_user_id', 'in_reply_to_status_id',
          'possibly_sensitive', 'geo_place_name', 'retweet_count', 'favourite_count', 'source',
          'text', 'sentiment', 'probability', 'user_favourites_count', 'user_followers_count', 'user_friends_count', 'user_lang', 'user_location', 'user_name', 'user_screen_name', 'user_statuses_count']
  Dir['tweets/*.json'].each do |file|
    row = []
    json = JSON.parse File.read file

    puts "Parsing tweet #{json['id']}"

    row << Time.parse(json['created_at']).in_time_zone('Pacific/Auckland').to_s.sub(/ +1200$/, '')
    row << json['in_reply_to_screen_name']
    row << json['in_reply_to_user_id']
    row << json['in_reply_to_status_id']
    row << json['possibly_sensitive']

    if json['place']
      row << json['place']['full_name']
    else
      row << nil
    end

    row << json['retweet_count']
    row << json['favorite_count']

    row << json['source']
    row << json['text']

    begin
    sentiment_result = Sentimentalizer.analyze(json['text'])

    sentiment = case sentiment_result.sentiment
                when POSITIVE then 'positive'
                when NEUTRAL then 'neutral'
                when NEGATIVE then 'negative'
                end

    row << sentiment
    row << sentiment_result.overall_probability
    rescue NoMethodError => e
      puts "Ignoring exception #{e.class.name}: #{e.message}"
      row << 'neutral'
      row << 0.5
    end

    row << json['user']['favourites_count']
    row << json['user']['followers_count']
    row << json['user']['friends_count']
    row << json['user']['lang']
    row << json['user']['location']
    row << json['user']['name']
    row << json['user']['screen_name']
    row << json['user']['statuses_count']

    csv << row

  end
end
