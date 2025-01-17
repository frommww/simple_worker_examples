require 'simple_worker'
require 'yaml'

load "server_worker.rb"
load "client_worker.rb"

config_data = YAML.load_file('../_config.yml')

SimpleWorker.configure do |config|
  config.project_id = config_data['sw']['project_id']
  config.token = config_data['sw']['token']
end

num_clients = 5
worker_ids = num_clients.times.map{ 0+Random.rand(999) }.sort 

#running clients
num_clients.times {|i|
  cw = ClientWorker.new
  cw.api_key = config_data["pusher"]["api_key"]
  cw.api_secret = config_data["pusher"]["secret_key"]
  cw.worker_id = worker_ids[i]

  cw.queue(:timeout=>60)

#wait until worker start
  loop do
    status= cw.status["status"]
    puts "Checking status- #{status}"
    break if ['running', 'error', 'timeout'].include?(status)
  end
}

# running killer
sw = ServerWorker.new
sw.api_key = config_data["pusher"]["api_key"]
sw.api_secret = config_data["pusher"]["secret_key"]
sw.app_id = config_data["pusher"]["app_id"]
sw.worker_ids = worker_ids
sw.queue
