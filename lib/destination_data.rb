require 'rubygems'
require 'bundler/setup'
require 'stringex'

# a Destination can have many children sub destinations under it
# a Destination can have only one parent destination

class DestinationData

  attr_reader :atlas_id, :parent_atlas_id, :parent_name, :destination_name, :child_node_slugs

  def initialize(initdata = {})
    @content = nil
    @atlas_id = initdata[:atlas_id]
    @parent_atlas_id = initdata[:parent_atlas_id]
    @destination_name = initdata[:name]
    @parent_name = initdata[:parent_name]
    @child_node_slugs = []
  end

  def add_child_node(child_node)
    @child_node_slugs << child_node.slug unless @child_node_slugs.include?(child_node.slug)
    return self
  end

  def slug
    return "#{@destination_name} #{@atlas_id}".to_url
  end

  def parent_slug
    return "#{@parent_name} #{@parent_atlas_id}".to_url
  end

  def update(update_data)
    @atlas_id = update_data[:atlas_id] if update_data[:atlas_id]
    @parent_atlas_id = update_data[:parent_atlas_id] if update_data[:parent_atlas_id]
    @destination_name = update_data[:name] if update_data[:name]
    @parent_name = update_data[:parent_name] if update_data[:parent_name]
    return self
  end
end