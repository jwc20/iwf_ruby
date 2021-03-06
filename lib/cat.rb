require_relative './athlete_result'
require_relative './event'
require 'nokogiri'
require 'open-uri'
require 'pry'

class Cat
  def get_doc(url)
    # Get document for a single event
    Nokogiri::HTML(open(url))
  end

  def make_results_men_0(url)
    # Get all athlete informations and results from the event
    # USING TOTALS
    doc = get_doc(url)
    # name_of_event = doc.css("#page__container section div.filters div.container div div div h2").text
    cards = doc.css('#men_total div.card')
    # binding.pry
    cards.each do |card|
      athlete = AthleteResult.new
      athlete.name = card.css('div.col-7.not__cell__767 p').text.delete!("\n")

      # Need to check if node is not empty
      next unless athlete.name && athlete.name != ''

      athlete.nation = card.css('div div a div div.col-3.not__cell__767 p').text.delete!("\n")
      athlete.birthdate = card.css('div.col-5.not__cell__767 p')[0].children[2].text.delete!("\n")
      athlete.athlete_url = card.css('div div a.col-md-5.title').attribute('href').value.strip

      # category

      athlete.bweight = card.css('div.col-4.not__cell__767 p')[0].children[2].text.delete!("\n")
      athlete.group = card.css('div div div.col-md-4 div div.col-3.not__cell__767 p')[0].children[2].text.delete!("\n")

      # snatch1
      # snatch2
      # snatch3

      # jerk1
      # jerk2
      # jerk3

      athlete.snatch = card.css('div div div.col-md-3 div div:nth-child(1) p strong').children.text
      athlete.jerk = card.css('div div div.col-md-3 div div:nth-child(2) p strong').text
      athlete.total = card.css('div div div.col-md-3 div div:nth-child(3) p strong')[0].children[1].text

      # rank_s
      # rank_cj
      athlete.rank = card.css('div.col-2.not__cell__767 p').text.delete!("\n")
    end
  end

  def make_results_men(url)
    # Get all athlete informations and results from the event
    # USING TOTALS
    doc = get_doc(url)
    # name_of_event = doc.css("#page__container section div.filters div.container div div div h2").text

    containers = doc.css('#men_total')

    # extended_results = doc.css('div#men_snatchjerk')

    containers.each do |container|
      categories = container.css('div.results__title')
      # binding.pry

  

      categories.each do |cat|

        results = cat.xpath('following-sibling::div')
        # puts results.first.parent.xpath('following-sibling::div').css('div:nth-child(3) div:nth-child(2) div div div.col-md-3 div div:nth-child(2) p strong').text
   
        results.css('div.card').each do |result|
          athlete = AthleteResult.new
          athlete.name = result.css('div.col-7.not__cell__767 p').text.delete!("\n")

          next unless athlete.name && athlete.name != ''

          athlete.nation = result.css('div div a div div.col-3.not__cell__767 p').text.delete!("\n")
          athlete.birthdate = result.css('div.col-5.not__cell__767 p')[0].children[2].text.delete!("\n")
          athlete.athlete_url = result.css('div div a.col-md-5.title').attribute('href').value.strip

          athlete.category = cat.css('div div div h2').text
          athlete.bweight = result.css('div.col-4.not__cell__767 p')[0].children[2].text.delete!("\n")
          athlete.group = result.css('div div div.col-md-4 div div.col-3.not__cell__767 p')[0].children[2].text.delete!("\n")

          athlete.snatch = result.css('div div div.col-md-3 div div:nth-child(1) p strong').children.text
          athlete.jerk = result.css('div div div.col-md-3 div div:nth-child(2) p strong').text
          athlete.total = result.css('div div div.col-md-3 div div:nth-child(3) p strong')[0].children[1].text

          athlete.rank = result.css('div.col-2.not__cell__767 p').text.delete!("\n")

          # athlete.snatch1 = result.parent.xpath('following-sibling::div').css('div:nth-child(3) div:nth-child(2) div div div.col-md-3 div div:nth-child(2) p strong').text

          # categories.first.parent.xpath('following-sibling::div').css('div:nth-child(3) div:nth-child(2) div div div.col-md-3 div div:nth-child(2) p strong').first.text

          # athlete.snatch2 = result.parent.xpath('following-sibling::div').css('div:nth-child(3) div:nth-child(2) div div div.col-md-3 div div:nth-child(2) p strong').text


  
          # get_extended_results(doc)
          # rank_s
          # rank_cj

          # extended_results = cat.xpath('following-sibling::div').css('div#men_snatchjerk')

          # extended_results = cat.parent.xpath('following-sibling::div')
        end
      end
    end
  end

  # def get_extended_results(url)
  #   doc = get_doc(url)

  #   extended_results = doc.css('div#men_snatchjerk')
  #   athlete = AthleteResult.new

  #   extended_results.each do |extended_result|
  #     # athlete.snatch1 = extended_result.css('div:nth-child(3) div:nth-child(1) p strong').text
  #     athlete.snatch2 = extended_result.css('div:nth-child(3) div:nth-child(2) div div div.col-md-3 div div:nth-child(2) p strong').text
  #     # athlete.snatch3 = extended_result.css('div:nth-child(3) div:nth-child(2) div div div.col-md-3 div div:nth-child(3) p strong').text

  #     # athlete.jerk1 = extended_result.css('div:nth-child(5) div:nth-child(2) div div div.col-md-3 div div:nth-child(1) p strong').text
  #     # athlete.jerk2 = extended_result.css('div:nth-child(5) div:nth-child(2) div div div.col-md-3 div div:nth-child(2) p strong').text
  #     # athlete.jerk3 = extended_result.css('div:nth-child(5) div:nth-child(2) div div div.col-md-3 div div:nth-child(3) p strong').text
  #   end
  # end

  def print_male_athletes(url)
    # self.make_all_men_athlete_informations_and_results_from_event(url)
    make_results_men(url)
    # get_extended_results(url)
    AthleteResult.all.each do |athlete|
      next unless athlete.name && athlete.name != ''

      puts "Name: #{athlete.name}"
      puts "Nation: #{athlete.nation}"
      puts "Birthdate: #{athlete.birthdate}"
      puts "URL:  #{athlete.athlete_url}"
      puts "Category: #{athlete.category}"
      puts "Body weight: #{athlete.bweight}"
      puts "Group: #{athlete.group}"
      puts "Snatch: #{athlete.snatch}"
      puts "Snatch1: #{athlete.snatch1}"
      puts "Snatch2: #{athlete.snatch2}"
      puts "Snatch3: #{athlete.snatch3}"
      puts "Clean and Jerk: #{athlete.jerk}"
      puts "Total: #{athlete.total}"
      puts "Rank: #{athlete.rank}"
      puts ''
    end
  end
end

Cat.new.print_male_athletes('https://iwf.sport/results/results-by-events/?event_id=529')
# Cat.new.get_extended_results('https://iwf.sport/results/results-by-events/?event_id=529')
# Cat.new.make_results_men('https://iwf.sport/results/results-by-events/?event_id=529')
