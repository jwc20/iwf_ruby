# frozen_string_literal: true

require_relative 'iwf_ruby/version'
require 'nokogiri'
require 'open-uri'
require 'pry'

module IwfRuby
  class Scraper
    require_relative './athlete_result'
    require_relative './event'

    def get_years_available
      # FIXME
      # Gets all years available in new bodyweight and old bodyweight events page
      years = []
      urls = ['https://iwf.sport/results/results-by-events/', 'https://iwf.sport/results/results-by-events/results-by-events-old-bw/']

      urls.each do |url|
        events_page = Nokogiri::HTML(URI.open(url))
        events_page.css('.results_by_events select').first.css('option').each do |year|
          # puts year.text
          years.push(year.text) unless years.include?(year.text)
        end
      end
      years
    end

    def get_participant_countries(event_url)
      countries = []
      doc = get_doc(event_url)

      containers = [doc.css('#men_total'), doc.css('#women_total')]
      containers.each do |container|
        categories = container.css('div.results__title')
        categories.each do |category|
          results = category.xpath('following-sibling::div')
          results.css('div.card').each do |result|
            athlete = AthleteResult.new
            athlete.name = result.css('div div a div div.col-7.not__cell__767 p').text.delete!("\n")
            next unless athlete.name && athlete.name != ''

            countries.push(result.css('div div a div div.col-3.not__cell__767 p').text.delete!("\n"))
          end
        end
      end
      return countries.group_by { |e| e }.map { |k, v| [k, v.length] }.to_h
    end

    def make_events(year)
      get_events_page(year).css('#section-scroll div div.cards a').each do |post|
        event = Event.new
        event.name = post.css('div.container div div.col-md-5.col-12.not__cell__767__full p span').text

        next unless event.name && event.name != ''

        event.location = post.css('div.container div div.col-md-3.col-4.not__cell__767 p').text.delete!("\n")
        event.date = post.css('div.container div div:nth-child(2) p').text.delete!("\n").rstrip

        if year.to_i > 2018
          event.event_url = "https://iwf.sport/results/results-by-events/#{post.attribute('href').value}"
        elsif year.to_i < 2018
          event.event_url = "https://iwf.sport/results/results-by-events/results-by-events-old-bw/#{post.attribute('href').value}"
        end
      end
    end

    def find_event_result_men(event_name_searched, year)
      # Event.reset_all
      event_name_searched_formatted = event_name_searched.split(' ').join('-').downcase
      events = print_events(year)
      events.each do |event|
        event_name_formatted = event.name.split(' ').join('-').downcase
        next unless event_name_formatted == event_name_searched_formatted

        return print_male_athletes(event.event_url)
      end
    end

    def find_event_result_women(event_name_searched, year)
      # Event.reset_all
      event_name_searched_formatted = event_name_searched.split(' ').join('-').downcase
      events = print_events(year)
      events.each do |event|
        event_name_formatted = event.name.split(' ').join('-').downcase
        next unless event_name_formatted == event_name_searched_formatted

        return print_female_athletes(event.event_url)
      end
    end

    def print_events(year)
      Event.reset_all
      make_events(year)
      Event.all.each do |event|
        next unless event.name && event.name != ''

        # puts "Name: #{event.name}"
        # puts "Location: #{event.location}"
        # puts "Date: #{event.date}"
        # puts "Event url: #{event.event_url}"
      end
    end

    def get_events_page(year)
      # def get_events_page(year, bw = nil)
      # Gets all events by year of competition
      if year.to_i > 2018
        get_new_bodyweight_events(year)
      elsif year.to_i < 2018
        get_old_bodyweight_events(year)
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
      old_bw = Nokogiri::HTML(URI.open('https://iwf.sport/results/results-by-events/results-by-events-old-bw/?event_year=2018')).search('#section-scroll div.results')
      new_bw = Nokogiri::HTML(URI.open('https://iwf.sport/results/results-by-events/?event_year=2018'))
      new_bw.at('#section-scroll div.results').add_child(old_bw)
    end

    def get_new_bodyweight_events(year)
      Nokogiri::HTML(URI.open("https://iwf.sport/results/results-by-events/?event_year=#{year}"))
    end

    def get_old_bodyweight_events(year)
      Nokogiri::HTML(URI.open("https://iwf.sport/results/results-by-events/results-by-events-old-bw/?event_year=#{year}"))
    end

    def get_doc(url)
      # Get document for a single event
      Nokogiri::HTML(URI.open(url))
    end

    def get_all_men_athlete_names_from_event(url)
      # Get only the name of male athletes in the event
      doc = get_doc(url)
      doc.css('#men_total div div a div div.col-7.not__cell__767').text
    end

    def get_all_women_athlete_names_from_event(url)
      # Get only the name of female athletes in the event
      doc = get_doc(url)
      doc.css('#women_total div div a div div.col-7.not__cell__767').text
    end

    # TODO:
    # snatch1
    # snatch2
    # snatch3
    # jerk1
    # jerk2
    # jerk3

    def make_results_men(url)
      # Get all athlete informations and results from the event
      doc = get_doc(url)
      containers = doc.css('#men_total')
      scrape_results(containers)
    end

    def make_results_women(url)
      # Get all athlete informations and results from the event
      doc = get_doc(url)
      containers = doc.css('#women_total')
      scrape_results(containers)
    end

    def scrape_results(containers)
      containers.each do |container|
        categories = container.css('div.results__title')
        categories.each do |cat|
          results = cat.xpath('following-sibling::div')
          results.css('div.card').each do |result|
            athlete = AthleteResult.new
            athlete.name = result.css('div div a div div.col-7.not__cell__767 p').text.delete!("\n")
            next unless athlete.name && athlete.name != ''

            athlete.nation = result.css('div div a div div.col-3.not__cell__767 p').text.delete!("\n")
            athlete.birthdate = result.css('div.col-5.not__cell__767 p')[0].children[2].text.delete!("\n")
            athlete.athlete_url = result.css('div div a.col-md-5.title').attribute('href').value.strip
            athlete.category = cat.css('div div div h2').text.gsub(/[^\d]/, '').to_i
            athlete.bweight = result.css('div.col-4.not__cell__767 p')[0].children[2].text.delete!("\n")
            athlete.group = result.css('div div div.col-md-4 div div.col-3.not__cell__767 p')[0].children[2].text.delete!("\n")
            athlete.snatch = result.css('div div div.col-md-3 div div:nth-child(1) p strong').children.text.gsub('---',
                                                                                                                 '0').to_i
            athlete.jerk = result.css('div div div.col-md-3 div div:nth-child(2) p strong').text.gsub('---', '0').to_i
            athlete.total = result.css('div div div.col-md-3 div div:nth-child(3) p strong')[0].children[1].text.gsub(
              '---', '0'
            ).to_i
            athlete.rank = result.css('div.col-2.not__cell__767 p').children[2].text.delete("\n").gsub('---', '0').to_i
          end
        end
      end
    end

    def print_male_athletes(url)
      # self.make_all_men_athlete_informations_and_results_from_event(url)
      AthleteResult.reset_all
      make_results_men(url)

      AthleteResult.all.each do |athlete|
        next unless athlete.name && athlete.name != ''

        # puts "Name: #{athlete.name}"
        # puts "Nation: #{athlete.nation}"
        # puts "Birthdate: #{athlete.birthdate}"
        # puts "URL:  #{athlete.athlete_url}"
        # puts "Category: #{athlete.category}"
        # puts "Body weight: #{athlete.bweight}"
        # puts "Group: #{athlete.group}"
        # puts "Snatch: #{athlete.snatch}"
        # puts "Clean and Jerk: #{athlete.jerk}"
        # puts "Total: #{athlete.total}"
        # puts "Rank: #{athlete.rank}"
      end
    end

    def print_female_athletes(url)
      # self.make_all_men_athlete_informations_and_results_from_event(url)
      AthleteResult.reset_all
      make_results_women(url)

      AthleteResult.all.each do |athlete|
        next unless athlete.name && athlete.name != ''

        # puts "Name: #{athlete.name}"
        # puts "Nation: #{athlete.nation}"
        # puts "Birthdate: #{athlete.birthdate}"
        # puts "URL:  #{athlete.athlete_url}"
        # puts "Category: #{athlete.category}"
        # puts "Body weight: #{athlete.bweight}"
        # puts "Group: #{athlete.group}"
        # puts "Snatch: #{athlete.snatch}"
        # puts "Clean and Jerk: #{athlete.jerk}"
        # puts "Total: #{athlete.total}"
        # puts "Rank: #{athlete.rank}"
      end
    end

    ############################################################################
    # TODOs:
    def get_events_from_location(location)
      # Get events from the location
    end

    def get_all_athlete_informations_and_results_from_event(url)
      # Get all athlete informations and results from the event
      # name, athlete_url, nation, birthdate, category, bweight, group,
      # rank_s, snatch1, snatch2, snatch3,
      # rank_cj, jerk1, jerk2, jerk3,
      # rank, snatch, jerk, total
      # doc = get_doc(url)
    end

    def get_athlete_informations_from_event(athlete)
      # Get information about the athlete from the event
      # name, athlete_url, nation, birthdate, category, bweight, group
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
  ############################################################################

  class Error < StandardError; end
end

IwfRuby::Scraper.new.get_participant_countries('https://iwf.sport/results/results-by-events/?event_id=527')
# find_event_result_men('2022 IWF Junior World Championships', 2022)
# IwfRuby::Scraper.new.find_event_result_women('XXXII OLYMPIC GAMES', 2021)
