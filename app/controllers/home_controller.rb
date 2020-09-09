require "uri"
require "net/http"
require 'json'

class HomeController < ApplicationController

  skip_around_action :rescue_errors, only: [:error]

  def error
    begin
      @error=session[:error]
      if @error
        @email = "Guest"
        session[:error]=nil

        uri = URI.parse("#{REMORA_SERVER}/error_post")

        header = {'Content-Type': 'text/json'}
        params = {
          'email' => @email,
          'error' => @error.to_json
        }

        # Create the HTTP objects
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.request_uri, header)
        request.body = params.to_json

        # Send the request in a new thread
        # Close the database connection that the thread opens
        Thread.new do
          http.request(request)
          ActiveRecord::Base.connection.close
        end

        render layout: false
      else
        redirect_to "/"
      end
    rescue
      redirect_to "/"
    end
  end

end
