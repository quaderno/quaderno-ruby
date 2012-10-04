module Quaderno
  class Contact < Base
    include Quaderno::Behavior::Crud    
    
    api_model Quaderno::Contact
    api_path 'contacts'
    
  end
end