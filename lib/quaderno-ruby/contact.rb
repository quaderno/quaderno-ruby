module Quaderno
  class Contact < Base
    include Quaderno::Behavior::Retrieve

    api_model Quaderno::Contact
    api_path 'contacts'
    retrieve_path 'customers'
  end
end