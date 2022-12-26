# frozen_string_literal: true

require 'net/http'

class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, :invalid) unless url_exist?(value)
  end

  private

  def default_host
    Rails.application.routes.default_url_options[:host]
  end

  def url_exist?(url_string)
    uri = URI.parse(url_string)
    return false unless uri.is_a?(URI::HTTP)
    return false if uri.host == default_host

    res = Net::HTTP.get_response(uri)

    return url_exist?(res['location']) if !res.is_a?(Net::HTTPNotModified) && res.is_a?(Net::HTTPRedirection)

    return !%w[4 5].include?(res.code[0]) if res.is_a?(Net::HTTPResponse)

    false
  rescue SocketError, URI::InvalidURIError
    false
  end
end
