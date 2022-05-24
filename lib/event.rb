require "nokogiri"
require "open-uri"
require "pry"

class Event
  attr_accessor :name, :location, :date, :event_id

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
  end

  def make_events(year)
    get_events_page(year).css("#section-scroll div div.cards a").each do |post|
      event = Event.new
      event.name = post.css("div.container div div.col-md-5.col-12.not__cell__767__full p span").text
      event.location = post.css("div.container div div.col-md-3.col-4.not__cell__767 p").text.delete!("\n")
      event.date = post.css("div.container div div:nth-child(2) p").text.delete!("\n").rstrip
      event.event_id = post.attribute("href").value
    end
  end

  def print_events(years)
    make_events(years)
    Event.all.each do |event|
      if event.name
        puts "Name: #{event.name}"
        puts "Location: #{event.location}"
        puts "Date: #{event.date}"
        puts "Event ID: #{event.event_id}"
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
    # FIXME:
    old_bw = Nokogiri::HTML(open("https://iwf.sport/results/results-by-events/results-by-events-old-bw/?event_year=2018")).search("#section-scroll div.results")
    new_bw = Nokogiri::HTML(open("https://iwf.sport/results/results-by-events/?event_year=2018"))
    new_bw.at("#section-scroll div.results").add_child(old_bw)
  end

  def get_events_from_location(location)
    # Get events from the location
  end

  def get_athletes_from_event(url)
    # Get only name of athletes in the event
  end

  def get_athletes_information_from_event(athlete)
    # Get information about the athlete from the event
    # name, athlete_id, nation, born, category, bweight, group
  end

  def get_snatch_results_from_event(athlete)
    # Get only snatch results from the event
    # rank_s, snatch1, snatch2, snatch3, snatch
  end

  def get_clean_and_jerk_results_from_event(athlete)
    # Get only clean and jerk results from the event
    # rank_cj, jerk1, jerk2, jerk3, jerk
  end

  def get_total_results_from_event(athlete)
    # Get totals (highest snatch + highest clean and jerk) from the event
    # snatch, jerk, total
  end

  # def get_results_from_event(url)
  #   # Get all results from the event
  # end
end

binding.pry
