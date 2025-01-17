# TO USE:
# 1) Get accounts/credentials for SimpleWorker and a MongoDB (MongoHQ is pretty cool).
#

require 'simple_worker'
require 'yaml'
# This is needed for the 'minutes since' syntax
require 'active_support/core_ext'

require_relative 'mongo_worker.rb'

config_data = YAML.load_file('../_config.yml')

SimpleWorker.configure do |config|
  config.project_id = config_data['sw']['project_id']
  config.token = config_data['sw']['token']
end

mw               = MongoWorker.new
mw.mongo_host   = config_data['mongo2']['host']
mw.mongo_port   = config_data['mongo2']['port']
mw.mongo_db_name   = config_data['mongo2']['db_name']
mw.mongo_username = config_data['mongo2']['username']
mw.mongo_password = config_data ['mongo2']['password']

# Run the job (with several alternatives included)
#mw.queue

mw.run_local
#mw.schedule(:start_at => 2.minutes.since, :run_every => 60, :run_times => 2)
#mw.queue(:priority=>2)

# Go to the SimpleWorker dashboard to see the status and logs.

# You can also get the stats programmatically with the wait_until_complete and get_log
# Note that wait_until_complete only works with queue (not run_local or schedule).
status = mw.wait_until_complete
puts mw.get_log

