require 'java'
require 'enumerator'

Dir.glob(File.join(File.dirname(__FILE__), "*.jar")) { |jar| require File.basename(jar) }

module FlyingSaucer4R
  VERSION = '0.6.1'

  class UserAgent < org.xhtmlrenderer.pdf.ITextUserAgent
    def initialize(output_device)
      super
    end

    def resolveURI(uri)
      if uri =~ /^\//
        super(uri[1..uri.length])
      else
        super(uri)
      end
    end
    alias :resolve_uri :resolveURI
  end

  def self.create_pdf(xhtml, base_path, logger = nil)
    estimated_pdf_length = xhtml.length
    output = java.io.ByteArrayOutputStream.new(estimated_pdf_length)

    begin
      dom = create_java_dom(xhtml, logger)
      render_pdf(dom, base_path, output)
    ensure
      output.close
    end
  end

  private
  def self.provide_context(doc, line_no)
    mark_selected = line_no != -1
    line_no = 1 if line_no == -1
    result = doc.enum_for(:each_line).enum_for(:each_with_index).inject([]) do |memo, pair|
      line, current = pair
      current += 1
      diff = line_no - current
      if diff.abs < 20
        format_string = if line_no == current && mark_selected
                          "==> %4d %s"
                        else
                          "    %4d %s"
                        end
        memo << sprintf(format_string, current, line)
      elsif current > line_no
        break memo
      end

      memo
    end

    result.join('')
  end

  def self.create_java_dom(s, logger)
    begin
      builder = javax.xml.parsers.DocumentBuilderFactory.new_instance.new_document_builder
      builder.parse(java.io.ByteArrayInputStream.new(s.to_java_bytes))
    rescue NativeException => e
      java_e = e.cause
      if java_e.is_a?(org.xml.sax.SAXParseException)
        context = provide_context(s, java_e.line_number)
        logger.info("Unable to parse XHTML at line #{java_e.line_number}, column #{java_e.column_number}: #{java_e.message}\n#{context}") if logger
      end
      raise e
    end
  end

  def self.render_pdf(dom, base_path, output)
    renderer = org.xhtmlrenderer.pdf.ITextRenderer.new
    agent = UserAgent.new(renderer.output_device)
    agent.shared_context = renderer.shared_context
    renderer.shared_context.user_agent_callback = agent
    renderer.set_document(dom, path_to_url(base_path))
    renderer.layout

    renderer.create_pdf(output)
    String.from_java_bytes(output.to_byte_array)
  end

  def self.path_to_url(path)
    java.io.File.new(path).to_uri.to_url.to_string
  end
end
