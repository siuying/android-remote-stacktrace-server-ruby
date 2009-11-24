require 'datamapper'

class Report
  include DataMapper::Resource
  property  :id,                Serial
  property  :version,           BigDecimal
  property  :package,           String,       :length => 50
  property  :stack,             String,       :length => 5000           
  property  :created_at,        DateTime
end