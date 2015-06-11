require "rexml/document"
require 'debugger'
module LogpageHelper
	def format_full_log path
		#debugger
		whole_out = ""
		lines = File.readlines(@path).each{|line| line}
		lines.join('').split("Response").each do |data|
			#debugger
			doc = REXML::Document.new data
			out=""
			doc.write(out,1)
			whole_out << out
		end

		whole_out
	end
end
