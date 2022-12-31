# frozen_string_literal: true

require 'test_helper'
require 'minitest/autorun'
require 'net/http'

class UrlTest < ActiveSupport::TestCase
  def setup
    @url = Url.new(original_url: 'https://example.com')
    @url.valid?
  end

  test 'should be valid and generate slug, set redis value' do
    assert @url.valid?
    assert @url.slug.present?

    urls(:react).save!
    assert urls(:react).redis_original_url.present?
  end

  test 'original_url should be present' do
    @url.original_url = ' ' * 6
    assert_not @url.valid?
  end

  test 'original_url should not be too long' do
    @url.original_url = "https://google.com/?q=#{'a' * 2049}"
    assert_not @url.valid?
  end

  test 'original_url should not be from host' do
    @url.original_url = 'https://github.io/aBcDeF'
    assert_not @url.valid?
  end

  test 'original_url should be saved as lower-case' do
    mixed_case_url = 'https://www.gOoGlE.com/?q=RailsTutorial'
    @url.original_url = mixed_case_url
    @url.save
    assert_equal 'https://www.google.com/?q=RailsTutorial', @url.reload.original_url
  end

  test 'slug should always generate when encode' do
    new_slug = SecureRandom.alphanumeric(3)
    @url.slug = new_slug
    @url.valid?
    assert_not_equal @url.slug, new_slug
  end

  test 'slug should be generate if existed before' do
    @url.slug = urls(:react).slug
    @url.valid?
    assert_not_equal @url.slug, urls(:react).slug
  end

  test 'original_url validation should accept valid' do
    valid_addresses = %w[https://example.com http://example.COM HTTP://example.com]
    valid_addresses.each do |valid_address|
      @url.original_url = valid_address
      assert @url.valid?
    end
  end

  test 'original_url validation should reject invalid' do
    invalid_addresses = %w[https://example,com http://example. http://example+foo.com localhost]
    invalid_addresses.each do |invalid_address|
      @url.original_url = invalid_address
      assert_not @url.valid?
      assert @url.errors.details[:original_url].present?
    end
  end

  test 'Net::HTTP call get_response does not return Net::HTTPResponse, then url should not valid' do
    mock_not_http_response = MiniTest::Mock

    Net::HTTP.stub :get_response, mock_not_http_response do
      assert_not @url.valid?, "#{@url.inspect} should be invalid"
    end
  end

  test 'Net::HTTP call get_response return Timeout::Error, then url should valid' do
    mock_time_out_error = Timeout::Error.new
    Net::HTTP.stub :get_response, mock_time_out_error do
      assert_not @url.valid?, "#{@url.inspect} should be invalid"
    end
  end

  test 'URI module raise invalid uri error, then url should not valid' do
    @url.original_url = 'https://exam ple.com'
    assert_not @url.valid?
    assert @url.errors.details[:original_url].present?
  end

  test 'URL is redirect to another, then check last url should valid' do
    @url.original_url = 'http://bit.ly'
    assert @url.valid?
  end

  test 'encode from wrong url should return error messages' do
    assert_equal Url.encode('this is example'), ['Original url is invalid']
  end

  test 'decode from not valid slug should return error messages' do
    assert_equal Url.decode('something'), ['Shorten URL is not valid']
  end

  test 'encode from shorten url should return error messages' do
    assert_equal Url.encode(urls(:react).shortened), ['Original url is invalid']
  end

  test 'decode from not existed slug should return error messages' do
    assert_equal Url.decode('https://github.io/not_existed'), ['Shorten URL is not existed']
  end

  test 'encode from existing url should return new slug' do
    redis = Redis.new
    first_slug = redis.keys.first.split(':').last
    first_original_url = redis.get(redis.keys.first)
    encoding_url = Url.encode(first_original_url)
    last_slug = redis.keys.last.split(':').last
    shortened_url = Rails.application.routes.url_helpers.shortened_url(slug: last_slug)
    assert_not_equal first_slug, last_slug
    assert_equal encoding_url, shortened_url
  end

  test 'decode from valid slug should return url from redis' do
    urls(:react).save!
    assert_equal Url.decode(urls(:react).shortened), urls(:react).original_url
  end
end
