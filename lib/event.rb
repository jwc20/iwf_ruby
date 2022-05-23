require "nokogiri"
require "open-uri"
require "pry"

class Event
  attr_accessor :name, :location, :date, :url

  @@all = []

  def initialize
    @@all << self
  end

  def self.all
    @@all
  end

  def self.reset_all
    @@all.clear
  end

  def get_page
    # Nokogiri::HTML(open("https://iwf.sport/results/results-by-events/?event_year=2022"))
    doc = Nokogiri::HTML(open("https://iwf.sport/results/results-by-events/?event_year=2022"))
    binding.pry
  end
end

# Event.new.get_page
