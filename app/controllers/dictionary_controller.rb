require 'unirest'
require 'prawn'
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
      response = Unirest.get "https://montanaflynn-dictionary.p.mashape.com/define?word="+word+"",
      headers:{
              "X-Mashape-Key" => "VQFQsSTNrdmshEL1WXruXZV6baBpp1SvlXkjsnF3u3ja2S1psj",
              "Accept" => "application/json"
            }
      #raise response.body["definitions"][0]["text"]
      
      if response.body["definitions"].empty?
       flash[:notice] = "enter correct word"
      else
       @bookmarked = false
       @hash1["word"] = params[:word] 
       @hash1["meaning1"] = response.body["definitions"][0]["text"]
       if response.body["definitions"][1].present?
        @hash1["meaning2"] = response.body["definitions"][1]["text"]
       end
       if response.body["definitions"][2].present?
        @hash1["meaning3"] = response.body["definitions"][2]["text"]
	     end
        
        Word.create(word:params[:word],meaning1:@hash1["meaning1"],meaning2:@hash1["meaning2"],meaning3:@hash1["meaning3"])
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
  @ip_address = request.headers["REMOTE_HOST"] 
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
  private 
  
  def set_word
    #raise params.inspect
   @word = Word.find_by_word(params[:word])

  end

end
