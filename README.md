# Nike

A Ruby client for the Nike+ API

## Features

* Run Stats
* Heart Rate Stats
* GPS Data
* Automatic Unit Conversion
* Data Set Caching

## Installation

Add this line to your application's Gemfile:

    gem 'nike'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nike

## Basic Usage

Initialize the client

    $ c = Nike::Client.new('your_email', 'your_password')

A summary of all activities by type (type is :run by default)

    $ c.activities                      # get all runs

    $ c.activities(type: :hr)           # get all heart rate activities

Full activity data (Slow if you have alot of data, use c.activity to fetch a detailed data set for a single activity)

    $ c.detailed_activities             # get detailed data for all runs

    $ c.detailed_activities(type: :hr)  # get detailed data for all hr activity

Detailed data for a single activity (The id can be found in using the summary calls above)

    $ c.activity(id)

Lifetime stats

    $ c.lifetime_totals                 # lifetime running totals

    $ c.lifetime_totals(type: :hr)      # lifetime hr totals

More metrics

    $ c.time_span_metrics               # run metrics

    $ c.time_span_metrics               # hr metrics

Distance by time of day

    $ c.time_of_day_metrics

Distance by terrain

    $ c.terrains

Pace data

    $ c.paces

Basic stats that appear on the Nike+ homepage

    $ c.homepage_stats

## GPS Data

Cheking if an activity includes GPS data

    $ a = @c.activity(#######)

    $ a.gps                             # => true

Getting to the GPS data

    $ a.geo.waypoints                   # list all GPS waypoints

    $ a.geo.waypoints.first             # => {"lat"=>42.115833, "lon"=>-87.776344, "ele"=>181.78954}
    $ a.geo.waypoints.first.lat         # => 42.115833

## Automatic Unit Conversion

Check to see which conversion helpers are available for a specific data set

    $ a = @c.activity(#######)

    $ a.conversion_helpers              # => [:distance_in_kilometers, :distance_in_miles, :duration_inseconds,
                                              :duration_in_minutes, :duration_in_hours, :duration_in_hms,
                                              :speed_in_mph, :speed_in_kph]

Examples

    $ a.duration                        # => 6402672
    $ a.duration_in_seconds             # => 6402.672
    $ a.duration_in_minutes             # => 106.7112
    $ a.duration_in_hours               # => 1.77852
    $ a.duration_in_hms                 # => "01:46:42"
                                              
All time fields are automatically converted to Ruby Time objects

    $ a.start_time_utc.class            # => Time

## Caching

Toggle caching during client initialization

    $ c = Nike::Client.new('your_email', 'your_password', caching: true)

Toggle caching after client initialization

    $ c.caching = false

Perform the HTTP request for a particular call even if caching is enabled. This
will have the side-effect of refreshing the cache.

    $ c.activities!
    

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
