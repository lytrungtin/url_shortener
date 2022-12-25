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

  def self.encode(original_url, test: false)
    raise 'Url was re encoded!' if test

    url = Url.find_or_initialize_by(original_url:)
    return url.slug if url.persisted?


    return Url.encode(original_url, ENV['RAILS_ENV'] == 'test') if url.errors.details[:slug].any?

    url.errors.full_messages
  end

  def self.decode(slug)
    url = Url.find_by(slug:)
    return url.original_url if url

    ['Shorten URL is not existed']
  end
end
