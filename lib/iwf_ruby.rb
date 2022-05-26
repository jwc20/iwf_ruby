# frozen_string_literal: true

require_relative "iwf_ruby/version"
require_relative "./athlete.rb"
require_relative "./event.rb"

require "nokogiri"
require "open-uri"
require "pry"

module IwfRuby
  class Athlete
    # name, athlete_id, nation, born, category, bweight, group,
    # rank_s, snatch1, snatch2, snatch3,
    # rank_cj, jerk1, jerk2, jerk3,
    # rank, snatch, jerk, total
    attr_accessor :name, :athlete_id, :nation, :born, :category, :bweight, :group, :rank_s, :snatch1, :snatch2, :snatch3, :rank_cj, :jerk1, :jerk2, :jerk3, :rank, :snatch, :jerk, :total

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
  end

  class Event
    attr_accessor :name, :location, :date, :event_url

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
      # FIXME
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
      years
    end

    def make_events(year)
      self.get_events_page(year).css("#section-scroll div div.cards a").each do |post|
        event = Event.new
        event.name = post.css("div.container div div.col-md-5.col-12.not__cell__767__full p span").text

        if event.name && event.name != ""
          event.location = post.css("div.container div div.col-md-3.col-4.not__cell__767 p").text.delete!("\n")
          event.date = post.css("div.container div div:nth-child(2) p").text.delete!("\n").rstrip

          if year.to_i > 2018
            event.event_url = "https://iwf.sport/results/results-by-events/#{post.attribute("href").value}"
          elsif year.to_i < 2018
            event.event_url = "https://iwf.sport/results/results-by-events/results-by-events-old-bw/#{post.attribute("href").value}"
          end
        end
      end
    end

    def print_events(year)
      self.make_events(year)
      Event.all.each do |event|
        if event.name && event.name != ""
          puts "Name: #{event.name}"
          puts "Location: #{event.location}"
          puts "Date: #{event.date}"
          puts "Event url: #{event.event_url}"
        end
      end
    end

    def get_events_page(year)
      # def get_events_page(year, bw = nil)
      # Gets all events by year of competition
      if year.to_i > 2018
        self.get_new_bodyweight_events(year)
      elsif year.to_i < 2018
        self.get_old_bodyweight_events(year)
        # TODO: Get events for 2018 (new and old bodyweight)
        # elsif year == 2018

        # elsif year == 2018 && bw == "new"
        #   get_new_bodyweight_events(year)
        # elsif year == 2018 && bw == "old"
        #   get_old_bodyweight_events(year)
      end
    end

    def get_2018_events
      # FIXME:
      old_bw = Nokogiri::HTML(open("https://iwf.sport/results/results-by-events/results-by-events-old-bw/?event_year=2018")).search("#section-scroll div.results")
      new_bw = Nokogiri::HTML(open("https://iwf.sport/results/results-by-events/?event_year=2018"))
      new_bw.at("#section-scroll div.results").add_child(old_bw)
    end

    def get_new_bodyweight_events(year)
      Nokogiri::HTML(open("https://iwf.sport/results/results-by-events/?event_year=#{year}"))
    end

    def get_old_bodyweight_events(year)
      Nokogiri::HTML(open("https://iwf.sport/results/results-by-events/results-by-events-old-bw/?event_year=#{year}"))
    end

    def get_events_from_location(location)
      # Get events from the location
    end

    def get_event_doc(url)
      # Get document for a single event
      Nokogiri::HTML(open(url))
    end

    def get_all_men_athlete_names_from_event(url)
      # Get only the name of male athletes in the event
      doc = get_event_doc(url)
      doc.css("#men_total div div a div div.col-7.not__cell__767").text
    end

    def get_all_women_athlete_names_from_event(url)
      # Get only the name of female athletes in the event
      doc = get_event_doc(url)
      doc.css("#women_total div div a div div.col-7.not__cell__767").text
    end

    # def make_all_men_athlete_informations_and_results_from_event(url)
    def make_results_men(url)
      # Get all athlete informations and results from the event
      # USING TOTALS
      doc = get_event_doc(url)
      cards = doc.css("#men_total div.card")
      cards.each do |card|
        athlete = Athlete.new
        # name
        athlete.name = card.css("div.col-7.not__cell__767 p").text.delete!("\n")

        # Need to check if node is not empty
        if athlete.name && athlete.name != ""
          # rank
          athlete.rank = card.css("div.col-2.not__cell__767 p").text.delete!("\n")
          # nation
          athlete.nation = card.css("div div a div div.col-3.not__cell__767 p").text.delete!("\n")
          # born
          athlete.born = card.css("div.col-5.not__cell__767 p")[0].children[2].text.delete!("\n")
          # bweight
          athlete.bweight = card.css("div.col-4.not__cell__767 p")[0].children[2].text.delete!("\n")
          # group
          athlete.group = card.css("div div div.col-md-4 div div.col-3.not__cell__767 p")[0].children[2].text.delete!("\n")
          # snatch
          athlete.snatch = card.css("div div div.col-md-3 div div:nth-child(1) p strong").children.text
          # jerk
          athlete.jerk = card.css("div div div.col-md-3 div div:nth-child(2) p strong").text
          #total
          athlete.total = card.css("div div div.col-md-3 div div:nth-child(3) p strong")[0].children[1].text
        end
      end
    end

    # def make_all_women_athlete_informations_and_results_from_event(url)
    def make_results_women(url)
      # Get all athlete informations and results from the event
      # USING TOTALS
      doc = get_event_doc(url)
      cards = doc.css("#women_total div.card")
      cards.each do |card|
        athlete = Athlete.new
        # name
        athlete.name = card.css("div.col-7.not__cell__767 p").text.delete!("\n")

        # Need to check if node is not empty
        if athlete.name && athlete.name != ""
          # rank
          athlete.rank = card.css("div.col-2.not__cell__767 p").text.delete!("\n")
          # nation
          athlete.nation = card.css("div div a div div.col-3.not__cell__767 p").text.delete!("\n")
          # born
          athlete.born = card.css("div.col-5.not__cell__767 p")[0].children[2].text.delete!("\n")
          # bweight
          athlete.bweight = card.css("div.col-4.not__cell__767 p")[0].children[2].text.delete!("\n")
          # group
          athlete.group = card.css("div div div.col-md-4 div div.col-3.not__cell__767 p")[0].children[2].text.delete!("\n")
          # snatch
          athlete.snatch = card.css("div div div.col-md-3 div div:nth-child(1) p strong").children.text
          # jerk
          athlete.jerk = card.css("div div div.col-md-3 div div:nth-child(2) p strong").text
          #total
          athlete.total = card.css("div div div.col-md-3 div div:nth-child(3) p strong")[0].children[1].text
        end
      end
    end

    def print_athletes(url)
      # self.make_all_men_athlete_informations_and_results_from_event(url)
      # self.make_results_men(url)
      self.make_results_women(url)
      Athlete.all.each do |athlete|
        if athlete.name && athlete.name != ""
          puts "Name: #{athlete.name}"
          puts "Rank: #{athlete.rank}"
          puts "Nation: #{athlete.nation}"
          puts "Born: #{athlete.born}"
          puts "Body weight: #{athlete.bweight}"
          puts "Group: #{athlete.group}"
          puts "Snatch: #{athlete.snatch}"
          puts "Clean and Jerk: #{athlete.jerk}"
          puts "Total: #{athlete.total}"
          puts ""
        end
      end
    end

    def get_all_athlete_informations_and_results_from_event(url)
      # Get all athlete informations and results from the event
      # name, athlete_id, nation, born, category, bweight, group,
      # rank_s, snatch1, snatch2, snatch3,
      # rank_cj, jerk1, jerk2, jerk3,
      # rank, snatch, jerk, total
      # doc = get_event_doc(url)
    end

    def get_athlete_informations_from_event(athlete)
      # Get information about the athlete from the event
      # name, athlete_id, nation, born, category, bweight, group
    end

    def get_athlete_snatch_results_from_event(athlete)
      # Get only snatch results from the event
      # rank_s, snatch1, snatch2, snatch3
    end

    def get_athlete_clean_and_jerk_results_from_event(athlete)
      # Get only clean and jerk results from the event
      # rank_cj, jerk1, jerk2, jerk3
    end

    def get_athlete_total_results_from_event(athlete)
      # Get totals (highest snatch + highest clean and jerk) from the event
      # rank, snatch, jerk, total
    end
  end

  class Error < StandardError; end

  # Your code goes here...
end
