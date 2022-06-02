# iwf_ruby Beta

A ruby library to scrape from the IWF (Internation Weightlifting Federation) website

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
