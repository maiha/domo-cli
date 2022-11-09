# stdlib
require "option_parser"
require "json"
require "logger"

# shards
require "var"
require "try"
require "cmds"
require "pretty"
require "shell"
require "shard"

# apps
require "./core/**"
require "./domo/**"
require "./cmds/**"

class Main
  def run(args = ARGV)
    arg = args.shift? || raise Cmds::MissingCommand.new
    case arg
    when "-V", "--version"
      STDOUT.puts Shard.git_description
      exit(0)
    else
      Cmds[arg].run(args)
    end
  rescue Cmds::Finished
  rescue err : Cmds::Navigatable
    STDERR.puts Cmds::Navigator.new.navigate(err)
    exit err.exit_code
  rescue err
    STDERR.puts err.to_s.chomp.colorize(:red)
    exit 100
  end
end

Main.new.run
