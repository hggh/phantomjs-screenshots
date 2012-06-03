#!/usr/bin/env ruby
require 'json'
require 'fileutils'
# Copyright Jonas Genannt <jonas@brachium-system.net>
# Licensed under the Apache License, Version 2.0

LOCK_FILE="/var/lock/pjs-screenshots"
JOBS_DIR="/tmp/foo"
JOBS_DIR_ERROR="/tmp/bar"
PHANTOMJS_BIN="/usr/bin/phantomjs"
PHANTOMHS_OPTS="--disk-cache=no --ignore-ssl-errors=yes --load-images=yes"
PHANTONJS_JS="../js/screenshot.js"
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

lock = Lockfile.new(LOCK_FILE)
unless lock.lock
	puts "Script already running"
	exit 0
end

unless File.directory?(JOBS_DIR_ERROR)
	puts "Directory #{JOBS_DIR_ERROR} not available"
	exit 1
end

unless File.directory?(JOBS_DIR)
	puts "Directory #{JOBS_DIR} not available"
	exit 1
end

current = Dir.getwd
Dir.chdir(JOBS_DIR)
jobfiles = Dir.glob("*.json")
Dir.chdir(current)

jobfiles.each do |f|
	json_file = File.join(JOBS_DIR, f)
	begin
		json = JSON.parse(File.read(json_file))
		command = PHANTOMJS_BIN + " " + PHANTOMHS_OPTS + " " + PHANTONJS_JS + " " + json_file

		output = %x{#{command} 2>&1}
		if $? != 0
			raise "could not run phantomjs"
		end

		File.unlink(json_file)
	rescue Exception => e
		FileUtils.mv(json_file, File.join(JOBS_DIR_ERROR, f))
	end
end

lock.unlock
