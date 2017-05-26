ROOT_DIR = File.dirname(__FILE__)
$LOAD_PATH.unshift(ROOT_DIR) unless $LOAD_PATH.include?(ROOT_DIR)

ENV['RACK_ENV'] ||= 'development'
ENV['TZ'] = 'Asia/Tokyo'

require 'bundler'
Bundler.setup(:default, ENV['RACK_ENV'])

require 'app'
run App
