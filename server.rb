require "rubygems"
require "sinatra"
require 'restclient'
require 'report'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{FileUtils.pwd}/reports.db")

configure do
  set :pushr, ENV['SERVER_ADDRESS']
end

post "/report" do
  stack   = params[:stacktrace]
  version = params[:package_version]
  package = params[:package_name]

  if stack.nil? || version.nil? || package.nil?
    halt "Missing required parameters!"
  end

  Report.new(:version => version, :package => package, :stack => stack, :created_at => Time.now).save
  RestClient.post options.pushr, :title => "[EXCEPTION][ANDROID][#{package}-#{version}]", :message => stack
  "OK"
end