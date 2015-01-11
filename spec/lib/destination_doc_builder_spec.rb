require 'destination_doc_builder.rb'
require 'pry'

RSpec.describe DestinationData do
  describe ".initialize" do
    let (:doc_builder) { DestinationDocBuilder.new({},"#{Dir.pwd}/spec/support/test_output_folder")}
    it "should initialize correctly" do
      expect(doc_builder.class).to equal(DestinationDocBuilder)
    end

    it "should link the data to the template" do
      new_content = DestinationContent.new({
        title_ascii: "the name",
        weather: ["always sunny"],
        transport: {local: ["buses are great"]},
        introductions: ["Good place to visit"]
        })
      new_data = DestinationData.new(
        {
          atlas_id: 1,
          parent_atlas_id: 2,
          parent_name: "parent",
          name: "name",
          content: new_content,
          child_node_ids: ["12345","678910"]
        })
      template_output = doc_builder.populate_template(new_data)
      expect(template_output).to match /Good place to visit/
      #out = File.open("#{Dir.pwd}/output/data.html","w")
      #out.puts template_output
      #out.close
    end

    it "should write the template to the file" do
      file_puts_double = double("puts")
      expect(file_puts_double).to receive(:puts).and_return(nil)
      expect(file_puts_double).to receive(:close).and_return(nil)
      expect(doc_builder).to receive(:populate_template).and_return(nil)
      expect(File).to receive(:open).and_return(file_puts_double)
      doc_builder.write_template_to_file({},"outfile")
    end
  end

  describe "link builders" do
    let (:doc_builder) {DestinationDocBuilder.new({
       1 => DestinationData.new({
        atlas_id: 1,
        parent_atlas_id: 2,
        parent_name: "parent",
        name: "child",
        content: DestinationContent.new({
          title_ascii: "child",
          weather: ["always sunny"],
          transport: {local: ["buses are great"]},
          introductions: ["Good place to visit"]
        }),
        child_node_ids: []
        }),
       2 => DestinationData.new({
        atlas_id: 2,
        parent_atlas_id: nil,
        parent_name: nil,
        name: "parent",
        content: DestinationContent.new({
          title_ascii: "parent",
          weather: ["always sunny"],
          transport: {local: ["buses are great"]},
          introductions: ["Good place to visit"]
        }),
        child_node_ids: [1]
        })
      },
      "#{Dir.pwd}/spec/support/test_output_folder")}

    it "should return the displayable name and url for a destination" do
      expect(doc_builder.doc_data[2].content).to receive(:place_name).and_return("A big far away place")
      expect(doc_builder).to receive(:doc_link).and_return("/aparentlink")

      name,link = doc_builder.get_link_info(2)
      expect(name).to match "A big far away place"
      expect(link).to match "aparentlink"
    end

    it "should return file name to where a document would be saved" do
      expect(doc_builder.doc_data[1]).to receive(:slug).and_return("slug")
      filename = doc_builder.doc_file_name(doc_builder.doc_data[1])
      expect(filename).to match "#{Dir.pwd}/spec/support/test_output_folder/slug.html"
    end

    it "should return the link that navigates to where the document can be viewed" do
      expect(doc_builder).to receive(:doc_file_name).and_return("mylink")
      filename = doc_builder.doc_link(doc_builder.doc_data[1])
      expect(filename).to match "mylink"
    end
  end

end