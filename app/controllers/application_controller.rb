class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from WeatherForecastError do |e|
    flash.now[:error] = e.message
    render :error
  end
end
