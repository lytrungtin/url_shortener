# frozen_string_literal: true

require 'test_helper'

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
    @url.original_url = "https://example.com/#{'a' * 255}"
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
end
