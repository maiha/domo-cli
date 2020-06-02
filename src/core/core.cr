module Core
  var option : Domo::Option = Domo::Option::CURRENT
  var parser : OptionParser = build_parser

  def before
    parser.parse(args)
    option.chdir?.try{|dir| Pretty::File.cd(dir)}
    self.logger = option.build_logger
  end

  private def valid_token? : Domo::Token?
    token = load_token!
    raise "expired: #{token.expired_at}" if token.expired_at < Pretty.now + option.token_margin
    return token
  rescue err
    logger.warn "valid_token?: #{err}"
    nil
  end

  private def update_token!
    authorize!
  end

  private def authorize!
    u1 = option.client_id?.presence     || abort "Need --client-id or env:DOMO_CLIENT_ID"
    u2 = option.client_secret?.presence || abort "Need --client-secret or env:DOMO_CLIENT_SECRET"

    curl "-u '#{u1}:#{u2}' 'https://api.domo.com/oauth/token?grant_type=client_credentials&amp;scope=data'", api: "token", bearer: false
  end

  private def load_token! : Domo::Token
    path = option.token_json
    File.exists?(path) || raise "The token file does not exist."
    token = Domo::Token.from_json(File.read(path))
    token.mtime = Pretty::File.mtime(path).to_local
    return token
  rescue err
    abort "load token: #{err} [#{option.token_json.inspect}]"
  end

  private def build_parser
    OptionParser.new do |parser|
      parser.banner = "usage: %s domo [OPTION] <TASK> [ARGS]" % File.basename(PROGRAM_NAME)

      parser.on("--client-id <ID>", "Specify the OAuth2 client ID") {|v| option.client_id = v}
      parser.on("--client-secret <SECRET>", "Specify the OAuth2 client secret") {|v| option.client_secret = v}
      parser.on("-m", "--token-margin SEC", "Margin to expired at (default: 60)") {|v| option.token_margin = v.to_i.seconds }
      parser.on("-O", "--outdir DIR", "Write files into the DIR") {|v| option.outdir = v.sub("/+$/","") }
      parser.on("-C", "--chdir DIR", "Change to DIR before executing") {|v| option.chdir = v }
      parser.on("-f", "--file FILE", "Filename to upload") {|v| option.file = v }
      parser.on("-l", "--log FILE", "Logging file name (default: STDOUT)") {|v| option.logger_path = v }
      parser.on("-n", "--dryrun", "Dryrun mode") { option.dryrun = true }
      parser.on("-v", "--verbose", "Verbose mode") { option.verbose = true }
      parser.on("-h", "--help", "Show this help") { help_and_exit! }
    end
  end

  private def help_and_exit!
    puts parser
    if self.class.task_names.any?
      puts "\ntasks:\n  %s" % self.class.task_names.join(", ")
    end
    exit 0
  end
end
