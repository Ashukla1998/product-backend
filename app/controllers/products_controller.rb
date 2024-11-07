class ProductsController < ApplicationController
  require 'open-uri'
  require 'nokogiri'

  def index
    # case params 
    # when [:search]
    #   @product = ProductDetail.find_by(title: params[:title])
    #   render json: @product,status: :ok 
    # when[:filter]
    #   @product = ProductDetail.order_by(params[:filter])
    #   render json: @product,status: :ok 
    # else
    #   render json: {error: "wrong input"}
    # end
    @products = ProductDetail.all 
    if @products.present?
      products_images = @products.map do |product|
        product_image_url = product.image.attached? ? url_for(product.image) : nil
        product.attributes.merge('image' => product_image_url)
      end
      render json: products_images,status: :ok 
    else
      render json: {error: "No Product Found ?"},status: :not_found
    end      
  end

  def show
    @product = ProductDetail.find_by(id: params[:id])
    if @product.present?
      if @product.image.attached?
        # @product = @product.attributes.merge('image' => rails_blob_path(@product.image, only_path: true))
        @product = @product.attributes.merge('image' => url_for(@product.image))
      else
        @product = @product.attributes.merge('image' => nil)
      end

      render json: @product, status: :ok
    else
      render json: { error: "No Product Found" }, status: :not_found
    end
  end

  def scrap_products
    # debugger
    url = params[:url]
    if url.present?
      scraped_data = scrape_product_data(url)
      if scraped_data
        @product = ProductDetail.create(scraped_data)
        render json: @product, status: :created
      else
        render json: { error: "Failed to scrape product data" }, status: :unprocessable_entity
      end
    else
      render json: { error: "No URL provided" }, status: :bad_request
    end
  end

  private
  def scrape_product_data(url)
    begin
      html = URI.parse(url).open("User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36")
      doc = Nokogiri::HTML(html)
      # debugger
      # doc = Nokogiri::HTML(html)

      {
        title: doc.css('.B_NuCI').text.strip,
        price: doc.css('._30jeq3._16Jk6d').text.strip,
        description: doc.css('.description').text.strip,
        size: doc.css('.size').text.strip,
        category: doc.css('.category').text.strip
      }
    rescue => e
      Rails.logger.error("Scraping error: #{e.message}")
      nil
    end
  end
end
