require 'destination_data'

# a Destination can have many children sub destinations under it
# a Destination can have only one parent destination

class DestinationData
  attr_reader
  def initialize(initdata = {})
    @destination = initdata[:country]
    @content = nil
    @atlas_id = initdata[:atlas_id]
    @parent_atlas_id = initdata[:parent_atlas_id]
    @destination_name = initdata[:name]
    @parent_name = initdata[:parent_name]
  end

  def build_destination_content

  end

  def get_child_destinations

  end

  def get_parent_destination

  end

end