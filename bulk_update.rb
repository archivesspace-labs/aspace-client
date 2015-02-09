#!/usr/bin/env ruby
require 'json'
require 'rest_client'
require "highline/import"

# This is a way to bulk update objects in ArchivesSpace using a JSON template 
# It's in Ruby and you'll need to have rest_client and highline installed ( gem install rest_client highline ) 
# run it with ruby ./bulk_update.rb
# good luck and backup and use at your own risk! 


# this is the bit that does the updating. You pass it a backend URL, the username, password, the type of object you're 
# updating, the repo your updating, and the json template. phew. 

def update( backend, user, pwd, klass, repo, json )
	token = { "X-ArchivesSpace-Session" => JSON.parse( RestClient.post "#{backend}/users/#{user}/login", { password: pwd } )["session"] }
  	# we get all the ids for the record type in the repo and iterate
	JSON(RestClient.get( "#{backend}/repositories/#{repo}/#{klass}?all_ids=true", token )).each do |id|
		thingy = JSON(RestClient.get( "#{backend}/repositories/#{repo}/#{klass}/#{id}", token ) )
		thingy.merge!(json) # merge in our template values
		print "#{id} : "
		response = RestClient.post( "#{backend}/repositories/#{repo}/#{klass}/#{id}", thingy.to_json, token ) # update the record
		puts response
	end
end

# this is like the main method. 
if __FILE__ == $0


	backend = ask("Enter your backend URL ==> ") { |q| q.default = "http://localhost:4567"; q.validate = /https?:\/\/[\S]+/ } 
	user = ask("Enter your user name ==> ") { |q| q.default = "admin" } 
	pwd = ask("Enter your password   ==> ")  { |q| q.default = "admin" } 
	repo = ask("Enter the repo number  ==> ") { |q| q.default = "2" } 
	
	klasses = %w{ accessions archival_objects classification_terms classifications digital_object_components digital_objects events resources }
	puts "Possible types : #{klasses.join(" ")}"
	klass = ask("Enter your desired type ==> ") { |q| q.in = klasses }  

	json = JSON.parse(IO.read("template.json"))
    
	say("<%= color('YOUR JSON', BOLD) %>!")   
	puts JSON.pretty_generate(json)

	puts "You are about to update globally update all #{ klass }  in Repository #{ repo } with the JSON above."
	answer = ask("Enter 'yes' if this is what you want ==> ") { |q| q.default = 'nope' } 
  	
	if answer == 'yes'
		update( backend, user, pwd, klass, repo, json ) 
	else
		puts "Not gonna do it. " 	
	end 
end
