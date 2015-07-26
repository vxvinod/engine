class LogpageController < ApplicationController
include LogpageHelper
	def searchLog
		@log_path = Plum.new
		#@display = File.readlines('C:\Users\60010743\Desktop\proxy.log').each{|line| line}
	end

	def create
		params[:plum].merge!({:user_id => 1})
		@log_path = Plum.new(params[:plum])
		#debugger
		@log_path.save
		@icp_path = params[:plum][:icp_path]
		@mns_path = params[:plum][:mns_path]
		@third_path = params[:plum][:third_party_path]
		#@display = File.readlines(@path).each{|line| line}
		@display = format_full_log(@icp_path)#.gsub(/\n/, '<br />')

		render template: "logpage/searchLog.html"
	end

	def apResponse
		@log_path = Plum.new
		@ap_file_path = params[:plum][:ap_file_path]
		#@ref_id = params[:plum][:ref_id]
		path = Plum.find_by_user_id(1)
		message_id = fetch_message_id_from_ap(@ap_file_path)
		@ref_id     = Hmss.reference_id_for_ap_request(message_id)
		@icp_path, @mns_path, @third_party_path = path.icp_path, path.mns_path, path.third_party_path
		@proxy_data = fetch_ap_response_proxy_data(path.third_party_path, @ap_file_path)
		@icp_data   = fetch_ce_data(@icp_path, @ref_id)
		@mns_data 	= fetch_mns_data(@mns_path, @ref_id)
		
		render template: "logpage/searchLog.html"
	end
end
