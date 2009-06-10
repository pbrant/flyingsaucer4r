# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{flyingsaucer}
  s.version = "0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["CCAP Web Team"]
  s.date = %q{2009-06-10}
  s.description = %q{The Flying Saucer gem gives JRuby access to the Flying Saucer XHTML renderer. It also provides Rails integration to simplify sending PDFs generated from XHTML to the browser.}
  s.email = ["CCAP_Web_Team@wicourts.gov"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "lib/flyingsaucer.rb", "lib/flyingsaucer/version.rb", "lib/itext-2_0_8_02.jar", "lib/pdffilter.rb", "lib/xhtmlrenderer20081112-core-renderer.jar", "test/test_pdffilter.rb"]
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{flyingsaucer}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{The Flying Saucer gem gives JRuby access to the Flying Saucer XHTML renderer}
  s.test_files = ["test/test_pdffilter.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 1.9.0"])
    else
      s.add_dependency(%q<hoe>, [">= 1.9.0"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.9.0"])
  end
end
