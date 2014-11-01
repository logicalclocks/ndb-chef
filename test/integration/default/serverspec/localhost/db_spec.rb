require 'spec_helper'

describe command("/var/lib/mysql-cluster/ndb/scripts/mysql-client.sh hop -e \"select count\(*\) from inodes\"") do
  it { should return_stdout /count/ }
end
