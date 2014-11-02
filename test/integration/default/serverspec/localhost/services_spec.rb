require 'spec_helper'

describe service('ndb_mgmd') do  
  it { should be_enabled   }
  it { should be_running   }
end 

describe service('mysqld') do  
  it { should be_enabled   }
  it { should be_running   }
end 

describe service('memcached') do  
  it { should be_enabled   }
  it { should be_running   }
end 

describe command("/var/lib/mysql-cluster/ndb/scripts/mysql-client.sh hop -e \"select count\(*\) from inodes\"") do
  its (:stdout) { should match /count/ }
end

