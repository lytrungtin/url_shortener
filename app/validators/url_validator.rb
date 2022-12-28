# frozen_string_literal: true

require 'net/http'

class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    @url_string = value
    record.errors.add(attribute, :invalid) unless url_valid?
  end

  private

  attr_reader :url_string

  def default_host
    Rails.application.routes.default_url_options[:host]
  end

  def uri_response
    return false unless uri

    Timeout.timeout(10) do
      Rails.cache.fetch("uri_response:#{uri.host.downcase}#{uri.scheme}#{uri.path}") do
        Net::HTTP.get_response(uri)
      end
    end
  rescue SocketError, Errno::ECONNREFUSED, Timeout::Error
    false
  end

  def url_valid?
    case uri_response
    when Net::HTTPSuccess, Net::HTTPNotModified
      return true
    when Net::HTTPRedirection
      @url_string = uri_response['location']
      return url_valid?
    end
    false
  end

  def uri
    uri = Rails.cache.fetch("uri_from_url:#{url_string}") do
      URI.parse(url_string)
    end
    if uri.is_a?(URI::HTTP)
      return false if uri.host == default_host

      return uri
    end
    false
  rescue URI::InvalidURIError
    false
  end
end
