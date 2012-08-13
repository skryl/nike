require 'hashie'

class Nike::Mash < Hashie::Mash
  KM_TO_MILE = 0.621371192

  CONVERTER_AVAILABILITY = {
    distance: [:distance_in_kilometers, :distance_in_miles, :speed_in_mph, :speed_in_kph],
    duration: [:duration_in_seconds, :duration_in_minutes, :duration_in_hours, :duration_in_hms],
    pace:     [:pace_in_mpk, :pace_in_mpm]
  }

  CONVERTER_LOOKUP = {
    distance_in_kilometers: :distance_to_kilometers,
    distance_in_miles: :distance_to_miles,
    duration_in_seconds: :duration_to_seconds,
    duration_in_minutes: :duration_to_minutes,
    duration_in_hours: :duration_to_hours,
    duration_in_hms: :duration_to_hms,
    speed_in_mph: :speed_to_mph,
    speed_in_kph: :speed_to_kph,
    pace_in_mpk: :pace_to_mpk,
    pace_in_mpm: :pace_to_mpm,
  }

  def method_missing(method, *args, &block)
    case method.to_s
    when /_time$|_time_utc$/
      Time.parse(super)
    else
      converter = CONVERTER_LOOKUP[method]
      converter ? self.send(converter) : super
    end
  end

  def respond_to_missing?(method, include_private = false)
    conversion_helpers.include?(method)
  end

  def conversion_helpers
    CONVERTER_AVAILABILITY.inject([]) do |a, (m, converters)|
      self.include?(m.to_s) ? a += converters : a
    end
  end

private

# distance

  def distance_to_kilometers
    distance
  end

  def distance_to_miles
    distance * KM_TO_MILE
  end

# duration

  def duration_to_seconds
    duration.to_f / 1000
  end

  def duration_to_minutes
    duration.to_f / 60000
  end

  def duration_to_hours
    duration.to_f / 3600000
  end

  def duration_to_hms
    Time.at(duration_to_seconds).gmtime.strftime('%R:%S')
  end

# speed

  def speed_to_mph
    distance_in_miles && duration_in_hours &&
    distance_in_miles / duration_in_hours
  end

  def speed_to_kph
    distance_in_kilometers && duration_in_hours &&
    distance_in_kilometers / duration_in_hours
  end
  
# speed

  def pace_to_mpk
    distnace_in_kilometers && duration_in_minutes &&
    duration_in_minutes / distance_in_kilometers
  end

  def pace_to_mpm
    distnace_in_miles && duration_in_minutes &&
    duration_in_minutes / distance_in_miles
  end

end
