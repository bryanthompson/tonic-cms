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
      Tonic::Database.set_connection self.connection
    end 
  end

  class Tag
    include RestResource::Model
    attr_reader :created_at, :updated_at
    attr_accessor :field_type, :key, :value, :page_id, :options
    
    def self.all
      self.request(:get, "/content_tags")
    end    

    def self.get(key)
      self.request(:get, "/content_tags/#{key}").tag
    end    
    
    def self.set(key, field_type, value, options = {})
      options.merge!(:key => key, :value => value, :field_type => field_type)
      self.request(:post, "/content_tags", options).tag
    end
    
    def self.delete(key)
      self.request(:delete, "/content_tags/#{key}")
    end
    
    # text fields are sanitized for html/js/etc.
    def self.text(value, options = {})
      self.set(options[:key], "text", value, options)
    end

    # textile fields are sanitized and rendered to textile
    def self.textile(value, options = {})
      self.set(options[:key], "textile", value, options)
    end

    # html fields accept html, so... you might want to pre-whitelist on your own
    def self.html(value, options = {})
      self.set(options[:key], "html", value, options)
    end
    
  end
  
  class Database
    include RestResource::Model
    attr_reader :created_at, :updated_at
    attr_accessor :title, :stub, :description, :fields

    def self.all
      self.request(:get, "/databases").list
    end
    
    def self.get(stub)
      self.request(:get, "/databases/#{stub}").database
    end
  end

  class DbField
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
