# frozen_string_literal: true

class Url < ApplicationRecord
  validates_presence_of :original_url, :slug
  validates :original_url, url: true
  validates_uniqueness_of :slug, :original_url
  validates_length_of :original_url, within: 7..255, on: :create, message: 'url too long or too short'
  validates_length_of :slug, within: 6..6, on: :create, message: 'url too long or too short'

  before_validation :generate_slug
  before_save do
    original_uri = URI.parse(original_url)
    original_uri.host = original_uri.host.downcase
    self.original_url = original_uri.to_s
  end

  def generate_slug
    self.slug = SecureRandom.alphanumeric(6) if slug.nil? || slug.empty?
    true
  end

  def shortened
    Rails.application.routes.url_helpers.shortened_url(slug:)
  end

  def self.encode(original_url, test: false)
    raise 'Url was re encoded!' if test

    url = Url.find_or_initialize_by(original_url:)
    return url.shortened if url.persisted? || url.save

    return Url.encode(original_url, ENV['RAILS_ENV'] == 'test') if url.errors.details[:slug].any?

    url.errors.full_messages
  end

  def self.decode(shortened_url)
    shortened_uri = URI.parse(shortened_url)
    if !shortened_uri.is_a?(URI::HTTP) || shortened_uri.host != Rails.application.routes.default_url_options[:host]
      return ['Shorten URL is not valid']
    end

    slug = shortened_uri.path.split('/').last
    url = Url.find_by(slug:)
    return url.original_url if url

    ['Shorten URL is not existed']
  rescue URI::InvalidURIError
    ['Shorten URL is not valid']
  end
end
