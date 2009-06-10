= flyingsaucer4r

== DESCRIPTION:

The Flying Saucer gem gives JRuby access to the Flying Saucer XHTML renderer.
It also provides Rails integration to simplify sending PDFs generated from
XHTML to the browser.

== SYNOPSIS:

To add Flying Saucer to the JRuby classpath:

    require 'flyingsaucer4r'

To use within Rails:

    require 'pdffilter'

    class ApplicationController < ActionController::Base
      after_filter PDFFilter

      ...
    end

Now any request with a :format of 'pdf' will be turned into a PDF using Flying
Saucer on the way out to the browser.

== REQUIREMENTS:

* None (but the Rails integration only makes sense if you are using Rails)

== INSTALL:

    jruby -S gem install pbrant-flyingsaucer4r

== LICENSE:

Copyright (c) 2008 Consolidated Court Automation Programs
