module Core
  private def curl(args, api : String, bearer = true)
    dir  = option.outdir
    base = "#{dir}/#{api}"

    cmd = String.build do |s|
      s << "curl"
      s << " -s -S -D '#{base}.header'"

      if bearer
        s << " -H 'Accept: application/json'"
        s << %( -H "Authorization: bearer `jq -M -r .access_token #{dir}/token.out`")
      end
      s << " " << args
      s << " 1> #{base}.out.tmp"
      s << " 2> #{base}.err.tmp"
    end

    logger.debug cmd
    
    seq = Shell::Seq.new
    seq.dryrun = option.dryrun
    seq.run!("mkdir -p #{dir}")
    seq.run!("rm -f #{base}.out #{base}.err #{base}.header ok err")
    seq.run!(cmd)
    seq.run!("mv #{base}.err.tmp #{base}.err")
    seq.run!("mv #{base}.out.tmp #{base}.out")

    if option.dryrun
      puts seq.manifest
    else
      logger.info seq.log
    end
  end
end
