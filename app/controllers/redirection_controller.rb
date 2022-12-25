# frozen_string_literal: true

class RedirectionController < ApplicationController
  def redirect
    url = Url.find_by_slug!(slug_params[:slug])
    redirect_to url.original_url, allow_other_host: true
  end

  private

  def slug_params
    params.permit(:slug)
  end
end
