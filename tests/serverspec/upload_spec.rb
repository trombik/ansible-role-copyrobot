require "spec_helper"
require "serverspec"


cache_dir = "/var/cache/copyrobot"
users = [
  {
    name: "_sshkey",
    group: "_sshkey",
    groups: ["nobody"],
  }
]
shell = "/bin/sh"
home_base_dir = "/home"

users.each do |u|
  describe group u[:group] do |g|
    it { should exist }
  end
end

users.each do |u|
  describe user u[:name] do
    it { should exist }
    it { should belong_to_primary_group u[:group] }
    it { should have_home_directory "#{home_base_dir}/#{u[:name]}" }
  end

  describe file "#{home_base_dir}/#{u[:name]}/.ssh" do
    it { should exist }
    it { should be_directory }
    it { should be_owned_by u[:name] }
    it { should be_grouped_into u[:group] }
    it { should be_mode 700 }
  end

  describe file "#{home_base_dir}/#{u[:name]}/.ssh/id_rsa" do
    it { should exist }
    it { should be_file }
    it { should be_owned_by u[:name] }
    it { should be_grouped_into u[:group] }
    it { should be_mode 600 }
    its(:content) { should match(/^-----BEGIN (?:RSA|OPENSSH) PRIVATE KEY-----$/) }
  end

  describe file "#{home_base_dir}/#{u[:name]}/.ssh/authorized_keys" do
    it { should exist }
    it { should be_file }
    it { should be_owned_by u[:name] }
    it { should be_grouped_into u[:group] }
    it { should be_mode 600 }
    its(:content) { should match(/^ssh-rsa\s+\S+\s+ansible-generated on\s+\S+$/) }
  end
end
