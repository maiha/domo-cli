class Domo::Token
  var mtime : Time
  
  JSON.mapping({
    access_token: String,
    expires_in: Int32,
  })

  def expired_at : Time
    mtime + expires_in.seconds
  end

  def inspect(io : IO)
    io.puts "fetched at : %s" % mtime
    io.puts "expired at : %s" % expired_at
    io <<   "token      : %s" % Pretty.truncate(access_token)
  end
end
