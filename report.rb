require 'datamapper'

class Report
  include DataMapper::Resource
  property  :id,                Serial
  property  :version,           String,       :length => 20
  property  :package,           String,       :length => 100
  property  :stack,             String,       :length => 5000           
  property  :created_at,        DateTime
end