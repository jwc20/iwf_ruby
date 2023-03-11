# iwf_ruby

A ruby library to scrape from the IWF (Internation Weightlifting Federation) website

## Methods:

- `#get_years_available`
- `#make_events(year)`
- `#find_event_result_men(event_name_searched, year)`
- `#find_event_result_women(event_name_searched, year)`
- `#print_events(year)`
- `#get_events_page(year)`
- `#get_new_bodyweight_events(year)`
- `#get_old_bodyweight_events(year)`
- `#get_doc(url)`
- `#get_all_men_athlete_names_from_event(url)`
- `#get_all_women_athlete_names_from_event(url)`
- `#make_results_men(url)`
- `#make_results_women(url)`
- `#scrape_results(containers)`
- `#print_male_athletes(url)`
- `#print_female_athletes(url)`

## Scraped Data:

### Athlete Result:

- name
- birthdate
- nation
- athlete_url
- category
- bodyweight
- group
- snatch
- jerk
- total
- rank

### Event:

- name
- location
- date
- event_url

### Tools:

open-uri, nokogiri

## Installation

To install the gem, add to the application's Gemfile:

```
gem 'iwf_ruby', git: 'https://github.com/jwc20/iwf_ruby', ref: 'development'

```

#### Note:

This client is used alongside the frontend:

```
https://github.com/jwc20/twler-frontend-new
```

and the backend:

```
https://github.com/jwc20/twler-backend
```
