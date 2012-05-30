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
      Tonic::Cms.service_url = "localhost"
      Tonic::Cms.service_port = 8080
    end 
   
    it "should get all tags" do
      RestClient.should_receive(:get).and_return('{"list":[{"id":"4f8793f52aec135ad5000007","class":"tag","field_type":"text","key":"test-field","page":null},{"id":"4f88246c2aec135cdb000002","class":"tag","field_type":"text","key":"b60310","page":null},{"id":"4f88246f2aec135cdb000003","class":"tag","field_type":"text","key":"3c546f","page":null},{"id":"4f88524d2aec136331000003","class":"tag","field_type":"text","key":"test-tag","page":null}]}')

      res = Tonic::Tag.all
      res[0].key.should == "test-field"
      res[0].value.should == nil
    end
    
    it "should get a specific tag" do
      RestClient.should_receive(:get).and_return('{"id":"4f88524d2aec136331000003","class":"tag","field_type":"text","key":"test-tag","page":null,"value":"some value"}')
      tag = Tonic::Tag.get("test-tag")
      tag.key.should == "test-tag"
      tag.field_type.should == "text"
     tag.value.should == "some value"
    end
    
    it "should set a tag" do
      RestClient.should_receive(:post).and_return('{"id":"4f88524d2aec136331000003","class":"tag","field_type":"text","key":"test-tag","page":null,"value":"some value"}')

      tag = Tonic::Tag.set("test-tag", :text, "some value")
      tag.key.should == "test-tag"
      tag.field_type.should == "text"
      tag.value.should == "some value"
    end

    it "should delete a tag" do
      RestClient.should_receive(:delete).and_return('{"success":true}')
      
      res = Tonic::Tag.delete("test-tag")
      res.success?.should == true
    end

    # should tags have a .render method or should we pass the .rendered_content
    # in with the full 'get' for a tag?

    # .text, .image, .textile will always be setters
    it "should set a text field without a options/key block" do
      RestClient.should_receive(:post).and_return('{"id":"4f8858d32aec13725700000b","class":"tag","field_type":"text","key":"d7e5e6","page":null,"value":"Setting a text field and I don\'t care what key it gets."}')
      tag = Tonic::Tag.text("Setting a text field and I don't care what key it gets.")
      tag.key.should_not be_nil
    end

    it "should set a text field with a options/key block" do
      RestClient.should_receive(:post).and_return('{"id":"4f885c8b2aec137929000001","class":"tag","field_type":"text","key":"my-text-field","page":null,"value":"Setting a text with a predictable key"}')
      tag = Tonic::Tag.text("Setting a text with a predictable key", {:key => "my-text-field"})
      tag.key.should == "my-text-field"
    end

    it "should set a textile field without a options/key block" do
      RestClient.should_receive(:post).and_return('{"id":"4f885e1b2aec137929000004","class":"tag","field_type":"textile","key":"bca31d","page":null,"value":"Setting a textile field and I don\'t care what key it gets."}')
      tag = Tonic::Tag.textile("Setting a textile field and I don't care what key it gets.")
      tag.key.should_not be_nil
    end

    it "should set a textile field with a options/key block" do
      RestClient.should_receive(:post).and_return('{"id":"4f885e1b2aec137929000005","class":"tag","field_type":"textile","key":"my-textile-field","page":null,"value":"Setting a textile with a predictable key"}')
      tag = Tonic::Tag.textile("Setting a textile with a predictable key", {:key => "my-textile-field"})
      tag.key.should == "my-textile-field"
    end

    it "should set a html field without a options/key block" do
      RestClient.should_receive(:post).and_return('{"id":"4f885fc02aec137f2f000001","class":"tag","field_type":"html","key":"db7b9b","page":null,"value":"Setting a html field and I don\'t care what key it gets."}')
      tag = Tonic::Tag.html("Setting a html field and I don't care what key it gets.")
      tag.key.should_not be_nil
    end

    it "should set a html field with a options/key block" do
      RestClient.should_receive(:post).and_return('{"id":"4f885fc02aec137f2f000002","class":"tag","field_type":"html","key":"my-html-field","page":null,"value":"Setting a html with a predictable key"}')
      tag = Tonic::Tag.html("Setting a html with a predictable key", {:key => "my-html-field"})
      tag.key.should == "my-html-field"
    end

    #it "should search tags by keys"
    #it "should search tags by type"
    #it "should search tags by content"

    it "should set an image field with an options/key block" do
      i = File.open(File.join(File.dirname(__FILE__), "fixtures/landscape.jpeg"), "r")
      tag = Tonic::Tag.image(i)
      tag.src.should_not be_nil
    end
    it "should fill an image to a predictable size with options" do
      i = File.open(File.join(File.dirname(__FILE__), "fixtures/landscape.jpeg"), "r")
      tag = Tonic::Tag.image(i, { :key => "abcabc", :width => 450, :height => 50, :mode => "fill" })
      tag.key.should == "abcabc"
      # TODO: pull the image and look at the dimensions
    end
    it "should fit an image to a predictable size with options" do
      i = File.open(File.join(File.dirname(__FILE__), "fixtures/landscape.jpeg"), "r")
      tag = Tonic::Tag.image(i, { :key => "abcabc", :width => 450, :height => 250, :mode => "fit" })
      tag.key.should == "abcabc"
      # TODO: pull the image and look at the dimensions
    end
    it "should create versions of an image with options" do
      i = File.open(File.join(File.dirname(__FILE__), "fixtures/landscape.jpeg"), "r")
      tag = Tonic::Tag.image(i, { :key => "abcabc", :width => 450, :height => 250, :mode => "fit", 
        :versions => { 0 => { :key => "aasdfjhsdf" }, 1 => { :key => "sdkjfh" }} })
      tag.versions.length.should == 2
    end
    
  end
  
  context "with pages"

  context "with queries"

  context "with databases" do
    before :each do 
      Tonic::Cms.api_key = "6cc58d33e1484addd0290758"
      Tonic::Cms.service_url = "dev.v3.drinkyourtonic.com"
      Tonic::Cms.service_port = 80
    end 

    it "should get a list of databases" do
      RestClient.should_receive(:get).and_return('{"list":[{"id":"4f51134c2aec1376b7000004","class":"database","title":"Test DB","stub":"test_db","description":"","fields":[{"id":"4f514e8d2aec1316cd000007","class":"db_field","title":"asdf","default_value":"","format":"","order":1,"stub":"field_one","field_type":"string","required":false},{"id":"4f514e8d2aec1316cd000008","class":"db_field","title":"Zip","default_value":"","format":"^[0-9]{5}$","order":2,"stub":"field_two","field_type":"string","required":true},{"id":"4f516c852aec13252b000002","class":"db_field","title":"Field Three","default_value":"Testing 123","format":"","order":3,"stub":"field_three","field_type":"string","required":false},{"id":"4f60dc582aec136700000003","class":"db_field","title":"document","default_value":"","format":"","order":4,"stub":"document","field_type":"file","required":false}]}]}')
      list = Tonic::Database.all
      list[0].stub.should == "test_db"
      list[0].fields.should be_an Array
    end

    it "should get a single database" do
      RestClient.should_receive(:get).and_return('{"id":"4f51134c2aec1376b7000004","class":"database","title":"Test DB","stub":"test_db","description":"","fields":[{"id":"4f514e8d2aec1316cd000007","class":"db_field","title":"asdf","default_value":"","format":"","order":1,"stub":"field_one","field_type":"string","required":false},{"id":"4f514e8d2aec1316cd000008","class":"db_field","title":"Zip","default_value":"","format":"^[0-9]{5}$","order":2,"stub":"field_two","field_type":"string","required":true},{"id":"4f516c852aec13252b000002","class":"db_field","title":"Field Three","default_value":"Testing 123","format":"","order":3,"stub":"field_three","field_type":"string","required":false},{"id":"4f60dc582aec136700000003","class":"db_field","title":"document","default_value":"","format":"","order":4,"stub":"document","field_type":"file","required":false}]}')
      db = Tonic::Database.get("test_db")
      db.stub.should == "test_db"
    end
       
    it "should get records for a database" do
      RestClient.should_receive(:get).and_return('{"list":[{"id":"4f517e162aec132e10000003","class":"record","field_one":"a","field_two":"b","field_three":"c","document":null},{"id":"4f517e1d2aec132e19000004","class":"record","field_one":"Another","field_two":"hrm","field_three":"okay","document":null},{"id":"4f517f362aec132e10000008","class":"record","field_one":"asdf","field_two":"1","field_three":"asdfasdf","document":null},{"id":"4f517f6d2aec132e1000000d","class":"record","field_one":"aabc","field_two":"688504","field_three":"asdfasdf","document":null},{"id":"4f517fa42aec132e1900000a","class":"record","field_one":"asdf","field_two":"11111","field_three":"asdf","document":null},{"id":"4f518cac2aec133326000018","class":"record","field_one":"a","field_two":"00000","field_three":"","document":null},{"id":"4f52f9512aec131310000006","class":"record","field_one":"","field_two":"12345","field_three":"","document":null},{"id":"4f603ac52aec1357a1000003","class":"record","field_one":"a","field_two":"b","field_three":"c","document":null},{"id":"4f60df5d2aec136e70000004","class":"record","field_one":"","field_two":"12345","field_three":"","document":""}]}')
      records = Tonic::Record.where(:database => "test_db")
      records.each.should be_an Enumerator
    end

    it "should get a single record" do
      RestClient.should_receive(:get).and_return('{"id":"4f517e162aec132e10000003","class":"record","field_one":"a","field_two":"b","field_three":"c","document":null}')
      rec = Tonic::Record.get("test_db", "4f517e162aec132e10000003")
      rec.should be_a Tonic::Record
      rec.id.should == "4f517e162aec132e10000003"
      rec.field_one.should == "a"
    end

    it "should create a record" do
      RestClient.should_receive(:post).and_return('{"id":"4f88a3a22aec133927000008","class":"record","field_one":"y","field_two":"12345","field_three":null,"document":null}')
      rec = Tonic::Record.create(:record => { :field_one => "y", :field_two => 12345}, :database => "test_db")
      rec.field_one.should == "y"
    end

    
    it "should delete a record" do
      RestClient.should_receive(:get).and_return('{"id":"4f517e162aec132e10000003","class":"record","database":"test_db","field_one":"a","field_two":"b","field_three":"c","document":null}')
      rec = Tonic::Record.get("test_db", "4f517e162aec132e10000003")
      RestClient.should_receive(:delete).and_return('{"success":true}')
      rec.delete.success?.should == true
    end

    it "should update a record" do
      RestClient.should_receive(:post).and_return('{"id":"4f517e162aec132e10000003","class":"record","database":"test_db","field_one":"Updated!","field_two":"b","field_three":"c","document":null}')
      rec = Tonic::Record.update("4f517e162aec132e10000003", {:database => "test_db", :record => {:field_one => "Updated!"}})
      rec.field_one.should == "Updated!"
    end

    it "should search records"

    # it should paginate all list results
  end

end
