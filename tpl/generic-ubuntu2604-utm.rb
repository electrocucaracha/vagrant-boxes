# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.boot_timeout = 1800
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.box_check_update = true

  config.vm.provider :utm do |u|
    u.cpus = 2
    u.memory = 2048
  end
end
