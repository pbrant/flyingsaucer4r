require 'flyingsaucer4r'
require 'java'
require 'enumerator'

class PDFFilter
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

      pdf = FlyingSaucer4R.create_pdf(
        controller.response.body,
        File.join(Rails.public_path, 'placeholder.html'),
        controller.logger)

      controller.response.content_type = 'application/pdf'
      add_ie6_pdf_over_ssl_headers(controller.response.headers)
      controller.response.body = pdf
    end

    private
    def add_ie6_pdf_over_ssl_headers(headers)
      headers["Cache-Control"] ||= 'maxage=3600'
      headers["Pragma"] ||= 'public'
    end
  end
end
