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
    @url.original_url = "https://google.com/?q=#{'a' * 255}"
    assert_not @url.valid?
  end

  test 'original_url should be unique' do
    duplicate_url = @url.dup
    duplicate_url.original_url = @url.original_url
    @url.save
    assert_not duplicate_url.valid?, "#{duplicate_url.inspect} should be invalid"
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
    assert_not @url.valid?, "#{@url.inspect} should be invalid"
  end

  test 'original_url validation should accept valid' do
    valid_addresses = %w[https://example.com http://example.COM HTTP://example.com]
    valid_addresses.each do |valid_address|
      @url.original_url = valid_address
      assert @url.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test 'original_url validation should reject invalid' do
    invalid_addresses = %w[https://example,com http://example. http://example+foo.com]
    invalid_addresses.each do |invalid_address|
      @url.original_url = invalid_address
      assert_not @url.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test 'URI module raise invalid uri error, then url should not valid' do
    mock_invalid_uri_error = URI::InvalidURIError

    URI.stub :parse, mock_invalid_uri_error do
      assert_not @url.valid?, "#{@url.inspect} should be invalid"
    end
  end

  test 'Net::HTTP call get_response does not return Net::HTTPResponse, then url should not valid' do
    mock_not_http_response = MiniTest::Mock

    Net::HTTP.stub :get_response, mock_not_http_response do
      assert_not @url.valid?, "#{@url.inspect} should be invalid"
    end
  end

  test 'generate to existing slug then url should not valid' do
    existing_slug = urls(:react).slug
    SecureRandom.stub :alphanumeric, existing_slug do
      assert_raises 'Url was re encoded!' do
        Url.encode('https://example.com')
      end
    end
  end

  test 'encode to existing slug then Url should call encode again' do
    existing_slug = urls(:react).slug
    SecureRandom.stub :alphanumeric, existing_slug do
      assert_raises 'Url was re encoded!' do
        Url.encode('https://example.com')
      end
    end
  end

  test 'encode from wrong url should return error messages' do
    assert_equal Url.encode('example'), ['Original url is invalid']
  end

  test 'decode from not existed slug should return error messages' do
    assert_equal Url.decode('something'), ['Shorten URL is not existed']
  end

  test 'encode from existing url should return slug from database' do
    assert_equal Url.encode(urls(:react).original_url), urls(:react).shortened
  end

  test 'decode from from valid slug should return url from database' do
    assert_equal Url.decode(urls(:react).slug), urls(:react).original_url
  end
end
