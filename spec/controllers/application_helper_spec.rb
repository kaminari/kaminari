require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ApplicationController < ActionController::Base; end
class UsersController < ApplicationController
  def index
    @users = User.page params[:page]
    render :inline => '<%= paginate @users %>'
  end
end

describe UsersController, 'pagination' do
  render_views
  before do
    1.upto(30) {|i| User.create! :name => "user#{'%02d' % i}" }
  end

  it 'renders' do
    get :index
    response.body.should =~ /pagination/
  end
end
