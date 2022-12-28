# frozen_string_literal: true

class Url < ApplicationRecord
  validates_presence_of :original_url, :slug
  validates :original_url, url: true
  validates_uniqueness_of :slug
  validates_length_of :original_url, within: 10..2048
  validates_length_of :slug, within: 6..6

  before_validation :generate_slug
  before_save do
    original_uri = Rails.cache.fetch("uri_from_url:#{original_url}") do
      URI.parse(original_url)
    end

    original_uri.host = original_uri.host.downcase
    self.original_url = original_uri.to_s
  end

  def generate_slug
    return if !slug.nil? && !slug.empty?

    slug = SecureRandom.alphanumeric(6)
    return generate_slug if Url.exists?(slug:)

    self.slug = slug
  end

  def shortened
    Rails.application.routes.url_helpers.shortened_url(slug:)
  end

  def self.encode(original_url)
    url = Url.new(original_url:)
    return url.shortened if url.save

    url.errors.full_messages
  end

  def self.decode(shortened_url)
    shortened_uri = URI.parse(shortened_url)
    if !shortened_uri.is_a?(URI::HTTP) || shortened_uri.host != Rails.application.routes.default_url_options[:host]
      return ['Shorten URL is not valid']
    end

    url = Url.find_by_slug(shortened_uri.path.split('/').last)
    return url.original_url if url

    ['Shorten URL is not existed']
  rescue URI::InvalidURIError
    ['Shorten URL is not valid']
  end
end
