require 'rubygems'
require 'shoulda'
require 'test/unit'
require 'mocha'

lib_dir = "#{File.dirname(__FILE__)}/../lib"
$: << lib_dir unless $:.include?(lib_dir)
require 'pdffilter'

RAILS_ROOT = File.dirname(__FILE__)

class PDFFilterTest < Test::Unit::TestCase
  def setup
    @controller = Struct.new(:request, :response).new
  end

  context "An HTML request" do
    should "exit right away" do 
      @controller.request = stub(:parameters => { :format => "html" })
      assert_nil PDFFilter.filter(@controller)
    end
  end

  context "An request with no specified format" do
    should "exit right away" do 
      @controller.request = stub(:parameters => {})
      assert_nil PDFFilter.filter(@controller)
    end
  end

  context "A PDF request" do
    setup do
      @controller.request = stub(:parameters => { :format => "pdf" })
      response_mock = mock()
      @controller.response = response_mock
      response_mock.expects(:body).returns("<html><body><h1>Hello from Flying Saucer!</h1></body></html>").at_least_once
      response_mock.expects(:content_type=).with('application/pdf').once
      @headers = {}
      response_mock.expects(:headers).returns(@headers).once
      response_mock.expects(:body=).once
    end

    should "render something" do
      assert_not_nil PDFFilter.filter(@controller)
    end
    
    should("render something that looks like a PDF") do
      assert_match(/%PDF/, PDFFilter.filter(@controller))
    end

    should "add headers for ie6" do
      PDFFilter.filter(@controller)
      assert_equal 'public', @headers["Pragma"]
      assert_equal 'maxage=3600', @headers["Cache-Control"]
    end

    should "not overwrite existing ie6 header" do
      @headers['Pragma'] = 'private'
      PDFFilter.filter(@controller)
      assert_equal 'private', @headers["Pragma"]
     end
  end

end
