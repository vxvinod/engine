class LogpageController < ApplicationController
include LogpageHelper
	def searchLog
		@log = PathLocation.new
		#@display = File.readlines('C:\Users\60010743\Desktop\proxy.log').each{|line| line}
	end

	def create
		@log = PathLocation.new
		@path = params[:path_location][:path]
		#@display = File.readlines(@path).each{|line| line}
		@display = format_full_log(@path)#.gsub(/\n/, '<br />')
		render template: "logpage/searchLog.html"
	end
end
