require 'destination_data.rb'
require 'pry'

RSpec.describe DestinationDataIngestor do
  describe ".initialize" do
    it "should populate model data" do
      newDestination = DestinationData.new({atlas_id: 1, parent_atlas_id: 2, parent_name: "parent", name: "name"})
      expect(newDestination.atlas_id).to equal 1
      expect(newDestination.parent_atlas_id).to equal 2
      expect(newDestination.destination_name).to match "name"
      expect(newDestination.parent_name).to match "parent"
      expect(newDestination.child_node_slugs).to match []
    end

  end

  describe ".slug methods" do
    let(:destination) {  DestinationData.new({atlas_id: 1, parent_atlas_id: 2, parent_name: "parent", name: "name"}) }
    it "should return the parent slug" do
      expect(destination.parent_slug).to match("parent-2")
    end

    it "should return the slug" do
      expect(destination.slug).to match("name-1")
    end
  end

  describe ".update" do
    it "shoudl update the name and id properties of the object" do
      parent = DestinationData.new({atlas_id: 4, name: "parent"})
      parent.update({atlas_id: 4, parent_atlas_id: 2, parent_name: "grandparent", name: "parent"})
      expect(parent.atlas_id).to equal 4
      expect(parent.parent_atlas_id).to equal 2
      expect(parent.destination_name).to match "parent"
      expect(parent.parent_name).to match "grandparent"
      expect(parent.child_node_slugs).to match []
    end
  end

  describe ".add_child_node" do
    it "should add the slug of the child node" do
      parent = DestinationData.new({atlas_id: 4, name: "parent"})
      child = DestinationData.new({atlas_id: 1, parent_atlas_id: 4, parent_name: "parent", name: "name"})
      parent.add_child_node child
      expect(parent.child_node_slugs).to match [child.slug]
    end

  end
end
