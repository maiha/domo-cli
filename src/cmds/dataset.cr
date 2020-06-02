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

  desc "import", "123456 -f data.csv # PUT https://api.domo.com/v1/datasets/{DATASET_ID}/data"
  task "import", "<DATASET_ID> -f <DATA_CSV>" do
    api  = task_name
    id   = arg1?.to_s.strip
    file = option.file.to_s.strip

    abort "arg1: Needs <DATASET_ID>" if id.empty?
    abort "Needs -f <DATA_CSV>" if file.empty?

    valid_token? || update_token!
    curl "-X PUT -H 'Content-Type: text/csv' --data-binary @#{file} https://api.domo.com/v1/datasets/#{id}/data", api: api
    
    if !option.dryrun
      check_import_dataset!(api: api)
    end
  end

  desc "update", "123456 -f meta.json # PUT https://api.domo.com/v1/datasets/{DATASET_ID}"
  task "update", "<DATASET_ID> -f <META_JSON>" do
    api  = task_name
    id   = arg1?.to_s.strip
    file = option.file.to_s.strip

    abort "arg1: Needs <DATASET_ID>" if id.empty?
    abort "Needs -f <DATA_CSV>" if file.empty?

    Shell::Seq.run!("jq . #{file}")

    valid_token? || update_token!
    curl "-X PUT -H 'Content-Type: application/json' --data-binary @#{file} https://api.domo.com/v1/datasets/#{id}", api: api
    
    if !option.dryrun
      check_update_dataset!(api: api, id: id)
    end
  end


  task "list" do
    api = task_name

    valid_token? || update_token!
    curl "https://api.domo.com/v1/datasets", api: api
    
    if !option.dryrun
      check_list_dataset!(api: api)
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

  private def check_import_dataset!(api)
    header = option.read("#{api}.header")

    case header
    when /\AHTTP[^ ]*? 204/
      puts "OK"
    else
      out = option.read("#{api}.out")
      err = option.read("#{api}.err")
      log = (out + err).gsub(/\n\n+/m, "\n")
      abort log
    end
  end

  private def check_update_dataset!(api, id)
    out = option.path("#{api}.out")

    updated_id   = Shell::Seq.run!("jq -r .id   #{out}").stdout.chomp
    updated_name = Shell::Seq.run!("jq -r .name #{out}").stdout.chomp
    err = nil
      
    if updated_id == id
      logger.info "[OK] updated dataset id : #{id.inspect}".colorize(:green)
    else
      err = "[NG] updated dataset id : #{updated_id.inspect}, but expected #{id.inspect}"
      logger.error err.colorize(:red)
    end

    if err
      Pretty::File.write(option.path("err"), err)
      abort err
    else
      Pretty::File.write(option.path("ok"), "updated dataset: #{updated_id.inspect}")
      puts "OK: #{updated_id.inspect} (#{updated_name})"
    end
  end

  private def check_list_dataset!(api)
    header = option.read("#{api}.header")

    case header
    when /\AHTTP[^ ]*? 200/
      if option.output.json?
        system("cat '%s'" % option.path("#{api}.out"))
      else        
        system("jq -r -c '.[] |[.id,.name] |@tsv' '%s'" % option.path("#{api}.out"))
      end
    else
      out = option.read("#{api}.out")
      err = option.read("#{api}.err")
      log = (out + err).gsub(/\n\n+/m, "\n")
      abort log
    end
  end

end
