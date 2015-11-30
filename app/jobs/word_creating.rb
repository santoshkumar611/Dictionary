class WordCreating
	@queue = :critical
	def self.perform(*args)
		puts "#{args[0]["word"]}---#{args[0]["meaning1"]}"
	  @word = Word.create(word: args[0]["word"],meaning1:args[0]["meaning1"])
	  
	end
end