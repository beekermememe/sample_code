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
      out = File.open("#{Dir.pwd}/output/data.html","w")
      out.puts template_output
      out.close
    end
  end
end