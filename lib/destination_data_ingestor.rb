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

  # we return a lookup table from here - we use the atlas ID as the key for the data container that we
  # use later to help populate the template of the web page that is generated

  def ingest
    return "one filename is blank" if @taxonomy_file == "" || @destinations_file == ""
    taxonomy_doc = read_taxonomy
    destinations_doc = read_destinations

    xpath = find_deepest_node(taxonomy_doc)
    destinations_lookup = {}
    get_place_info_and_parent_place_info_from_node_xpath(taxonomy_doc,xpath).each do |data_object|
      destinations_lookup = build_data_objects_from_place_info_data(destinations_lookup,data_object)
    end
    destinations_lookup
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

  # this is used to create a hash that we will use to generate the data objects later
  def get_place_info_and_parent_place_info_from_node_xpath(taxonomy_doc,xpath)
    data_objects = []
    while xpath.count("node") > 1
      taxonomy_doc.xpath("/" + xpath.join("/")).each do |node|
        atlas_id = node.attributes["atlas_node_id"].value
        parent_atlas_id = node.parent.attributes["atlas_node_id"].value
        placename = get_place_name(node.children)
        parent_placename =  get_place_name( node.parent.children)
        data_objects << {atlas_id: atlas_id, parent_atlas_id: parent_atlas_id, name: placename, parent_name: parent_placename}
      end
      xpath.pop
    end
    data_objects
  end

  # a helper to assist in getting the place name from the XML doc entry being processed
  def get_place_name(node_children)
    node_children.each do |child_of_node|
      if child_of_node.class == Nokogiri::XML::Element
        return child_of_node.children[0].text
      end
    end
    return "unknown"
  end

  # How deep do the nodes go - we will start at the deepest when creating the data containers
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

  # Here we update the lookup table when we process a new set of xpath/node information
  def build_data_objects_from_place_info_data(existing_object_lookup, new_place_info)
    if(!existing_object_lookup[new_place_info[:atlas_id]]) # The place does not exist
      existing_object_lookup[new_place_info[:atlas_id]] = build_destination_data_object(new_place_info)
    else
      existing_object_lookup[new_place_info[:atlas_id]] = update_destination_data_object(existing_object_lookup[new_place_info[:atlas_id]],new_place_info)
    end

    if(!existing_object_lookup[new_place_info[:parent_atlas_id]]) # The parent place does not exist
      existing_object_lookup[new_place_info[:parent_atlas_id]] = build_parent_destination_data_object(new_place_info)
    end
    
    existing_object_lookup = add_child_node_to_parent(existing_object_lookup,new_place_info[:parent_atlas_id],new_place_info[:atlas_id])
    return existing_object_lookup
  end

  def build_destination_data_object(seed_data)
    DestinationData.new(seed_data)
  end

  def build_parent_destination_data_object(seed_data)
    parent_seed_data = {atlas_id: seed_data[:parent_atlas_id], name: seed_data[:parent_name]}
    DestinationData.new(parent_seed_data)
  end

  def add_child_node_to_parent(lookup, parent_id, child_id)
    lookup[parent_id] = lookup[parent_id].add_child_node lookup[child_id]
    return lookup
  end

  # We need a helper method to update an existing data object
  def update_destination_data_object(existing_data,new_data)
    existing_data.update(new_data)
    return existing_data
  end

end