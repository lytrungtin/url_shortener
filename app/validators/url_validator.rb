# frozen_string_literal: true

require 'net/http'

# URL validator for urls from Model should valid, be able to redirect or response success
class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, :invalid) unless url_valid?(value)
  end

  private

  def default_host
    Rails.application.routes.default_url_options[:host]
  end

  def uri_response(url_string)
    uri = uri(url_string)
    return false unless uri

    Rails.cache.fetch("url_response:#{url_string}") do
      Timeout.timeout(1) { Net::HTTP.get_response(uri) }
    end
  rescue SocketError, Errno::ECONNREFUSED
    false
  end

  def handle_response(uri_response)
    case uri_response
    when Net::HTTPSuccess, Net::HTTPNotModified
      true
    when Net::HTTPRedirection
      url_valid?(uri_response['location'])
    else
      false
    end
  end

  def url_valid?(url_string)
    uri_response = uri_response(url_string)
    handle_response(uri_response)
  rescue Timeout::Error
    true
  end

  def uri(url_string)
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
