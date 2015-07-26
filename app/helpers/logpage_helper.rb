require "rexml/document"
require 'rexml/formatters/pretty.rb'
require 'debugger'
require 'nokogiri'
module LogpageHelper
	def format_full_log path
		#debugger
		whole_out = ""
		lines = File.read(path)
		lines.split("Response").each do |data|
			#debugger
			doc = REXML::Document.new data
			out=""
			doc.write(out,1)
			whole_out << out
		end

		whole_out
	end

	def fetch_message_id_from_ap apPath
		apFile = File.read(apPath)
		apXml  = Nokogiri::XML(apFile)
		messageId = apXml.xpath('//MessageID').text unless apXml.xpath('//MessageID').nil?
		messageId
	end

	def fetch_ap_response_proxy_data proxyPath, apPath
		proxyLogData = nil
    
    apFile      = File.read(apPath)
    apXml       = Nokogiri::XML(apFile)
    proxyFile   = File.read(proxyPath)
   
    messageId       = apXml.at_xpath("//MessageHeader/MessageID").content
    orderId         = apXml.at_xpath("//OrderID").content
    pumpId          = apXml.at_xpath("//PumpChannel/PumpID/PumpID").content 
  
    proxyData    = proxyFile.split("Response").reverse
    pumpObsRegex = /<InfusionProgramStatus>\W+.*?<MessageID>#{messageId}<\/MessageID>\W+.*?<PumpID>#{pumpId}<\/PumpID>\W+.*?<OrderID>#{orderId}<\/OrderID>\W+.*?<\/InfusionProgramStatus>/
   
    proxyData.each do |data|
       if data=~pumpObsRegex
          proxyLogData = data.match(pumpObsRegex).to_s 
          break
       end
    end

    print = REXML::Document.new(proxyLogData)
    out = ""
    proxyData = print.write(out,2)
    return proxyLogData 
	end

	def fetch_ce_data (ceLog, referenceIdValue)
			apStatus = "AP_STATUS_VALID"
      ceMatchData = nil
      ceFetchRegex  = /autoprogramReferenceId:\s#{referenceIdValue}(.*?)I\/PlumSocketReader(.*?)autoprogramStatus:\s#{apStatus}(.*?)tag/m
      ceFileData     = File.read(ceLog)        
      ceData = ceFileData.match(ceFetchRegex).to_s.split('eventMessageHeaderSig').reverse
         ceData.each do |data|
            if data=~ceFetchRegex
               ceMatchData = data.match(ceFetchRegex) 
               break
            end
         end         
    
      ceMatchData.to_s
   end

   def fetch_mns_data(mnsLog, refId)
   	apStatus = "AP_STATUS_VALID"
   	mnsFetchData = nil
   	mnsFetchRegex = /cmdType:\sAUTO_PROGRAM(.*?)referenceId:\s#{refId.to_i}(.*?)autoProgramStatus:\s#{apStatus}(.*?)tag(.*?)referenceId:\s#{refId.to_i}(.*?)autoProgramStatus:\s#{apStatus}(.*?)tag/m
   	mnsFileData = File.read(mnsLog)
   	mnsData = mnsFileData.match(mnsFetchRegex).to_s.split('cmdResponse').reverse
    debugger
   		mnsData.each do |data|
   			unless (data=~mnsFetchRegex).nil?
   				mnsFetchData = data.match(mnsFetchRegex).to_s
   				break
   			end
   		end
      debugger
   		mnsFetchData
   end
end
