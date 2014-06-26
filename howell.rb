# Plugin: Howell
# Author: James Newton <hello@jamesnewton.com>
#
# Description: A bot that provides various commands originally ported from
#              skybot (https://github.com/rmmh/skybot) and some extras we use
#              from our private network.
#
# Configuration:
#   db:
#     enabled: (true or false)
#     hostname:
#     username:
#     password:
#     database:
#
#   * db is optional, db related plugins will not work if enabled is false
#
#   * if db is enabled then you will need two tables:
#     table: lastfm fields: nick, username (both can be varchar's)
#     table: wallet fields: nick, address  (both can be varchar's)
#
#  api_keys:
#    lastfm:
#
#  * lastfm is optional, and lastfm commands will not work if there is no lastfm
#    api key
#
# Gems: httparty, json, mysql2

require 'json'
require 'httparty'
require 'mysql2'
require 'oauth'
require 'uri'

module Howell
  include RubyServ::Plugin

  configure do |config|
    config.nickname = 'howell'
    config.realname = 'howell'
    config.username = 'howell'
  end

  def db
    config = RubyServ.config.db
    db     = Mysql2::Client.new(host: config.hostname, username: config.username, password: config.password, database: config.database, reconnect: true)
    db.query_options.merge!(symbolize_keys: true)
    db
  end

  require_relative 'howell/wallet'
  require_relative 'howell/lastfm'
  require_relative 'howell/whatpulse'
  require_relative 'howell/stock'
  require_relative 'howell/server'
  require_relative 'howell/rubygems'
  require_relative 'howell/github'
  require_relative 'howell/codeschool'
  require_relative 'howell/bitcoin'
  require_relative 'howell/twitter'
  require_relative 'howell/worldcup'
end
