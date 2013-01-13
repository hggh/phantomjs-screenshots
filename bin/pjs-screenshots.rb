#!/usr/bin/env ruby
begin
	require 'rubygems'
rescue
end
require 'json'
require 'fileutils'
require 'timeout'
require 'yaml'
require 'optparse'
# Copyright Jonas Genannt <jonas@brachium-system.net>
# Licensed under the Apache License, Version 2.0

options = { :config => '../conf/pjs.conf' }
OptionParser.new do |opts|
	opts.banner = "Usage: pjs-screenshots.rb [options]"

	opts.on("-c", "--config CONFIGURATION", "Path to configuration") do |c|
		options[:config] = c
	end
end.parse!

unless File.readable?(options[:config])
	puts "Could not find (#{options[:config]}) configration, use --config"
	exit 1
end
config = YAML.load(File.read(options[:config]))

if config[:selenium_phantomjs]
	require 'selenium-webdriver'
	if config[:selenium_host] == ''
		puts "Please set option :selenium_host in configuration"
		exit 1
	end
end

class Lockfile
	@lock = ""
	@lock_file = ""
	def initialize(lock_file)
		@lock_file = lock_file
		@lock = File.open(lock_file, File::CREAT)
	end

	def lock
		unless @lock.flock(File::LOCK_EX | File::LOCK_NB)
			return false
		end
		true
	end

	def unlock
		@lock.flock(File::LOCK_UN)
		@lock.close
		File.unlink(@lock_file)
	end
end

lock = Lockfile.new(config[:lock_file])
unless lock.lock
	puts "Script already running"
	exit 0
end

unless File.directory?(config[:job_directory_error])
	puts "Directory #{config[:job_directory_error]} not available"
	exit 1
end

unless File.directory?(config[:job_directory])
	puts "Directory #{config[:job_directory]} not available"
	exit 1
end

unless File.exists?(config[:phantomjs_binary])
	puts "PhantomJS binary not available at #{config[:phantomjs_binary]}"
	exit 1
end

current = Dir.getwd
Dir.chdir(config[:job_directory])
jobfiles = Dir.glob("*.json")
Dir.chdir(current)

unless jobfiles.length > 0
	puts "no jobs found at #{config[:job_directory]}"
	exit 1
end

jobfiles.each do |f|
	json_file = File.join(config[:job_directory], f)
	begin
		json = JSON.parse(File.read(json_file))
		viewport = json["ViewPort"].split(/x/)

		Timeout::timeout(15) do
			if config[:selenium_phantomjs]
				slweb = Selenium::WebDriver.for(:remote, :url => config[:selenium_host])
				slweb.manage.window.resize_to(viewport[0],viewport[1])
				slweb.navigate.to json["Url"]
				slweb.save_screenshot(json["Output"])
				slweb.quit
			else
				@pipe = IO.popen(config[:phantomjs_binary] + " " + config[:phantomjs_opts] + " " + config[:phantomjs_script] + " " + json_file)
				output = @pipe.read
				Process.wait(@pipe.pid)
				if $? != 0
					raise "could not run phantomjs"
				end
			end
		end
		File.unlink(json_file)
	rescue Timeout::Error => e
		Process.kill(9, @pipe.pid)
		Process.wait(@pipe.pid)
		FileUtils.mv(json_file, File.join(config[:job_directory_error], f))
	rescue Exception => e
		FileUtils.mv(json_file, File.join(config[:job_directory_error], f))
	end
end

lock.unlock
