class Word < ActiveRecord::Base
	validates :word, :meaning1,presence: true
end
