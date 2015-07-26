class Hmss < ActiveRecord::Base
  # attr_accessible :title, :body
  Hmss.establish_connection(
  	:adapter => "sqlserver",
  	:host	 => "localhost",
  	:username =>"sa",
  	:password => "Hospira1",
  	:database => "HMSS_61"
  	)
  self.table_name = 'dbo.InfusionOrder'
  self.primary_key = 'no'

  def self.reference_id_for_ap_request(requestId)
  	referenceId = nil
  	infusionData = self.find_by_RequestId(requestId)
  	referenceId = infusionData.InfusionOrderId unless infusionData.nil?
  	referenceId
  end
end
