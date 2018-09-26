require 'json'

$pillar_data = Hash.new

config_param = ''
if ENV['KITCHEN_HOSTNAME'] and ENV['KITCHEN_USERNAME']
    # if we used a custom provisioner root_path, this would need to be modified to handle that
    kitchen_config_path = "/tmp/kitchen/etc/salt"
    if os[:family] == 'windows'
        kitchen_config_path = command("powershell join-path $Env:TEMP $(join-path kitchen $(join-path etc salt))").stdout.strip
    end
    config_param = "--config-dir \"#{kitchen_config_path}\""
else
    config_param = ''
end


refresh_pillar = command("salt-call saltutil.refresh_pillar #{config_param}")
pillar_data_output = command("salt-call pillar.items #{config_param} --output=json --out-indent=-1 -l quiet")
if not pillar_data_output.stdout.empty? and not pillar_data_output.stdout.nil?
    begin
        $pillar_data = JSON.parse(pillar_data_output.stdout, :max_nesting => false, :symbolize_names => true)
    rescue JSON::ParserError => e
    end
end