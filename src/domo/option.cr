class Domo::Option
  CURRENT = new

  var chdir   : String
  var outdir  : String = ".domo"
  var file    : String
  var output  : Output = Output::TEXT
  var dryrun  = false
  var verbose = false

  var client_id     : String = ENV["DOMO_CLIENT_ID"]?
  var client_secret : String = ENV["DOMO_CLIENT_SECRET"]?
  var token_margin  : Time::Span = 60.seconds
  
  var logger_path  : String
  var logger_level : String = "INFO"

  def path(file : String) : String
    File.join(outdir, file)
  end

  def read(file : String) : String
    File.read(path(file))
  end

  def token_json : String
    path("token.out")
  end
  
  def build_logger
    logger = Logger.new(nil)
    if path = logger_path?
      Pretty::File.mkdir_p(File.dirname(path))
      logger = Pretty::Logger.build_logger({"path" => path, "level" => logger_level, "colorize" => true})
    end
    logger.level = "DEBUG" if verbose
    return logger
  end
end
