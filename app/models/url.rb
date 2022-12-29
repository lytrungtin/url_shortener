# frozen_string_literal: true

# Storing and validating URLs input before generate shorten slug
class Url < ApplicationRecord
  validates :original_url, :slug, presence: true
  validates :original_url, url: true
  validates :slug, uniqueness: true
  validates :original_url, length: { within: 10..2048 }
  validates :slug, length: { within: 4..4 }

  before_validation :generate_slug
  before_save do
    original_uri = Rails.cache.fetch("uri_from_url:#{original_url}") do
      URI.parse(original_url)
    end

    original_uri.host = original_uri.host.downcase
    self.original_url = original_uri.to_s
  end

  def generate_slug
    return if !slug.nil? && !slug.strip.nil?

    slug = SecureRandom.alphanumeric(4)
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
    shortened_uri = Rails.cache.fetch("uri_from_url:#{shortened_url}") { URI.parse(shortened_url) }
    if !shortened_uri.is_a?(URI::HTTP) || shortened_uri.host != Rails.application.routes.default_url_options[:host]
      return ['Shorten URL is not valid']
    end

    url = Url.find_by(slug: shortened_uri.path.split('/').last)
    return url.original_url if url

    ['Shorten URL is not existed']
  rescue URI::InvalidURIError
    ['Shorten URL is not valid']
  end
end
