defmodule SkepticBotWeb.SeoMetaTagsComponentsTest do
  use SkepticBotWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias SkepticBotWeb.SeoMetaTagsComponents

  describe "seo_meta_tags/1" do
    test "renders meta tags with the values passed" do
      assigns = %{
        description: "Listen to the podcast episodes",
        title: "American Ponzi"
      }

      assert render_component(&SeoMetaTagsComponents.seo_meta_tags/1, attributes: assigns) =~
               "<meta name=\"twitter:card\" content=\"summary_large_image\">\n"

      assert render_component(&SeoMetaTagsComponents.seo_meta_tags/1, attributes: assigns) =~
               "<meta name=\"twitter:site\" content=\"@optimumBA\">\n"

      assert render_component(&SeoMetaTagsComponents.seo_meta_tags/1, attributes: assigns) =~
               "<meta property=\"description\" content=\"Listen to the podcast episodes\">\n"

      assert render_component(&SeoMetaTagsComponents.seo_meta_tags/1, attributes: assigns) =~
               "<meta property=\"og:description\" content=\"Listen to the podcast episodes\">\n"

      assert render_component(&SeoMetaTagsComponents.seo_meta_tags/1, attributes: assigns) =~
               "<meta property=\"og:title\" content=\"American Ponzi\">"
    end

    test "renders meta tags with default values if no attributes are given" do
      assert render_component(&SeoMetaTagsComponents.seo_meta_tags/1, attributes: nil) =~
               "<meta name=\"twitter:card\" content=\"summary_large_image\">"

      assert render_component(&SeoMetaTagsComponents.seo_meta_tags/1, attributes: nil) =~
               "<meta name=\"twitter:description\" content=\"Questions Everything\">"

      assert render_component(&SeoMetaTagsComponents.seo_meta_tags/1, attributes: nil) =~
               "<meta name=\"twitter:image\" content=\"#{url(~p"/images/seo_default_image.png")}\">"

      assert render_component(&SeoMetaTagsComponents.seo_meta_tags/1, attributes: nil) =~
               "<meta name=\"twitter:site\" content=\"@optimumBA\">"

      assert render_component(&SeoMetaTagsComponents.seo_meta_tags/1, attributes: nil) =~
               "<meta name=\"twitter:url\" content=\"#{url(~p"/")}\">"

      assert render_component(&SeoMetaTagsComponents.seo_meta_tags/1, attributes: nil) =~
               "<meta property=\"description\" content=\"Questions Everything\">"

      assert render_component(&SeoMetaTagsComponents.seo_meta_tags/1, attributes: nil) =~
               "<meta property=\"og:description\" content=\"Questions Everything\">"

      assert render_component(&SeoMetaTagsComponents.seo_meta_tags/1, attributes: nil) =~
               "<meta property=\"og:image\" content=\"#{url(~p"/images/seo_default_image.png")}\">"

      assert render_component(&SeoMetaTagsComponents.seo_meta_tags/1, attributes: nil) =~
               "<meta property=\"og:title\" content=\"Skeptic.bot\">"

      assert render_component(&SeoMetaTagsComponents.seo_meta_tags/1, attributes: nil) =~
               "<meta property=\"og:type\" content=\"website\">"

      assert render_component(&SeoMetaTagsComponents.seo_meta_tags/1, attributes: nil) =~
               "<meta property=\"og:url\" content=\"#{url(~p"/")}\">"
    end
  end
end
