module Howell
  match(/(twitter|tw) ([\w#\$]+)( \w+)?/) do |m, _, command, nth|
    return unless RubyServ.config.respond_to?(:twitter)

    nth = nth.nil? ? 0 : (nth.to_i > 20 ? 0 : nth.to_i)

    output = if command =~ /\A(#|\$)/
               search_for_tag(command, nth)
             else
               get_last_tweet(command, nth)
             end

    m.reply "\x02Twitter\x02: #{output}"
  end

  match(/https?:\/\/twitter\.com\/(#!\/)?[_0-9a-zA-Z]+\/status\/(\d+)/, skip_prefix: true) do |m, _, id|
    m.reply "\x02Twitter\x02: #{get_last_tweet(id, 0)}"
  end

  match(/https?:\/\/twitter\.com\/(#!\/)?([_0-9a-zA-Z]+)/, skip_prefix: true) do |m, _, username|
    m.reply "\x02Twitter\x02: #{get_last_tweet(username, 0)}"
  end

  def get_last_tweet(user, nth)
    nth = nth > 20 ? 0 : nth

    request = if user =~ /\d+/
                twitter_request(:get, "https://api.twitter.com/1.1/statuses/show.json?id=#{user}")
              else
                twitter_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=#{user}")[nth]
              end

    "\x0307#{request['text'].sub("\n", '-')}\x0307 - \x0303@#{request['user']['screen_name']}\x03 \x0302(#{request['user']['name']} - #{request['user']['description']}) - https://twitter.com/#{request['user']['screen_name']}\x03"
  end

  def search_for_tag(tag, nth)
    twitter_request(:get, "https://api.twitter.com/1.1/search/tweets.json?q=#{URI.escape(tag)}")['statuses']
  end

  def twitter_request(type, uri)
    JSON.parse(prepare_twitter_access_token.request(type, uri).body)
  end

  def prepare_twitter_access_token
    config = RubyServ.config.twitter
    access = OAuth::Consumer.new(config.api_key, config.api_secret, {
      site: 'http://api.twitter.com',
      scheme: :header
    })

    OAuth::AccessToken.from_hash(access, {
      oauth_token: config.access_token,
      oauth_token_secret: config.access_token_secret
    })
  end
end
