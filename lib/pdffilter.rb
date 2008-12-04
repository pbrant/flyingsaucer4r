require 'flyingsaucer'
require 'java'

class PDFFilter
  class <<self
    def filter(controller)
      format = controller.request.parameters[:format]
      return unless format && format.to_sym == :pdf

      dom = create_java_dom(controller.response.body) 
      estimated_pdf_length = controller.response.body.length
      output = java.io.ByteArrayOutputStream.new(estimated_pdf_length)

      begin
        renderer = org.xhtmlrenderer.pdf.ITextRenderer.new
        renderer.set_document(dom, path_to_url(File.join(RAILS_ROOT, 'public', 'placeholder.html')))
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
  end
end
