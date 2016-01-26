$: << "#{File.dirname(__FILE__)}" unless $:.include? File.dirname(__FILE__)

require "aspace_client/jsonmodel"
require "aspace_client/asutils"
require "aspace_client/memoryleak"
require "aspace_client/client_enum_source"
require "aspace_client/jsonmodel_i18n_mixin"
require 'aspace_client/jsonmodel_client'
require 'aspace_client/archivesspace_json_schema.rb'

include JSONModel 

module AspaceClient

end
