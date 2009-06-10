require 'flyingsaucer4r'
require 'java'
require 'enumerator'

class PDFFilter
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

  class <<self
    def debug=(b)
      @debug = b
    end
    
    def debug?
      @debug
    end

    def filter(controller)
      format = controller.request.parameters[:format]
      return unless format && format.to_sym == :pdf

      controller.logger.debug("Rendering XHTML to PDF:\n" + controller.response.body) if debug?

      begin
        dom = create_java_dom(controller.response.body) 
      rescue NativeException => e
        java_e = e.cause
        if java_e.is_a?(org.xml.sax.SAXParseException)
          context = provide_context(controller.response.body, java_e.line_number) 
          controller.logger.info("Unable to parse XHTML at line #{java_e.line_number}, column #{java_e.column_number}: #{java_e.message}\n#{context}")
        end
        raise e
      end
      estimated_pdf_length = controller.response.body.length
      output = java.io.ByteArrayOutputStream.new(estimated_pdf_length)

      begin
        renderer = org.xhtmlrenderer.pdf.ITextRenderer.new
        agent = UserAgent.new(renderer.output_device)
        agent.shared_context = renderer.shared_context
        renderer.shared_context.user_agent_callback = agent
        renderer.set_document(dom, resource_path)
        renderer.layout

        renderer.create_pdf(output)
      ensure
        output.close
      end

      controller.response.content_type = 'application/pdf'
      add_ie6_pdf_over_ssl_headers(controller.response.headers)
      controller.response.body = String.from_java_bytes(output.to_byte_array)
    end

    private
    def provide_context(doc, line_no)
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

    def add_ie6_pdf_over_ssl_headers(headers)
      headers["Cache-Control"] ||= 'maxage=3600'
      headers["Pragma"] ||= 'public'
    end

    def create_java_dom(s)
      builder = javax.xml.parsers.DocumentBuilderFactory.new_instance.new_document_builder
      builder.parse(java.io.ByteArrayInputStream.new(s.to_java_bytes))
    end

    def path_to_url(path)
      java.io.File.new(path).to_uri.to_url.to_string
    end

    def resource_path
      if Object.const_defined? "PUBLIC_ROOT"
        puts Object.const_get("PUBLIC_ROOT")
        path_to_url(File.join(PUBLIC_ROOT, 'placeholder.html'))
      else
        path_to_url(File.join(RAILS_ROOT, 'public', 'placeholder.html'))
      end
    end
  end
end
