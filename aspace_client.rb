#!/usr/bin/env ruby

require "lib/jsonmodel"
require "lib/asutils"
require "lib/memoryleak"
require "lib/client_enum_source"
require "lib/jsonmodel_i18n_mixin"
require 'lib/jsonmodel_client'
require 'lib/archivesspace_json_schema.rb'

require 'csv'

include JSONModel 

JSONModel.set_repository(2)



JSONModel::init( :client_mode => true, :url => "http://localhost:8089", 
               :allow_other_unmapped => false,
               :enum_source => ClientEnumSource.new )


# login the user.
uri = JSONModel(:user).uri_for("admin/login")
response = JSONModel::HTTP.post_form(uri, :password => '84Admin')
JSONModel::HTTP.current_backend_session = ASUtils.json_parse(response.body)["session"]



# put the data in...

CSV.parse(open('names.csv')).each do |row|
	data = { "names" => [ { "primary_name" => row[0].strip, 
	"name_order" => "direct", "sort_name_auto_generate" => true,
	"source" => "local"} ] }
	
	
	date = row[1]
	if date.length > 1 and date.include?("-")
		data["dates_of_existence"] = [{"label" => "existence", "date_type" => "inclusive", "begin" => date.split("-").first.strip, "end" => date.split("-").last.strip } ]
	elsif date.length > 1
		data["dates_of_existence"] = [{ "label" => "existence", "date_type" => "single", "expression" => date.strip } ]
	end
	
	begin	
		 JSONModel(:agent_person).from_hash( data ).save
	rescue JSONModel::ValidationException => e
		 puts e.inspect
		 puts data
	end
end


# now pull it back out
file = File.open("names_out.csv", "w") 
count = ( JSONModel::HTTP.get_json( JSONModel(:agent_person).uri_for, :all_ids => true ).length / 10 ) + 1

( 1 ... count ).each do |c| 
	JSONModel(:agent_person).all(:page => c )["results"].each do |person|
		date = ""
		if person["dates_of_existence"].length > 0
			doe = person["dates_of_existence"].first
			if doe["expression"]
				date = doe["expression"]
			elsif doe["begin"] 
				date = doe["begin"] + " - " + doe["end"]
			end
				
		end				
		person["names"].each do |name|
			file << "\"#{name["sort_name"]}\", #{date}\n"
		end
	end

end

file.close


