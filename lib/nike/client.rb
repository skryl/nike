require_relative 'core_ext/hash.rb'

require 'httparty'
require 'hashie'
require 'active_support/core_ext/string/inflections'

class Nike::Client
  include HTTParty
  # debug_output $stdout

  LOGIN_URL     = 'https://secure-nikeplus.nike.com/nsl/services/user/login'
  BASE_URL      = 'http://nikeplus.nike.com/plus'
  APP_KEY       = 'b31990e7-8583-4251-808f-9dc67b40f5d2' 
  FORMAT        = :json

  # service urls
  #
  RUN_ACTIVITIES_URL = '/activity/running/[user_id]/lifetime/activities'
  HR_ACTIVITIES_URL  = '/activity/running/[user_id]/heartrate/lifetime/activities'
  ACTIVITY_URL       = '/running/ajax'

  ACTIVITIES_URLS        = {
    run:   RUN_ACTIVITIES_URL,
    hr:    HR_ACTIVITIES_URL
  }

  format FORMAT
  base_uri BASE_URL
  default_params format: FORMAT, app: APP_KEY
  headers 'User-Agent' => 'Mozilla/5.0'

  attr_accessor :caching

  def initialize(email, password, opts = {})
    @email, @password, @user_id = email, password, nil
    @caching, @cache = opts[:caching] || true, {}
    @timeout_seconds = opts[:timeout_seconds] || 15
  end

  def activity(id)
    fetch_activity_data(id.to_s).activity
  end

  def activities(opts = {})
    fetched_activities = fetch_user_data(opts).activities
    if fetched_activities.nil? 
      return {}
    else
      return fetched_activities.map { |a| a.activity }
    end
  end

  def detailed_activities(opts = {})
    activities(opts).map { |a| activity(a.activity_id) }
  end

  [:lifetime_totals, :time_span_metrics, :time_of_day_metrics, :terrains, :paces, :homepage_stats].each do |m|
    eval %(
      def #{m}(opts = {})
        fetch_user_data(opts).send(:#{m})
      end
    )
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

  def fetch_activity_data(id)
    cache(id) do 
      wrap get_authorized(ACTIVITY_URL + "/#{id}")
    end
  end

  def fetch_user_data(opts)
    type = (opts[:type] || :run).to_sym
    cache(type) do
      wrap get_authorized(ACTIVITIES_URLS[type], query: { indexStart: (opts[:indexStart] || 0), indexEnd: (opts[:indexEnd] || 999999) })
    end
  end

# auth

  def get_authorized(url, opts = {})
    login_if_unauthenticated
    raise "Authentication failed!" unless logged_in?

    timeout(@timeout_seconds) do
      self.class.get(personify_url(url), opts).to_hash
    end

  end

  def login_if_unauthenticated
    return if logged_in?

    response = self.class.login(@email, @password)
    @user_id = response['serviceResponse']['body']['User']['screenName']

  end

  def self.login(email, password)
    timeout(@timeout_seconds) do
      response = post(LOGIN_URL, query: { email: email, password: password })
      self.default_cookies.add_cookies(response.headers['set-cookie'])
      response
    end
  end

  def logged_in?
    !@user_id.nil?
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

  def personify_url(url)
    vars = url.scan(/\[[^\]]*\]/)
    vars.inject(url){ |u, v| u.gsub(v, self.instance_variable_get("@#{v[1..-2]}").to_s) }
  end

  def wrap(response)
    Nike::Mash.new(response.underscore_keys)
  end

end
