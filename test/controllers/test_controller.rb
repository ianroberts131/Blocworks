require_relative '../models/test_model'
class TestController < BlocWorks::Controller
  def welcome
    "This is the welcome action YAY!"
  end
  
  def index
    @tests = Test.new
  end
  
  def show
    @test = Test.find(params[:id])
  end
  
  def new
    @test = Test.new
  end
  
  def create
  end
  
  def edit
  end
end