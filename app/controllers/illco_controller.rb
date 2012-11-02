class IllcoController < ApplicationController
  # http_basic_authenticate_with name: "meeps", password: "@g3rr3ds3cur3!", except: :index
  def index
    render :layout => 'illco'
  end
end
