require 'destination_data_ingestor.rb'
require 'pry'

RSpec.describe DestinationDataIngestor do
  describe ".initialize" do
    it "should create the new object" do
      expect(DestinationDataIngestor.new({taxonomy_file: "taxonomy_file.xml", destinations_file: "destinations_file.xml"}).class).to equal(DestinationDataIngestor)
    end
  end

  describe ".ingest" do
    it "should not allow the object to run the ingest if no file is sent" do
      badObject = DestinationDataIngestor.new
      expect(badObject.ingest).to match("one filename is blank")
    end
  end

  describe ".read_taxonomy .read_destinations" do
    it "should return error strings if the input files have issues/missing" do
      badObject = DestinationDataIngestor.new({taxonomy_file: "taxonomy_file.xml", destinations_file: "destinations_file.xml"})
      taxonomy_object = badObject.read_taxonomy; destinations_object = badObject.read_destinations
      expect(taxonomy_object).to match("Failed to read - taxonomy_file.xml : No such file or directory @ rb_sysopen - taxonomy_file.xml")
      expect(destinations_object).to match("Failed to read - destinations_file.xml : No such file or directory @ rb_sysopen - destinations_file.xml")
    end


    it "should read the taxonomy_file and return an xml doc" do
      goodObject = DestinationDataIngestor.new({taxonomy_file: "#{Dir.pwd}/spec/support/taxonomy_test_file.xml", destinations_file: "#{Dir.pwd}/spec/support/destinations_test_file.xml"})
      taxonomy_object = goodObject.read_taxonomy
      expect(taxonomy_object.class).to match(Nokogiri::XML::Document)
    end

    it "should read the destinations_file and return an xml doc" do
      goodObject = DestinationDataIngestor.new({taxonomy_file: "#{Dir.pwd}/spec/support/taxonomy_test_file.xml", destinations_file: "#{Dir.pwd}/spec/support/destinations_test_file.xml"})
      destinations_object = goodObject.read_destinations
      expect(destinations_object.class).to match(Nokogiri::XML::Document)
    end
  end

  describe ".find_deepest_node" do
    it "should find how deep the nodes go and return an array to determine the xpath of the deepest node" do
      goodObject = DestinationDataIngestor.new({taxonomy_file: "#{Dir.pwd}/spec/support/taxonomy_test_file.xml", destinations_file: "#{Dir.pwd}/spec/support/destinations_test_file.xml"})
      taxonomy_object = goodObject.read_taxonomy
      expect(goodObject.find_deepest_node(taxonomy_object).count).to equal(6)
    end
  end

  describe ".get_place_info_and_parent_place_info_from_node_xpath" do
    it "should extract the place info and parent info" do
      goodObject = DestinationDataIngestor.new({taxonomy_file: "#{Dir.pwd}/spec/support/taxonomy_test_file.xml", destinations_file: "#{Dir.pwd}/spec/support/destinations_test_file.xml"})
      taxonomy_object = goodObject.read_taxonomy
      xpath = ["taxonomies","taxonomy","node","node","node","node"]
      data_objects = goodObject.get_place_info_and_parent_place_info_from_node_xpath(taxonomy_object,xpath)
      expect(data_objects.length).to equal(11)
      expect(data_objects[0][:atlas_id]).to match("355613")
      expect(data_objects[0][:parent_atlas_id]).to match("355612")
      expect(data_objects[0][:placename]).to match("Table Mountain National Park")
      expect(data_objects[0][:parent_placename]).to match("Cape Town")
    end
  end

  describe ".build_data_objects_from_place_info_data" do
    it "should create data objects based on the hash info passed" do
      info1 = {:atlas_id=>"355615", :parent_atlas_id=>"355614", :placename=>"Bloemfontein", :parent_placename=>"Free State"}
      info2 = {:atlas_id=>"355617", :parent_atlas_id=>"355616", :placename=>"Johannesburg", :parent_placename=>"Gauteng"}
    end

    it "should detect that the parent has already been created" do
      info1 = {:atlas_id=>"355617", :parent_atlas_id=>"355616", :placename=>"Johannesburg", :parent_placename=>"Gauteng"}
      info2 = {:atlas_id=>"355618", :parent_atlas_id=>"355616", :placename=>"Pretoria", :parent_placename=>"Gauteng"}
    end

    it "should detect that the main id has already been created - this reallt should not happen" do
      info1 = {:atlas_id=>"355615", :parent_atlas_id=>"355614", :placename=>"Bloemfontein", :parent_placename=>"Free State"}
      info2 = {:atlas_id=>"355615", :parent_atlas_id=>"355616", :placename=>"Bloemfontein", :parent_placename=>"Gauteng"}
    end
  end
end


