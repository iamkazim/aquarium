# frozen_string_literal: true

# typed: true
module Anemone

  class WorkersController < ApplicationController

    def show

      worker = Worker.find(params[:id])
      render json: worker
    rescue StandardError => e
      render json: { error: e.to_s }

    end

  end

end
