require 'rubygems'
require 'shoulda'
require 'test/unit'
require 'mocha'

lib_dir = "#{File.dirname(__FILE__)}/../lib"
$: << lib_dir unless $:.include?(lib_dir)
require 'pdffilter'

class Rails
  def self.public_path
    File.dirname(__FILE__) + "/public"
  end
end

class LoggerStub
  def debug(message)
    @debug_message = message
  end

  def last_debug_message
    @debug_message
  end

  def info(message)
    @info_message = message
  end

  def last_info_message
    @info_message
  end
end

class PDFFilterTest < Test::Unit::TestCase
  def setup
    @controller = Struct.new(:request, :response, :logger).new
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

  context "A PDF request with an image" do
    setup do
      standard_pdf("<html><body><h1><img src='images/apple.jpg' />Hello from Flying Saucer!</h1></body></html>")
    end

    should "render something" do
      assert_not_nil PDFFilter.filter(@controller)
    end
  end

  def standard_pdf(content)
    @controller.request = stub(:parameters => { :format => "pdf" })
    response_mock = mock()
    @controller.response = response_mock
    @controller.logger = LoggerStub.new
    response_mock.expects(:body).returns(content).at_least_once
    response_mock.expects(:content_type=).with('application/pdf').once
    @headers = {}
    response_mock.expects(:headers).returns(@headers).once
    response_mock.expects(:body=).once
  end

  def invalid_xhtml(content)
    @controller.request = stub(:parameters => { :format => "pdf" })
    response_mock = mock()
    @controller.response = response_mock
    @controller.logger = LoggerStub.new
    response_mock.expects(:body).returns(content).at_least_once
  end

  context "Malformed XHTML" do
    should "report the line number of invalid XHTML with context" do
      invalid_xhtml(<<-EOF)
<html>
  <body>
    <h1>Hello from Flying Saucer!
  </body>
</html>
      EOF
      assert_raise NativeException do
        PDFFilter.filter(@controller)
      end
      assert_match %r[Unable to parse XHTML at line 4], @controller.logger.last_info_message
      assert_match %r[==>\s+4], @controller.logger.last_info_message
    end

    should "complain about XML that isn't" do
      invalid_xhtml(<<-EOF)
some text
that
really
isn't XML
      EOF
      assert_raise NativeException do
        PDFFilter.filter(@controller)
      end
      assert_match %r[==>\s+1 some text], @controller.logger.last_info_message
    end
  end

  context "A PDF request" do
    setup do
      standard_pdf("<html><body><h1>Hello from Flying Saucer!</h1></body></html>")
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

    should "not log debug message if debug turned off" do
      PDFFilter.filter(@controller)
      assert_nil @controller.logger.last_debug_message
    end

    should "log XHTML content if debug turned on" do
      old_debug = PDFFilter.debug?
      PDFFilter.debug = true
      begin
        PDFFilter.filter(@controller)
        assert_match(/<html>/, @controller.logger.last_debug_message)
      ensure
        PDFFilter.debug = old_debug
      end
    end
  end

  context FlyingSaucer4R::UserAgent do
    setup { @user_agent = FlyingSaucer4R::UserAgent.new(org.xhtmlrenderer.pdf.ITextOutputDevice.new(1)) }

    should "treat absolute URIs as relative (Java method name)" do
      assert_equal @user_agent.resolveURI('stylesheets/aim.css'), @user_agent.resolveURI('/stylesheets/aim.css')
    end

    should "treat absolute URIs as relative (Ruby method name)" do
      assert_equal @user_agent.resolve_uri('stylesheets/aim.css'), @user_agent.resolve_uri('/stylesheets/aim.css')
    end
  end

end
