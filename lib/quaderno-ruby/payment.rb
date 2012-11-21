module Quaderno
  
  class Payment < OpenStruct
  	def method
      marshal_dump[:method]
  	end
  end
  
end