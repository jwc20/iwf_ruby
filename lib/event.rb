require "nokogiri"
require "open-uri"
require "pry"
require "json"

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
    # Gets all years available in new bodyweight and old bodyweight events page
    years = Array.new
    urls = ["https://iwf.sport/results/results-by-events/", "https://iwf.sport/results/results-by-events/results-by-events-old-bw/"]

    urls.each do |url|
      events_page = Nokogiri::HTML(open(url))
      events_page.css(".results_by_events select").first.css("option").each do |year|
        # puts year.text
        years.push(year.text) unless years.include?(year.text)
      end
    end
    puts years
  end

  def make_events(year)
    get_events_page(year).css("#section-scroll div div.cards a").each do |post|
      event = Event.new
      event.name = post.css("div.container div div.col-md-5.col-12.not__cell__767__full p span").text
      event.location = post.css("div.container div div.col-md-3.col-4.not__cell__767 p").text.delete!("\n")
      event.date = post.css("div.container div div:nth-child(2) p").text.delete!("\n").rstrip
      event.url = post.attribute("href").value
    end
  end

  def print_events(years)
    make_events(years)
    Event.all.each do |event|
      if event.name
        puts "Name: #{event.name}"
        puts "Location: #{event.location}"
        puts "Date: #{event.date}"
        puts "Url #{event.url}"
      end
    end
  end

  def get_events_page(year)
    # def get_events_page(year, bw = nil)
    # Gets all events by year of competition
    if year > 2018
      get_new_bodyweight_events(year)
    elsif year < 2018
      get_old_bodyweight_events(year)
      # TODO: Get events for 2018 (new and old bodyweight)
      # elsif year == 2018

      # elsif year == 2018 && bw == "new"
      #   get_new_bodyweight_events(year)
      # elsif year == 2018 && bw == "old"
      #   get_old_bodyweight_events(year)
    end
  end

  def get_new_bodyweight_events(year)
    Nokogiri::HTML(open("https://iwf.sport/results/results-by-events/?event_year=#{year}"))
  end

  def get_old_bodyweight_events(year)
    Nokogiri::HTML(open("https://iwf.sport/results/results-by-events/results-by-events-old-bw/?event_year=#{year}"))
  end

  def get_2018_events
    old_bw = Nokogiri::HTML(open("https://iwf.sport/results/results-by-events/results-by-events-old-bw/?event_year=2018")).search("#section-scroll div.results")
    new_bw = Nokogiri::HTML(open("https://iwf.sport/results/results-by-events/?event_year=2018"))
    new_bw.at("#section-scroll div.results").add_child(old_bw)
  end

  def get_events_from_location
  end
end

# Event.new.get_years_available
#
# puts Event.new.make_events(2021).text
Event.new
binding.pry
