Cmds.command "token" do
  include Core

  task "authorize", "--client-id=<ID> --client-secret=<SECRET>" do
    authorize!

    if !option.dryrun
      token = load_token!          # read OK
      puts "OK: saved to '#{option.token_json}'"
    end
  end

  task "show" do
    p load_token!
  end

end
