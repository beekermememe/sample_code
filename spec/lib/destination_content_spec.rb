require 'destination_content.rb'
require 'pry'

RSpec.describe DestinationContent do
  describe ".initialize" do
    it "should take the params passed and update the instance variables" do
      newcontent = DestinationContent.new({
        title_ascii: "the name",
        weather: ["always sunny"],
        transport: {local: ["buses are great"]},
        introductions: ["Good place to visit"]
        })
      expect(newcontent.introductions[0]).to match "Good place to visit"
      expect(newcontent.weather[0]).to match "always sunny"
      expect(newcontent.transport[0]).to match "buses are great"
      expect(newcontent.place_name).to match "the name"
    end
  end
end