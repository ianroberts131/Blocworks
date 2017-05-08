require_relative '../models/test_model'

class TestController < BlocWorks::Controller
  def welcome
    "This is the welcome action YAY!"
  end
  
  def index
    @tests = TestModel.all
  end
  
  def show
    @test = TestModel.find(params['id'])
  end
  
  def new
    @test = TestModel.new
  end
  
  def create
    
  end
  
  def edit
  end
end