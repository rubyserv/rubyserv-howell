module Howell
  match(/wallet( \w+)?( \w+)?/) do |m, command, arg|
    return unless RubyServ.config.respond_to?(:db) && RubyServ.config.db.enabled

    command = db.escape(command.strip) unless command.nil?
    arg     = db.escape(arg.strip) unless arg.nil? || nil
    nick    = db.escape(m.user.nickname)

    if command
        case command
        when 'add'
          m.reply add_address(arg, nick)
        when /(del|remove|delete|rm)/
          m.reply del_address(arg, nick)
        else
          m.reply (command =~ /\w{34}/i ? show_address(command) : show_user(command))
        end
    else
      m.reply show_user(nick)
    end
  end

  def add_address(address, nick)
    if !address_exist?(address)
      db.query("INSERT INTO wallet (nick, address) VALUES ('#{nick}', '#{address}')")

      "address \x0307#{address}\x0f added to your wallet information"
    else
      "address \x0307#{address}\x0f is already applied to a user"
    end
  end

  def del_address(address, nick)
    if has_address?(nick, address)
      db.query("DELETE FROM wallet WHERE nick = '#{nick}' AND address = '#{address}'")

      "address \x0307#{address}\x0f removed from your wallet information"
    else
      "address \x0307#{address}\x0f is not in your wallet"
    end
  end

  def show_user(nick)
    if has_wallet?(nick)
      addresses = []

      data  = db.query("SELECT address FROM wallet WHERE nick = '#{nick}'")
      count = data.count

      data.each { |row| addresses << row[:address] }

      "\x032Wallets for #{nick} (#{count}):\x03 #{addresses.map { |address| "\x0307#{address}\x0f" }.join(', ')}"
    else
      "no wallets stored for \x032#{nick}\x0f"
    end
  end

  def show_address(address)
    response = HTTParty.get("https://blockchain.info/address/#{address}?format=json")

    if !response.body.match(/Sorry this is is not a valid bitcoin address/)
      data = format_blockchain_data(response)

      output = sprintf "\x0307#{address}\x0f - ", data
      output += sprintf "\x02Transactions:\x02 %<transactions>d - ", data
      output += sprintf "\x02Received:\x02 %<received>.2f BTC (~$%<received_usd>.2f) - ", data
      output += sprintf "\x02Sent:\x02 %<sent>.2f BTC (~$%<sent_usd>.2f) - ", data
      output += sprintf "\x02Balance:\x02 %<balance>.2f BTC (~$%<balance_usd>.2f)", data
      output
    else
      "\x0307#{address}\x0f is not a valid address"
    end
  end

  def format_blockchain_data(response)
    {
      transactions: response['n_tx'].to_i,

      received: Float(response['total_received'].to_i) / 100000000,
      received_usd: (Float(response['total_received'].to_i) / 100000000) * mtgox_current,

      sent: Float(response['total_sent'].to_i) / 100000000,
      sent_usd: (Float(response['total_sent'].to_i) / 100000000) * mtgox_current,

      balance: Float(response['final_balance'].to_i) / 100000000,
      balance_usd: (Float(response['final_balance'].to_i) / 100000000) * mtgox_current
    }
  end

  def mtgox_current
    response = JSON.parse(URI.parse('https://data.mtgox.com/api/2/BTCUSD/money/ticker').open.read)['data']

    Float(response['buy']['value'].to_i)
  end

  def address_exist?(address)
    !db.query("SELECT address FROM wallet WHERE address = '#{address}'").count.zero?
  end

  def has_wallet?(nick)
    !db.query("SELECT address FROM wallet WHERE nick = '#{nick}'").count.zero?
  end

  def has_address?(nick, address)
    !db.query("SELECT address FROM wallet WHERE nick = '#{nick}' AND address = '#{address}'").count.zero?
  end
end
