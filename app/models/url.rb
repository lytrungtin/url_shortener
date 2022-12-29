# frozen_string_literal: true

# Storing and validating URLs input before generate shorten slug
class Url < ApplicationRecord
  validates :original_url, :slug, presence: true
  validates :original_url, url: true
  validates :slug, uniqueness: true
  validates :original_url, length: { within: 10..2048 }
  validates :slug, length: { within: 4..6 }

  before_validation :generate_slug
  before_save do
    original_uri = Rails.cache.fetch("uri_from_url:#{original_url}") do
      URI.parse(original_url)
    end

    original_uri.host = original_uri.host.downcase
    self.original_url = original_uri.to_s
  end
  after_save do
    redis.set(original_url_key, original_url)
  end

  def redis_original_url
    redis.get(original_url_key)
  end

  def shortened
    Rails.application.routes.url_helpers.shortened_url(slug:)
  end

  class << self
    def encode(original_url)
      url = Url.new(original_url:)
      return url.shortened if url.save

      url.errors.full_messages
    end

    def get_slug_from_shortened_url(shortened_url)
      shortened_uri = Rails.cache.fetch("uri_from_url:#{shortened_url}") { URI.parse(shortened_url) }
      if !shortened_uri.is_a?(URI::HTTP) || shortened_uri.host != Rails.application.routes.default_url_options[:host]
        return false
      end

      shortened_uri.path.split('/').last
    end

    def decode(shortened_url)
      slug = get_slug_from_shortened_url(shortened_url)
      return ['Shorten URL is not valid'] unless slug

      url = redis.get("urls:original_url:#{slug}")
      return url if url

      ['Shorten URL is not existed']
    rescue URI::InvalidURIError
      ['Shorten URL is not valid']
    end

    def redis
      @redis ||= Redis.new
    end
  end

  private

  def redis
    @redis ||= Redis.new
  end

  def generate_slug
    return if !slug.nil? && !slug.strip.nil?

    slug = SecureRandom.alphanumeric(4)
    return generate_slug if Url.exists?(slug:)

    self.slug = slug
  end

  def original_url_key
    @original_url_key ||= "urls:original_url:#{slug}"
  end
end
