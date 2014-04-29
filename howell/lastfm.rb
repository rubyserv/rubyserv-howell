module Howell
  match(/np( \S+)?/) do |m, username|
    return unless lastfm_and_database?

    username ||= user_has_username?(m.user.nickname)
    response   = HTTParty.get("http://ws.audioscrobbler.com/2.0/?format=json&method=user.getrecenttracks&api_key=#{RubyServ.config.api_keys.lastfm}&user=#{username.strip}&limit=1")
    tracks     = response['recenttracks']['track']

    if tracks.is_a?(Array)
      track = tracks[0]
      status = 'current track'
    elsif tracks.is_a?(Hash)
      track = tracks
      status = 'last track'
    end

    artist       = track['artist']['#text']
    album        = track['album']['#text']
    title        = track['name']
    listen_count = HTTParty.get("http://ws.audioscrobbler.com/2.0/?format=json&method=track.getInfo&api_key=#{RubyServ.config.api_keys.lastfm}&username=#{username.strip}&track=#{URI.escape(title)}&artist=#{URI.escape(artist)}")['track']['userplaycount']

    ret = "\x02#{username}\x0F's #{status} - \x02#{track['name']}\x0f"
    ret += " by \x02#{artist}\x0f" unless artist.empty?
    ret += " on \x02#{album}\x0f" unless album.empty?
    ret += " - listened to \x02#{listen_count}\x0f times" unless listen_count.nil?

    m.reply ret
  end

  match(/lastfm (\S+)/) do |m, username|
    return unless lastfm_and_database?

    nick     = db.escape(m.user.nickname)
    username = db.escape(username)

    delete_old_username_if_exists(nick, username)

    db.query("INSERT INTO lastfm (nick, username) VALUES ('#{nick}', '#{username}')")
  end

  def lastfm_and_database?
    if RubyServ.config.respond_to?(:db) && RubyServ.config.db.enabled && RubyServ.config.respond_to?(:api_keys) && RubyServ.config.api_keys.respond_to?(:lastfm)
      true
    else
      RubyServ::Logger.warn('Database is not enabled or there is no lastfm API key')
      false
    end
  end

  def user_has_username?(nick)
    result = db.query("SELECT username FROM lastfm WHERE nick = '#{nick}' LIMIT 1")
    result.count.zero? ? false : result.first[:username]
  end

  def delete_old_username_if_exists(nick, username)
    results  = db.query("SELECT nick, username FROM lastfm WHERE nick = '#{nick}' AND username = '#{username}'")

    db.query("DELETE FROM lastfm WHERE nick='#{nick}'") if results.count.zero?
  end
end
