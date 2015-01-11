require 'destination_data'
require 'erubis'

class DestinationDocBuilder
  attr_reader :doc_data
  def initialize(doc_data = nil,output_folder = nil, template_file = nil)
    @doc_data = doc_data
    @output_folder = output_folder.nil? ? "#{Dir.pwd}/output" : "#{Dir.pwd}/#{output_folder}"
    @template = template_file.nil? ? "#{Dir.pwd}/lib/templates/destination_template.eruby" : template_file
  end

  def populate_html_files
    @doc_data.each do |key,data|
      write_template_to_file(data)
    end
  end

  # This is where is set the output file name
  # we are using the slug to make a safe filename
  def doc_file_name(destination_data)
    @output_folder + "/" + destination_data.slug + ".html"
  end

  # Using the lookup hash we can find the place_name
  def child_link_info(child_id)
    child_doc = @doc_data[child_id]
    child_name = child_doc.nil? ? nil : child_doc.content.place_name
    child_link = child_doc.nil? ? nil : doc_link(child_doc)
    return child_name,child_link
  end

  # Using the lookup hash we can find the place_name
  def parent_link_info(parent_id)
    parent_doc = @doc_data[parent_id]
    parent_name = parent_doc.nil? ? nil : parent_doc.content.place_name
    parent_link = parent_doc.nil? ? nil : doc_link(parent_doc)
    return parent_name,parent_link
  end

  # Change this if you need to customize the url

  def doc_link(destination_data)
    doc_file_name(destination_data)
  end
  
  # returns a string that can be written to a file

  def populate_template(destination_data)
    eruby = Erubis::Eruby.new(File.read @template)
    data = destination_data

    child_links = []
    destination_data.child_node_ids.each do |id|
      child_name,child_link = child_link_info(id)
      next if child_name.nil?
      child_links << {name: child_name, link: child_link}
    end

    parent_name,parent_link = destination_data.parent_atlas_id.nil? ? [nil,nil] : parent_link_info(destination_data.parent_atlas_id)
    return eruby.result(binding()).to_s
  end

  def write_template_to_file(destination_data)
    File.open("#{doc_file_name(destination_data)}","w") do |f|
      f.puts populate_template(destination_data)
    end
  end



end