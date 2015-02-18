# encoding: utf-8

# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'multi_json'
require 'berkshelf/vagrant'

# Load in custom vagrant settings
raise <<-EOF unless File.exists?("vagrant.yml")

  Hi! Before getting started with Vagrant and Coderwall
  you'll need to setup the `vagrant.yml`. There should
  be a file `vagrant.yml.example` that you can use as
  a base reference. Copy the `vagrant.yml.example` to
  `vagrant.yml` to get started.

EOF

require 'yaml'
custom_settings = File.file?('vagrant.yml') ?  YAML.load_file('vagrant.yml') : {}

if ENV['VAGRANT_DEBUG']
  puts '== Using Custom Vagrant Settings =='
  puts custom_settings.inspect
end

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  VAGRANT_JSON = MultiJson.load(Pathname(__FILE__).dirname.join('.', 'node.json').read)

  config.vm.box = "opscode-ubuntu-12.04_chef-11.4.0"
  config.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_chef-11.4.0.box"
  config.ssh.forward_agent = true

  config.vm.network "private_network", ip: "192.168.237.95"
  config.vm.network :forwarded_port, guest: 3000, host: 3000

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["cookbooks"]
      chef.json = VAGRANT_JSON
      chef.log_level = :debug

      VAGRANT_JSON['run_list'].each do |recipe|
        chef.add_recipe(recipe)
      end if VAGRANT_JSON['run_list']
      chef.json = {
      :rbenv      => {
        :user_installs => [
          {
            :user   => "vagrant",
            :rubies => [
              "2.1.5"
            ],
            :global => "2.1.5"
          }
        ]
      },
      :git        => {
        :prefix => "/usr/local"
      },
      :redis      => {
        :bind        => "127.0.0.1",
        :port        => "6379",
        :config_path => "/etc/redis/redis.conf",
        :daemonize   => "yes",
        :timeout     => "300",
        :loglevel    => "notice"
      },
      :postgresql => {
        :config   => {
          :listen_addresses => "*",
          :port             => "5432"
        },
        :pg_hba   => [
          {
            :type   => "local",
            :db     => "postgres",
            :user   => "postgres",
            :addr   => nil,
            :method => "trust"
          },
          {
            :type   => "host",
            :db     => "all",
            :user   => "all",
            :addr   => "0.0.0.0/0",
            :method => "md5"
          },
          {
            :type   => "host",
            :db     => "all",
            :user   => "all",
            :addr   => "::1/0",
            :method => "md5"
          }
        ],
        :password => {
          :postgres => "password"
        }
      }
    }
  end
end
