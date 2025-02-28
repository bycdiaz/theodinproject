require 'rails_helper'
require './lib/kramdown/document_sections'

RSpec.describe MarkdownConverter do
  describe '#as_html' do
    it 'converts the markdown to html with sections' do
      markdown = <<~MARKDOWN
        ### First section header
        some content

        ### Second section header
        some content

        ### Third section header
        some content
      MARKDOWN

      result = <<~HTML
        <section data-title="first-section-header">
          <h3 id="first-section-header"><a href="#first-section-header" class="anchor-link">First section header</a></h3>
          <p>some content</p>

        </section>
        <section data-title="second-section-header">
          <h3 id="second-section-header"><a href="#second-section-header" class="anchor-link">Second section header</a></h3>
          <p>some content</p>

        </section>
        <section data-title="third-section-header">
          <h3 id="third-section-header"><a href="#third-section-header" class="anchor-link">Third section header</a></h3>
          <p>some content</p>
        </section>
      HTML

      expect(described_class.new(markdown).as_html).to eq(result)
    end

    context 'when the markdown starts with an unsectionable header' do
      it 'converts the markdown to html with a generic section first' do
        markdown = <<~MARKDOWN
          # Unsectionable Header
          some content

          ### Sectionable Header
          some content
        MARKDOWN

        html_result = <<~HTML
          <section data-title="content">
            <h1 id="unsectionable-header">Unsectionable Header</h1>
            <p>some content</p>

          </section>
          <section data-title="sectionable-header">
            <h3 id="sectionable-header"><a href="#sectionable-header" class="anchor-link">Sectionable Header</a></h3>
            <p>some content</p>
          </section>
        HTML

        expect(described_class.new(markdown).as_html).to eq(html_result)
      end
    end

    context 'when the markdown contains external links' do
      it 'applies target and rel attributes to the external links' do
        markdown = <<~MARKDOWN
          [an internal link](/paths)

          [an external link](https://www.example.com)
        MARKDOWN

        html_result = <<~HTML
          <p><a href="/paths">an internal link</a></p>

          <p><a href="https://www.example.com" target="_blank" rel="noopener noreferrer">an external link</a></p>
        HTML

        expect(described_class.new(markdown).as_html).to eq(html_result)
      end
    end

    context 'when the markdown contains images' do
      it 'wraps images in links when alt attr is valid string' do
        markdown = <<~MARKDOWN
          ![an image](https://example.com/image.jpeg)
        MARKDOWN

        html_result = <<~HTML
          <p><a href="https://example.com/image.jpeg" target="_blank" rel="noopener noreferrer"><img src="https://example.com/image.jpeg" alt="an image" /></a></p>
        HTML

        expect(described_class.new(markdown).as_html).to eq(html_result)
      end

      it 'does not wrap images in links when alt attr is empty string' do
        markdown = <<~MARKDOWN
          ![](https://example.com/image.jpeg){: alt=""}
        MARKDOWN

        html_result = <<~HTML
          <p><img src="https://example.com/image.jpeg" alt="" /></p>
        HTML

        expect(described_class.new(markdown).as_html).to eq(html_result)
      end
    end

    context 'when the markdown does not have any sections' do
      it 'converts the markdown to html without sections' do
        markdown = <<~MARKDOWN
          # Header
          some content
        MARKDOWN

        html_result = <<~HTML
          <h1 id="header">Header</h1>
          <p>some content</p>
        HTML

        expect(described_class.new(markdown).as_html).to eq(html_result)
      end
    end

    context 'when the markdown includes section headings that contain apostrophes' do
      it 'can convert headings with apostrophes' do
        markdown = <<~MARKDOWN
          ### It's a header
          content
        MARKDOWN

        html_result = <<~HTML
          <section data-title="its-a-header">
            <h3 id="its-a-header"><a href="#its-a-header" class="anchor-link">It’s a header</a></h3>
            <p>content</p>
          </section>
        HTML

        expect(described_class.new(markdown).as_html).to eq(html_result)
      end
    end

    context 'when the markdown includes backtick fenced codeblocks' do
      it 'converts the markdown with appropriate code format' do
        markdown = <<~MARKDOWN
          ```ruby
          puts 'this should work'
          ```
        MARKDOWN

        html_result = <<~HTML
          <div class="language-ruby highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="nb">puts</span> <span class="s1">'this should work'</span>
          </code></pre></div></div>
        HTML

        expect(described_class.new(markdown).as_html).to eq(html_result)
      end
    end
  end
end
