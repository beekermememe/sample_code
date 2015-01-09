require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'destination_content'
require 'destination_data'

# Basic operational flow for using this Class

# get the infile name
# open with Nokogiri
# handle errors if need be
# populate objects
# return objects back

# data is of the format

#  <top node>
#    <sub-node>
#    <sub-node>

# So we will read in top nodes create parent_destinations
# then read through each parent_destination and create child docs
# --- in the future we could do this recursively until all levels are processed
# --- we should be able to traverse up and down programmatically at that point

# once this is done, we can create a lookup table with the destination and the atlas id
# then we can go through the destinations an update the content for eash destination object

class DestinationDataIngestor

  def initialize(files_to_process = {taxonomy_file: "", destinations_file: ""})
    @taxonomy_file = files_to_process[:taxonomy_file]
    @destinations_file = files_to_process[:destinations_file]
  end

  def ingest
    return "one filename is blank" if @taxonomy_file == "" || @destinations_file == ""
    taxonomy_doc = read_taxonomy
    destinations_doc = read_destinations
  end

  def read_taxonomy
    read_file(@taxonomy_file)
  end

  def read_destinations
    read_file(@destinations_file)
  end

  def read_file(filename)
    return_object = nil
    begin
      f = File.open(filename)
      return_object = Nokogiri::XML(f)
      f.close
    rescue Exception => e
      return_object = "Failed to read - #{filename} : #{e.message}"
    end
    return_object
  end

  def create_data_objects(taxonomy_doc,destinations_doc)

  end

  def find_deepest_node(taxonomy_doc)
    xpath = ["taxonomies","taxonomy","node"]
    nodecount = taxonomy_doc.xpath("/" + xpath.join("/")).count
    while(nodecount > 0)
      xpath << "node"
      nodecount = taxonomy_doc.xpath("/" + xpath.join("/")).count
    end

    #pop off node that did not have any count and then we have the deeped node

    xpath.pop
    return xpath
  end

  def build_data_objects_from_place_info_data(existing_object_lookup, new_place_info)
    if(!existing_object_lookup[new_place_info[:atlas_id]]) # The place does not exist
      
    end

    if(!existing_object_lookup[new_place_info[:parent_atlas_id]]) # The parent place does not exist
      
    end
    return existing_object_lookup

  end

  def get_place_info_and_parent_place_info_from_node_xpath(taxonomy_doc,xpath)
    data_objects = []
    taxonomy_doc.xpath("/" + xpath.join("/")).each do |node|
      atlas_id = node.attributes["atlas_node_id"].value
      parent_atlas_id = node.parent.attributes["atlas_node_id"].value
      placename = get_place_name(node.children)
      parent_placename =  get_place_name( node.parent.children)
      data_objects << {atlas_id: atlas_id, parent_atlas_id: parent_atlas_id, placename: placename, parent_placename: parent_placename}
    end
    puts data_objects
    data_objects
  end

  def get_place_name(node_children)
    node_children.each do |child_of_node|
      if child_of_node.class == Nokogiri::XML::Element
        return child_of_node.children[0].text
      end
    end
    return "unknown"
  end
end