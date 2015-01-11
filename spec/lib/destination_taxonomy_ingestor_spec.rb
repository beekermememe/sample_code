require 'destination_taxonomy_ingestor.rb'

RSpec.describe DestinationTaxonomyIngestor do
  describe ".initialize" do
    it "should create the new object" do
      expect(DestinationTaxonomyIngestor.new({taxonomy_file: "taxonomy_file.xml"}).class).to equal(DestinationTaxonomyIngestor)
    end
  end

  describe ".ingest" do
    it "should not allow the object to run the ingest if no file is sent" do
      badObject = DestinationTaxonomyIngestor.new
      expect(badObject.ingest).to match("filename is blank")
    end
  end

  describe ".read_taxonomy .read_destinations" do
    it "should return error strings if the input files have issues/missing" do
      badObject = DestinationTaxonomyIngestor.new({taxonomy_file: "taxonomy_file.xml"})
      taxonomy_object = badObject.read_taxonomy;
      expect(taxonomy_object).to match("Failed to read - taxonomy_file.xml : No such file or directory @ rb_sysopen - taxonomy_file.xml")
    end


    it "should read the taxonomy_file and return an xml doc" do
      goodObject = DestinationTaxonomyIngestor.new({taxonomy_file: "#{Dir.pwd}/spec/support/taxonomy_test_file.xml"})
      taxonomy_object = goodObject.read_taxonomy
      expect(taxonomy_object.class).to match(Nokogiri::XML::Document)
    end

  end

  describe ".find_deepest_node" do
    it "should find how deep the nodes go and return an array to determine the xpath of the deepest node" do
      goodObject = DestinationTaxonomyIngestor.new({taxonomy_file: "#{Dir.pwd}/spec/support/taxonomy_test_file.xml"})
      taxonomy_object = goodObject.read_taxonomy
      expect(goodObject.find_deepest_node(taxonomy_object).count).to equal(6)
    end
  end

  describe ".get_place_info_and_parent_place_info_from_node_xpath" do
    it "should extract the place info and parent info" do
      goodObject = DestinationTaxonomyIngestor.new({taxonomy_file: "#{Dir.pwd}/spec/support/taxonomy_test_file.xml"})
      taxonomy_object = goodObject.read_taxonomy
      xpath = ["taxonomies","taxonomy","node","node","node","node"]
      data_objects = goodObject.get_place_info_and_parent_place_info_from_node_xpath(taxonomy_object,xpath)
      expect(data_objects.length).to equal(23)
      expect(data_objects[0][:atlas_id]).to match("355613")
      expect(data_objects[0][:parent_atlas_id]).to match("355612")
      expect(data_objects[0][:name]).to match("Table Mountain National Park")
      expect(data_objects[0][:parent_name]).to match("Cape Town")
    end
  end

  describe ".build_data_objects_from_place_info_data" do
    it "should create data objects based on the hash info passed" do
      goodObject = DestinationTaxonomyIngestor.new({taxonomy_file: "#{Dir.pwd}/spec/support/taxonomy_test_file.xml"})
      double1 = double("mock", :add_child_node => { object: "data"})
      double2 = double("mock", :add_child_node => double1)
      allow(DestinationData).to receive(:new ).and_return( double2 ) 

      info1 = {:atlas_id=>"355615", :parent_atlas_id=>"355614", :name=>"Bloemfontein", :parent_name=>"Free State"}
      info2 = {:atlas_id=>"355617", :parent_atlas_id=>"355616", :name=>"Johannesburg", :parent_name=>"Gauteng"}
      lookup = {}
      lookup = goodObject.build_data_objects_from_place_info_data(lookup, info1)
      lookup = goodObject.build_data_objects_from_place_info_data(lookup, info2)
      expect(lookup.count).to equal 4
    end

    it "should detect that the parent has already been created" do
      goodObject = DestinationTaxonomyIngestor.new({taxonomy_file: "#{Dir.pwd}/spec/support/taxonomy_test_file.xml"})
      double1 = double("mock", :add_child_node => { object: "data"})
      double2 = double("mock", :add_child_node => double1)
      allow(DestinationData).to receive(:new ).and_return( double2 ) 

      lookup = {}
      info1 = {:atlas_id=>"355617", :parent_atlas_id=>"355616", :name=>"Johannesburg", :parent_name=>"Gauteng"}
      info2 = {:atlas_id=>"355618", :parent_atlas_id=>"355616", :name=>"Pretoria", :parent_name=>"Gauteng"}
      lookup = goodObject.build_data_objects_from_place_info_data(lookup, info1)
      lookup = goodObject.build_data_objects_from_place_info_data(lookup, info2)
      expect(lookup.count).to equal 3
    end

    it "should detect that the main id has already been created - this reallt should not happen" do
      goodObject = DestinationTaxonomyIngestor.new({taxonomy_file: "#{Dir.pwd}/spec/support/taxonomy_test_file.xml"})
      double1 = double("mock", :add_child_node => { object: "data"})
      double2 = double("mock", :add_child_node => double1, :update => { object: "data"})
      allow(DestinationData).to receive(:new ).and_return( double2 ) 

      lookup = {}
      info1 = {:atlas_id=>"355615", :parent_atlas_id=>"355614", :name=>"Bloemfontein", :parent_name=>"Free State"}
      info2 = {:atlas_id=>"355615", :parent_atlas_id=>"355616", :name=>"Bloemfontein", :parent_name=>"Gauteng"}
      lookup = goodObject.build_data_objects_from_place_info_data(lookup, info1)
      lookup = goodObject.build_data_objects_from_place_info_data(lookup, info2)
      expect(lookup.count).to equal 3
    end
  end
end


