# frozen_string_literal: true

module Api
  module V1
    class UrlController < ApplicationController
      before_action :decode_params, only: [:decode]
      before_action :encode_params, only: [:encode]

      def encode
        result = Rails.cache.fetch("encode_original_url:#{encode_params[:original_url]}") do
          Url.encode(encode_params[:original_url])
        end
        return render json: { status: false, errors: result }, status: :unprocessable_entity if result.is_a?(Array)

        render json: { status: true, data: [{ shortened_url: result }] }, status: :ok
      end

      def decode
        result = Rails.cache.fetch("decode_shortened_url:#{decode_params[:shortened_url]}") do
          Url.decode(decode_params[:shortened_url])
        end
        return render json: { status: false, errors: result }, status: :unprocessable_entity if result.is_a?(Array)

        render json: { status: true, data: [{ original_url: result }] }, status: :ok
      end

      private

      def encode_params
        @encode_params ||= params.require(:url).permit(:original_url)
      rescue ActionController::ParameterMissing
        render json: { status: false, errors: ['Original URL is required'] }, status: :unprocessable_entity
      end

      def decode_params
        @decode_params ||= params.require(:url).permit(:shortened_url)
      rescue ActionController::ParameterMissing
        render json: { status: false, errors: ['Shorten URL is required'] }, status: :unprocessable_entity
      end
    end
  end
end
