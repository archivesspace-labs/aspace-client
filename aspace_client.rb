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




JSONModel::init( :client_mode => true, :url => "http://localhost:8089", 
               :allow_other_unmapped => false,
               :enum_source => ClientEnumSource.new )


# login the user.
uri = JSONModel(:user).uri_for("admin/login")
response = JSONModel::HTTP.post_form(uri, :password => '84Admin')
JSONModel::HTTP.current_backend_session = ASUtils.json_parse(response.body)["session"]


repo = JSONModel(:repository).from_hash({ :repo_code => "123#{Time.now}", :name => "demo#{Time.now}" }).save
JSONModel.set_repository(repo)


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
file = CSV.open("names_out.csv", "wb") 
count = ( JSONModel::HTTP.get_json( JSONModel(:agent_person).uri_for, :all_ids => true ).length / 10 ) + 1

( 1 ... count ).each do |c| 
	JSONModel(:agent_person).all(:page => c )["results"].each do |person|			
		person["names"].each do |name|
			file << [ "Bob #{name["sort_name"]}", person["uri"] ]	
		end
	end
end

file.close

CSV.foreach('names_out.csv') do |row|
	name = row.first
	id = row.last.split("/").last
	person = JSONModel(:agent_person).find(id)
	person["names"].first["primary_name"] = name.upcase
	person["names"].first["title"] = "Esq."
	person.save
end

