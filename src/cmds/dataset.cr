Cmds.command "dataset" do
  include Core

  desc "create", "-f meta.json"
  task "create", "-f <META_JSON>" do
    api  = task_name
    file = option.file.to_s.strip.presence || abort "Need '-f <META_JSON>'"

    name = Shell::Seq.run!("jq -r .name #{file}").stdout.chomp

    valid_token? || update_token!
    curl "-X POST -H 'Content-Type: application/json' --data-binary @#{file} https://api.domo.com/v1/datasets", api: api
    
    if !option.dryrun
      check_create_dataset!(api: api, name: name)
    end
  end

  private def check_create_dataset!(api, name)
    out = option.path("#{api}.out")
    created_name = Shell::Seq.run!("jq -r .name #{out}").stdout.chomp
    created_id   = Shell::Seq.run!("jq -r .id   #{out}").stdout.chomp
    err = nil
      
    if created_name == name
      logger.info "[OK] dataset name : #{name.inspect}".colorize(:green)
    else
      err = "[NG] dataset name : #{name.inspect}, but got #{created_name}"
      logger.error err.colorize(:red)
    end

    if !created_id.empty?
      logger.info  "[OK] dataset id   : #{created_id.inspect}".colorize(:green)
    else
      err = "[NG] dataset id   : #{created_id.inspect}"
      logger.error err.colorize(:red)
    end

    if err
      Pretty::File.write(option.path("err"), err)
      abort err
    else
      Pretty::File.write(option.path("ok"), "created dataset: #{created_id.inspect}")
      puts "OK: #{created_id.inspect} (#{created_name})"
    end
  end
end
