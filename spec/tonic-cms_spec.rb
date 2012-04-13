require File.join(File.dirname(__FILE__), "../lib/tonic-cms.rb")

describe Tonic::Cms do
  context "should let us set things up" do
    it "should let us set our API key" do
      Tonic::Cms.api_key = 'asdf'
      Tonic::Cms.api_key.should == 'asdf'
    end
    
    it "should default to v3.drinkyourtonic.com as our server" do
      Tonic::Cms.service_url.should == "v3.drinkyourtonic.com"
    end
  
    it "should let us set a server manually" do
      Tonic::Cms.service_url = "localhost"
      Tonic::Cms.service_url.should == "localhost"
    end

    it "should let us set a server port manually" do
      Tonic::Cms.service_port = 80
      Tonic::Cms.service_port.should == 80
    end
    
    it "should combine service and api key info into a connection attr" do
      Tonic::Cms.api_key = "key"
      Tonic::Cms.service_url = "localhost"
      Tonic::Cms.service_port = 80
      Tonic::Cms.connection.should be_a Hash
      Tonic::Cms.connection[:username].should == "key"
      Tonic::Cms.connection[:server].should == "localhost"
      Tonic::Cms.connection[:port].should == 80
      Tonic::Cms.connection[:url_prefix].should == "/api/v1"
    end
  end

  context "with content tags" do
    before :each do 
      Tonic::Cms.api_key = "6cc58d33e1484addd0290758"
      Tonic::Cms.service_url = "dev.v3.drinkyourtonic.com"
      Tonic::Cms.service_port = 80
    end 
   
    it "should get all tags" do
      RestClient.should_receive(:get).and_return({:list => [
        {:class => "content_tag", :key => "test-tag", :value => "test value"}
      ]}.to_json)

      res = Tonic::Tag.all
      res.list[0].key.should == "test-tag"
      res.list[0].value.should == "test value"
    end
    
    it "should get a specific tag" do
      RestClient.should_receive(:get).and_return({
        :class => "content_tag", :key => "test-tag", :value => "test value",
        :field_type => "text"
      }.to_json)

      res = Tonic::Tag.get("test-tag")
      res.content_tag.key.should == "test-tag"
      res.content_tag.field_type.should == "text"
      res.content_tag.value.should == "test value"
    end
    
    it "should set a tag" do
      #RestClient.should_receive(:post).and_return({
      #  :class => "content_tag", :key => "test-tag", :value => "some value",
      #  :field_type => "text"
      #}.to_json)

      res = Tonic::Tag.set("test-tag", :text, "some value")
      res.content_tag.key.should == "test-tag"
      res.content_tag.field_type.should == "text"
      res.content_tag.value.should == "some value"
    end

  end

  context "with pages"

  context "with queries"

  context "with databases"

end
