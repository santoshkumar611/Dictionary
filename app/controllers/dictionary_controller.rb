require 'unirest'
require 'prawn'
require 'json'
class DictionaryController < ApplicationController
	before_action :set_word ,only: [:search, :bookmarking, :unbookmarking, :showbookmarked, :close, :download]
	def search
		if @word.present?	
		 @bookmarked = @word.bookmarked
		 @hash1 = Hash.new
		 @hash1["word"] = params[:word]
		 @hash1["meaning1"] = @word.meaning1
		 @hash1["meaning2"] = @word.meaning2
		 @hash1["meaning3"] = @word.meaning3
		else
      @hash1 = Hash.new
		  word = params[:word]
      response = HTTParty.get "http://www.dictionaryapi.com/api/v1/references/sd4/xml/#{params[:word]}?key=9f88d753-f6de-4d2c-b2a0-f19862f3cc7f"
      response = Hash.from_xml(response.parsed_response).to_json
      response = JSON.parse(response)
      puts response
      if response["entry_list"]["suggestion"]
        flash[:notice] = "some suggestions for you"
        @suggestions = response["entry_list"]["suggestion"]
      else
        response = response["entry_list"]["entry"]
        if response.class == {}.class
          response = response["def"]["dt"]
        elsif response.class == [].class
          puts  response[0]["def"]
          response = response[0]["def"]["dt"]
        end

        if response.class == {}.class
         @bookmarked = false
         @hash1["word"] = params[:word] 
         @hash1["meaning1"] = response.gsub(':','')
         Word.create(word:params[:word],meaning1:@hash1["meaning1"])
        else
         @bookmarked = false
         @hash1["word"] = params[:word] 
         @hash1["meaning1"] = response[0].gsub(':','')
         if response[1].present?
          @hash1["meaning2"] = response[1].gsub(':','')
         end
         if response[2].present?
          @hash1["meaning3"] = response[2].gsub(':','')
  	     end
          Word.create(word:params[:word],meaning1:@hash1["meaning1"],meaning2:@hash1["meaning2"],meaning3:@hash1["meaning3"])
  	    end
      end
	  end  
  end
  def bookmarking
  	
  	puts "book marking"
   	@word.update(bookmarked: true)

   	@bookmarked = true
  end 
  def unbookmarking
  	#raise params.inspect
   puts "unbookmarking"
   @word.update(bookmarked: false)
   @bookmarked = false
  
  end 
  def showbookmarked
  @words  =  Word.where(bookmarked: true)
  end 
  def index
  @ip_address = request.remote_ip
  end
  def download 
      respond_to do |format|
        format.html
        format.pdf do
           pdf = Prawn::Document.new
           pdf.text "name of the word : #{@word.word}"
           pdf.text "meaning of the word : #{@word.meaning1},#{@word.meaning2},#{@word.meaning3}"
           send_data pdf.render, filename: "#{@word.word}.pdf", type: 'application/pdf'
        end
      end
  end
  
  def chill
    render json: current_user_requests
  end

  private 
  
  def set_word
    #raise params.inspect
   @word = Word.find_by_word(params[:word])

  end

end
