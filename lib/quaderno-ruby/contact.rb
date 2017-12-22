class Quaderno::Contact < Quaderno::Base
  include Quaderno::Behavior::Retrieve

  api_model Quaderno::Contact
  api_path 'contacts'
  retrieve_path 'customers'
end
