# frozen_string_literal: true

# Handles redirections for All urls already shortened with :slug param
class RedirectionController < ApplicationController
  before_action :validate_slug
  def redirect
    result = Rails.cache.fetch("decode_shortened_url:#{request.original_url}") do
      Url.decode(request.original_url)
    end
    return not_found if result.is_a?(Array)

    redirect_to result, allow_other_host: true
  end

  private

  def not_found
    render file: Rails.root.join('/public/404.html'), layout: false, status: :not_found
  end

  def validate_slug
    return not_found if params[:slug].match(/\A[a-zA-Z0-9]*\z/).nil?
  end
end
