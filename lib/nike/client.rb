require_relative 'core_ext/hash.rb'

require 'httparty'
require 'hashie'
require 'active_support/core_ext/string/inflections'

class Nike::Client
  include HTTParty
  # debug_output $stdout

  BASE_URL      = 'https://api.nike.com/me/sport'
  APP_KEY       = 'b31990e7-8583-4251-808f-9dc67b40f5d2' 
  FORMAT        = :json

  # service urls
  #
  ACTIVITY_URL = '/activities' 
  NUM_ACTIVITIES = 10

  format FORMAT
  base_uri BASE_URL
  headers 'Accept' => 'application/json', 
          'appid'  => APP_KEY

  DATE_RXP = /\d{4}-\d{2}-\d{2}/
  NUM_RXP  = /\d+/

  attr_accessor :caching

  def initialize(token, opts = {})
    @token = token
    @caching, @cache = opts[:caching] || true, {}
  end

  def activity(id)
    fetch_activity(id.to_s)
  end

  def activities(opts = {})
    params = {}
    start_date, end_date, count, page  = 
      opts[:start_date], opts[:end_date], opts[:count], opts[:page]

    params.merge(startDate: start_date) if start_date && start_date.match(DATE_RXP)
    params.merge(endDate: end_date) if end_date && end_date.match(DATE_RXP)
    params.merge(count: count) if count && count.match(NUM_RXP)
    params.merge(page: page) if page && page.match(NUM_RXP)

    fetch_activities(params)['data']
  end

  def detailed_activities(opts = {})
    activities(opts).map { |a| activity(a.activity_id) }
  end

  def method_missing(method_name, *args, &block)
    if /(.*)!$/ === method_name && self.respond_to?(method_name.to_s.chop)
      no_cache { self.send($1, *args, &block) }
    else super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.end_with?('!') && self.respond_to?(method_name.to_s.chop)
  end  

private

# data

  def fetch_activity(id)
    cache(id) do 
      wrap get_authorized(ACTIVITY_URL + "/#{id}")
    end
  end

  def fetch_activities(params = {})
    params = { count: NUM_ACTIVITIES }.merge(params)

    cache(:all) do
      wrap get_authorized(ACTIVITY_URL, params)
    end
  end

# auth

  def get_authorized(url, params = {})
    self.class.get(url, query: params.merge(access_token: @token))
  end

# caching

  def cache(key)
    @caching ? @cache[key] ||= yield : yield
  end

  def no_cache
    caching = @caching
    @caching = false
    yield
  ensure
    @caching = caching
  end

# helpers

  def wrap(response)
    Nike::Mash.new(response.underscore_keys)
  end

end
