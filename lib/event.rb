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

  def get_years_available
    # https://iwf.sport/results/results-by-events/results-by-events-old-bw/
    # https://iwf.sport/results/results-by-events/
    # old_bw = Nokogiri::HTML(open(""))
    years = Array.new
    urls = ["https://iwf.sport/results/results-by-events/", "https://iwf.sport/results/results-by-events/results-by-events-old-bw/"]

    urls.each do |url|
      events_page = Nokogiri::HTML(open(url))

      # events_page.css(".results_by_events select option").attribute("value").each do |year|
      events_page.css(".results_by_events select").first.css("option").each do |year|
        # puts year.text
        years.push(year.text) unless years.include?(year.text)
      end
    end
    puts years
  end

  def get_list_of_events(year)
    # Nokogiri::HTML(open("https://iwf.sport/results/results-by-events/?event_year=2022"))
    if year > 2018
      get_new_bodyweight_events(year)
    elsif year < 2018
      get_old_bodyweight_events(year)
    elsif year == 2018
      get_2018_events
    end
  end

  def get_old_bodyweight_events(year)
    doc = Nokogiri::HTML(open("https://iwf.sport/results/results-by-events/results-by-events-old-bw/?event_year=#{year}"))
  end

  def get_new_bodyweight_events(year)
    Nokogiri::HTML(open("https://iwf.sport/results/results-by-events/?event_year=#{year}"))
  end

  def get_2018_events
  end

  def get_events_from_location
  end
end

# binding.pry

# Event.new.get_years_available
