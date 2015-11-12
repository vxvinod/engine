require "rexml/document"
require 'rexml/formatters/pretty.rb'
require 'debugger'
require 'nokogiri'
module LogpageHelper
  include FilterHelper

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
   		mnsData.each do |data|
   			unless (data=~mnsFetchRegex).nil?
   				mnsFetchData = data.match(mnsFetchRegex).to_s
   				break
   			end
   		end
   		mnsFetchData
   end

  def ap_auto_programming(params)
    debugger
    logValues =[]
    bound = params['ap']
    if (bound.eql? 'Request')
      @logValues = fetch_request_interface_messages(params)
    elsif (bound.eql? 'Response')
      @logValues = fetch_response_interface_messages(params)
    else
      @logValues << nil
    end
  end

  def fetch_request_interface_messages(params)
    debugger
    requestData = {}
    ceRequestData = mnsRequestData = proxyRequestData = nil
   # ceRequestData = fetch_ce_ap_request(params)
    mnsRequestData = fetch_mns_ap_request(params)
    proxyRequestData = fetch_proxy_ap_request(params)
    requestData['raw_request'] = {
                                  'proxy_req' => proxyRequestData,
                                  'mns_req'   => mnsRequestData,
                                  'ce_req'    => ceRequestData
                                  }
    requestData['filter_request'] = filter_ap_request(requestData['raw_request'])
    requestData
  end

  def fetch_response_interface_messages(params)
    responseData = {}
    ceResponseData = mnsResponseData = proxyResponseData = nil
    ceResponseData = fetch_ce_ap_response(params)
    mnsResponseData = fetch_mns_ap_response(params)
    proxyResponseData = fetch_proxy_ap_response(params)
    responseData['raw_response'] = {
                                    'proxy_resp' => proxyResponseData,
                                    'mns_resp'   => mnsResponseData,
                                    'ce_resp'    => ceResponseData
    }
    responseData['filter_response'] = filter_ap_response(responseData['raw_response'])
    responseData
  end

  def fetch_ce_ap_response(params)
    ceMatchData = nil
    ceFetchRegex  = /I\/PlumSocketReader(.*?)autoprogramReferenceId:\s#{params['ref_id']}(.*?)I\/PlumSocketReader(.*?)autoprogramStatus:\s#{params['ap_status']}(.*?)tag/m
    ceFileData    = File.read(params['icp_path'])        
    ceData = ceFileData.match(ceFetchRegex).to_s.split('eventMessageHeaderSig').reverse
       ceData.each do |data|
          if data=~ceFetchRegex
             ceMatchData = data.match(ceFetchRegex) 
             break
          end
       end         
    ceMatchData
  end

  def fetch_mns_ap_response(params)
    apStatus = params["ap_status"]
    mnsFetchData = nil
    mnsFetchRegex = /cmdType:\sAUTO_PROGRAM(.*?)referenceId:\s#{params['ref_id']}(.*?)autoProgramStatus:\s#{params['ap_status']}(.*?)tag(.*?)referenceId:\s#{params['ref_id']}(.*?)autoProgramStatus:\s#{params['ap_status']}(.*?)tag/m
    mnsFileData = File.read(params['mns_path'])
    mnsData = mnsFileData.match(mnsFetchRegex).to_s.split('cmdResponse').reverse
      mnsData.each do |data|
        unless (data=~mnsFetchRegex).nil?
          mnsFetchData = data.match(mnsFetchRegex).to_s
          break
        end
      end
    mnsFetchData
  end

  def fetch_proxy_ap_response(params)
    proxyLogData = nil
    params = fetch_details_from_simulator_log(params)
    proxyData    = proxyFile.split("Response").reverse
    pumpObsRegex = /<InfusionProgramStatus>\W+.*?<MessageID>#{params['message_id']}<\/MessageID>\W+.*?<PumpID>#{params['pump_id']}<\/PumpID>\W+.*?<OrderID>#{params['order_id']}<\/OrderID>\W+.*?<\/InfusionProgramStatus>/   
    proxyData.each do |data|
       if data=~pumpObsRegex
          proxyLogData = data.match(pumpObsRegex).to_s 
          break
       end
    end
    proxyLogData 
  end

  def fetch_details_from_simulator_log(params)
    apFileData = fetch_proxy_ap_request(params)
    apXml      = Nokogiri::XML(apFileData)
    params['order_id'] = apXml.at_xpath("//OrderID").content
    params['pump_id']= apXml.at_xpath("//PumpChannel/PumpID/PumpID").content 
    # generate order id and pump id
    params
  end

  def fetch_proxy_ap_request(params)
    debugger
    ceMatchData = proxyReqData = nil
    proxyReqRegex  = /<ProgramPump>(.*?)<MessageID>#{params['message_id']}<\/MessageID>(.*?)<\/ProgramPump>$/m
    simulatorFileData  = File.read(params['simulator_path'])        
    simulatorData = simulatorFileData.match(proxyReqRegex).to_s.split('Received:').reverse
    simulatorData.each do |data|
      if data=~proxyReqRegex
        proxyReqData = data.match(proxyReqRegex) 
        break
      end
    end         
    proxyReqData.to_s  
  end

  def get_interface_path(params) 
    path = Plum.find_by_id(1)
    params['icp_path'] = path.icp_path
    params['mns_path'] = path.mns_path
    params['third_party_path'] = path.third_party_path
    params['simulator_path'] = path.simulator_path
    params
  end

  def fetch_mns_ap_request(params)
    debugger
    mnsReqData = nil
    mnsReqRegex  = /HDPSignals\$AutoProgramSig:(.*?)request\s{(.*?)referenceId:\s452(.*?)tag/m
    mnsFileData  = File.read(params['mns_path'])        
    mnsData = mnsFileData.match(mnsReqRegex).to_s.split('com.hospira.hdpsignals.mdcodegen.signals').reverse
    mnsData.each do |data|
      if data=~mnsReqRegex
        mnsReqData = data.match(mnsReqRegex) 
        break
      end
    end         
    mnsReqData.to_s
  end

  def fetch_ce_ap_request(params)
    # I\/HDPClientServiceSMImpl\(\s\d+\):\sreceived:\sAutoProgramSig(.*?)referenceId:\s48(.*?)request\s{(.*?)tag
    debugger
    ceReqData = nil
    ceReqRegex  = /I\/HDPClientServiceSMImpl\(\s\d+\):\sreceived:\sAutoProgramSig(.*?)referenceId:\s48(.*?)request\s{(.*?)tag/m
    ceFileData  = File.read(params['mns_path'])        
    ceData = ceFileData.match(ceReqRegex).to_s.split('com.hospira.hdpsignals.mdcodegen.signals').reverse
    ceData.each do |data|
      if data=~ceReqRegex
        ceReqData = data.match(ceReqRegex) 
        break
      end
    end
    mnsReqData.to_s
  end

end
