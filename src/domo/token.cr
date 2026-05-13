class Domo::Token
  var mtime : Time

  include JSON::Serializable

  property access_token : String
  property expires_in : Int32
  property client_id : String?

  def expired_at : Time
    mtime + expires_in.seconds
  end

  def inspect(io : IO)
    io.puts "fetched at : %s" % mtime
    io.puts "expired at : %s" % expired_at
    io.puts "client_id  : %s" % (client_id || "(unknown)")
    io <<   "token      : %s" % Pretty.truncate(access_token)
  end
end
