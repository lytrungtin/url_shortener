# frozen_string_literal: true

require 'test_helper'
require 'minitest/autorun'
require 'net/http'

class UrlTest < ActiveSupport::TestCase
  def setup
    @url = Url.new(original_url: 'https://example.com')
  end

  test 'should be valid and generate slug' do
    assert @url.valid?
    assert @url.slug.present?
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

  test 'slug should be present' do
    @url.slug = ' ' * 6
    assert_not @url.valid?
  end

  test 'slug should have a minimum length' do
    @url.slug = SecureRandom.alphanumeric(5)
    assert_not @url.valid?
  end

  test 'slug should be unique' do
    @url.slug = urls(:react).slug
    assert_not @url.valid?
    assert @url.errors.details[:slug].present?
  end

  test 'original_url validation should accept valid' do
    valid_addresses = %w[https://example.com http://example.COM HTTP://example.com]
    valid_addresses.each do |valid_address|
      @url.original_url = valid_address
      assert @url.valid?
    end
  end

  test 'original_url validation should reject invalid' do
    invalid_addresses = %w[https://example,com http://example. http://example+foo.com]
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
    @url.original_url = 'https://example.com/[%23R]%20'
    assert_not @url.valid?
    assert @url.errors.details[:original_url].present?
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
    assert_equal Url.encode(urls(:react).original_url), Url.last.shortened
  end

  test 'decode from from valid slug should return url from database' do
    assert_equal Url.decode(urls(:react).shortened), urls(:react).original_url
  end
end
