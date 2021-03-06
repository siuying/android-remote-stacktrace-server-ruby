require "rubygems"
require "sinatra"
require 'restclient'
require 'report'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{FileUtils.pwd}/reports.db")
Report.auto_upgrade! # WARNINGS: data maybe be removed

configure do
  set :pushr, ENV['SERVER_ADDRESS']
end

get "/" do
  last = Report.first(:order => [:created_at.desc])
  'see <a href="http://code.google.com/p/android-remote-stacktrace/">android-remote-stacktrace</a> for more details, or see the <a href="/report/' + last.id.to_s + '">last error</a>.'
end

post "/report" do
  stack   = params[:stacktrace]
  version = params[:package_version]
  package = params[:package_name]
  phone = params[:phone_model]
  sdk = params[:android_version]
  
  if stack.nil? || version.nil? || package.nil?
    halt "Missing required parameters!"
  end

  report = Report.new(:version => version, 
    :package => package, 
    :stack => stack,
    :phone => phone,
    :sdk => sdk,
    :created_at => Time.now)
  report.save

  # Use Pushr to send notification
  # More About Pushr: http://www.reality.hk/articles/2009/07/10/1082/
  RestClient.post(options.pushr, 
    :title => "[ERROR][ANDROID][#{package}-#{version}] ##{report.id}", 
    :message => stack)

  "OK"
end

get "/report/:id" do
  id   = params[:id]
  report = Report.get(id.to_i)

  halt "not found" if report.nil?

  "<h1>#{report.package} (#{report.version})</h1>" + 
    "<h2>#{report.phone} (#{report.sdk}) #{report.created_at}</h2>" +
    "<hr/><pre>#{report.stack}</pre>"
end