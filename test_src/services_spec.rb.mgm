require 'spec_helper'

describe service('ndb_mgmd') do  
  it { should be_enabled   }
  it { should be_running   }
end 

describe service('ndbmtd') do  
  it { should be_enabled   }
  it { should be_running   }
end 

describe command("grep -Fxvf /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys") do
  its(:exit_status) { should eq 0 }
end
