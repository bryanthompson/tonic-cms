require "tonic-cms/version"
require "rest_resource"

module Tonic
  module Cms
    @@api_key, @@service_url, @@service_port = "", "v3.drinkyourtonic.com", "443"
 
    def self.api_key=(x)
      @@api_key = x
      update_resource_connections
    end
    def self.service_url=(x) 
      @@service_url = x
      update_resource_connections
    end
    def self.service_port=(x)
      @@service_port = x
      update_resource_connections
    end

    def self.api_key; @@api_key; end
    def self.service_url; @@service_url; end
    def self.service_port; @@service_port; end
  
    def self.connection
      { :username => api_key, :server => service_url, 
        :port => service_port, :url_prefix => "/api/v1" }
    end

    private  

    def self.update_resource_connections
      Tonic::Tag.set_connection self.connection
    end 
  end

  class Tag
    include RestResource::Model
    attr_reader :created_at, :updated_at
    attr_accessor :field_type, :key, :value, :page_id
    
    def self.all
      self.request(:get, "/content_tags")
    end    

    def self.get(key)
      self.request(:get, "/content_tags/#{key}")
    end    
    
    def self.set(key, field_type, value, options = {})
      options.merge!(:key => key, :value => value, :field_type => field_type)
      self.request(:post, "/content_tags", options)
    end
  end
  
  class Database
  end
  
  class Record
  end

  class Query
  end

  class Page
  end

  class Site
  end

end
