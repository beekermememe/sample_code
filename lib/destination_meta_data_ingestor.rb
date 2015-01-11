require 'rubygems'
require 'bundler/setup'
require 'destination_content'
require 'destination_data'


class DestinationMetaDataIngestor

  def initialize(files_to_process = {destinations_file: ""})
    @destinations_file = files_to_process[:destinations_file]
  end


  def ingest
    return "filename is blank" if @destinations_file == ""
    destinations_doc = read_destinations
    destination_data = parse_xml_file(destinations_doc)
    return destination_data
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

  def parse_xml_file(xml_doc)
    lookup = {}
    xml_doc.xpath("/destinations/destination").each do |destination_xml|
      data_hash = {}
      data_hash[:atlas_id] = destination_xml.attributes["atlas_id"].value if destination_xml.attributes["atlas_id"]
      next unless data_hash[:atlas_id]
      data_hash[:title_ascii] = destination_xml.attributes["title-ascii"].value if destination_xml.attributes["title-ascii"]
      data_hash[:introductions] = get_destination_introductions(destination_xml)
      data_hash[:history] = get_destination_history(destination_xml)
      before_you_go, dangers_and_annoyances = get_destination_practical_information(destination_xml)
      data_hash[:practical_information] = {before_you_go: before_you_go, dangers_and_annoyances: dangers_and_annoyances}
      data_hash[:weather] = get_destination_weather(destination_xml)
      car,local = get_destination_transport(destination_xml)
      data_hash[:transport] = {car: car, local: local}
      lookup[data_hash[:atlas_id]] ||= data_hash
    end
    lookup
  end

  def get_destination_introductions(xml_doc)
    return_data = []
    return_data = []
    xml_doc.xpath("introductory/introduction/overview").each do |child_doc|
      return_data << child_doc.text.chomp unless child_doc.text.chomp == ""
    end
    return_data
  end

  def get_destination_history(xml_doc)
    return_data = []
    xml_doc.xpath("history/history/history").each do |child_doc|
      return_data << child_doc.text.chomp unless child_doc.text.chomp == ""
    end
    return_data
  end

  def get_destination_practical_information(xml_doc)
    before_you_go = []
    dangers_and_annoyances = []
    xml_doc.xpath("practical_information/health_and_safety/before_you_go").each do |child_doc|
      before_you_go << child_doc.text.chomp unless child_doc.text.chomp == ""
    end

    xml_doc.xpath("practical_information/health_and_safety/dangers_and_annoyances").each do |child_doc|
      dangers_and_annoyances << child_doc.text.chomp unless child_doc.text.chomp == ""
    end
    return before_you_go, dangers_and_annoyances
  end

  def get_destination_weather(xml_doc)
    return_data = []
    xml_doc.xpath("weather/when_to_go/overview").each do |child_doc|
      return_data << child_doc.text.chomp unless child_doc.text.chomp == ""
    end
    return_data
  end

  def get_destination_transport(xml_doc)
    getting_around_car = []
    getting_around_local = []
    xml_doc.xpath("transport/getting_around/car_and_motorcycle").each do |child_doc|
      getting_around_car << child_doc.text.chomp unless child_doc.text.chomp == ""
    end
    xml_doc.xpath("transport/getting_around/local_transport").each do |child_doc|
      getting_around_local << child_doc.text.chomp unless child_doc.text.chomp == ""
    end
    return getting_around_car, getting_around_local
  end
end