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
end
