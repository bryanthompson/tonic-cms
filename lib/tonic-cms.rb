require "tonic-cms/version"
require "addressable/uri"
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
      Tonic::Record.set_connection self.connection
    end 
  end

  class Tag
    include RestResource::Model
    attr_reader :created_at, :updated_at
    attr_accessor :field_type, :key, :value, :page_id, :options, :versions
    
    def self.all
      res = self.request(:get, "/content_tags")
      res.success? ? res.list : nil
    end    

    def self.get(key)
      res = self.request(:get, "/content_tags/#{key}")
      res.success? ? res.tag : nil
    end    
    
    def self.set(key, field_type, value, options = {})
      merged_opts = {:key => key, :value => value, :field_type => field_type, :options => options}
      self.request(:post, "/content_tags", merged_opts).tag
    end
    
    # TODO: Test
    def self.update(id, params = {})
      res = self.request(:post, "/content_tags/#{id}", params)
      res.success? ? res.tag : res.errors
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
    
    # image fields accept all sorts of images and options.
    def self.image(value, options = {})
      self.set(options[:key], "image", value, options)
    end
    
    def src
      return nil unless self.field_type == "image"
      value["location"]
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
    include RestResource::Model
    attr_reader :id, :created_at, :updated_at
    attr_accessor :database
  
    def initialize(params = {})
      # for now, we'll just set everything we get
      params.each do |param|
        instance_variable_set("@#{param[0]}", param[1])
      end
    end

    def self.get(database, id)
      self.request(:get, "/databases/#{database}/records/#{id}").record
    end
  
    # self.delete(database, id)
    # rec.delete
    
    # self.create
    # self.update
    # self.save
  
    def self.search(params = {})
      url = self.search_url("/databases/records", params)
      self.request(:get, url)
    end

    def self.create(params = {})
      # TODO: make sure we got a params[:database]
      res = self.request(:post, "/databases/#{params[:database]}/records", params)
      res.success? ? res.record : res.errors
    end
    def self.update(id, params = {})
      res = self.request(:post, "/databases/#{params[:database]}/records/#{id}", params)
      res.success? ? res.record : res.errors
    end

    def delete
      Record.request(:delete, "/databases/#{@database}/records/#{@id}")
    end

    # this gets properties off the record.  If the property doesn't exist, it will
    # raise an exception.  
    def method_missing(m, *args, &block)
      # if they accessed a setter, take the param. The API will throw a 'field does not exist'
      # error if they try pushing fields through that don't belong.
      if m.to_s =~ /^(.+)\=/ and args[0]
        instance_variable_set("@#{$1}", args[0])
      elsif attrs.keys.include?(m.to_s)
        attrs[m.to_s]
      else
        raise NoMethodError.new("NoMethodError")
      end
    end
  end

  class Query
  end

  class Page
  end

  class Site
  end

end
