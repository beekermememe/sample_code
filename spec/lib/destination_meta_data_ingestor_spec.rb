require 'destination_meta_data_ingestor.rb'
require 'pry'

RSpec.describe DestinationMetaDataIngestor do
  describe ".initialize" do
    it "should create the new object" do
      expect(DestinationMetaDataIngestor.new({destinations_file: "destinations_file.xml"}).class).to equal(DestinationMetaDataIngestor)
    end
  end

  describe ".readfile" do
    it "should return a fail string if it cannot open the file" do
      badFileIngestor = DestinationMetaDataIngestor.new({destinations_file: "badfile.xml"})
      expect(badFileIngestor.read_destinations).to match "Failed to read - badfile.xml : No such file or directory @ rb_sysopen - badfile.xml"
    end

    it "shoud return an object if the file is good" do
      goodFileIngestor = DestinationMetaDataIngestor.new({destinations_file: "#{Dir.pwd}/spec/support/destinations_test_file.xml"})
      expect(goodFileIngestor.read_destinations.class).to match(Nokogiri::XML::Document)
    end
  end

  describe ".ingest" do
    it "should not allow the object to run the ingest if no file is sent" do
      badObject = DestinationMetaDataIngestor.new
      expect(badObject.ingest).to match("filename is blank")
    end
  end


  context "xml doc parsing" do
    let(:xml_doc) {
       DestinationMetaDataIngestor.new({
        destinations_file: "#{Dir.pwd}/spec/support/destinations_test_file.xml"
       }).read_destinations.xpath("/destinations/destination")[0]
    }

    let(:ingestor) {
      DestinationMetaDataIngestor.new({
        destinations_file: "#{Dir.pwd}/spec/support/destinations_test_file.xml"
    })}

    describe ".get_destination_introductions" do
      it "should return an array of the introduction paragraphs for an atlas_id" do
        intros = ingestor.get_destination_introductions(xml_doc)
        expect(intros.length).to equal 1
      end
    end

    describe ".get_destination_history" do
      it "should return an array of the history paragraphs for an atlas_id" do
        intros = ingestor.get_destination_history(xml_doc)
        expect(intros.length).to equal 12
      end
    end

    describe ".get_destination_practical_information" do
      it "should return 2 arrays - before_you_go, dangers_and_annoyances for an atlas_id" do
        before_you_go, dangers_and_annoyances = ingestor.get_destination_practical_information(xml_doc)
        expect(before_you_go.length).to equal 8
        expect(dangers_and_annoyances.length).to equal 4
      end
    end

    describe ".get_destination_weather" do
      it "should return an array of the weather paragraphs for an atlas_id" do
        intros = ingestor.get_destination_weather(xml_doc)
        expect(intros.length).to equal 1
      end
    end

    describe ".get_destination_transport" do
      it "should return 2 arrays - before_you_go, dangers_and_annoyances for an atlas_id" do
        getting_around_car, getting_around_local = ingestor.get_destination_transport(xml_doc)
        expect(getting_around_car.length).to equal 3
        expect(getting_around_local.length).to equal 1
      end
    end

    describe ".parse_xml_file" do
      it "should parse everything without an exception and return a hash of data" do
        doc_data = ingestor.parse_xml_file(ingestor.read_destinations)
        expect(doc_data.count).to equal 24
        expect(doc_data['355064'].count).to equal 7
      end
    end
  end
end
