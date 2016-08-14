require 'spec_helper'

describe service('ndb_mgmd') do  
  it { should be_enabled   }
  it { should be_running   }
end 

describe service('ndbmtd') do  
  it { should be_enabled   }
  it { should be_running   }
end 

describe service('mysqld') do  
  it { should be_enabled   }
  it { should be_running   }
end 



describe command("grep -Fxvf /home/mysql/.ssh/id_rsa.pub /home/mysql/.ssh/authorized_keys") do
  its(:exit_status) { should eq 0 }
end
