require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
