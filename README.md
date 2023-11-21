# quaderno-ruby

Quaderno-ruby is a ruby wrapper for the [Quaderno API](https://developers.quaderno.io/api).

Current version is 3.0.1 → See the changelog [here](https://github.com/quaderno/quaderno-ruby/blob/master/changelog.md).

To learn more about our API and ecosystem, check [developers.quaderno.io](https://developers.quaderno.io).

## Installation & Configuration

To install add the following to your Gemfile:

```ruby
  gem 'quaderno', require: 'quaderno-ruby'
```

To configure just add this to your initializers

```ruby
  Quaderno::Base.configure do |config|
    config.auth_token = 'my_authenticate_token'
    config.url = 'https://my_subdomain.quadernoapp.com/api/'
    config.api_version = API_VERSION # Optional, defaults to the API version set in your account
    config.user_agent_header = 'my custom user agent' # Optional, will make support for your account more efficient if you are doing OAuth integrations
  end
```

## Quaderno Sandbox

Quaderno Sandbox is our public staging environment, a safe space to experiment with our set of APIs and products. As a completely separate environment, it has its own URL https://sandbox-quadernoapp.com and credentials.

It's perfect for your first steps with our tools. Please check https://developers.quaderno.io/developer-tools/sandbox/ to learn about its test data and limitations.

## Get authorization data

You can get your account subdomain by grabbing it from your account URL or by calling the authorization method with your personal API token.

```ruby
  response = Quaderno::Base.authorization 'my_authenticate_token', environment #=> Quaderno::Base
  response.identity # => {"id"=>737000, "name"=>"Walter White", "email"=>"cooking@br.bd", "href"=>"https://my_subdomain.quadernoapp.com/api/"}
```

Note that `environment` is an optional argument. By passing `:sandbox`, you will retrieve your credentials for the sandbox environment and not for production.

This will return a hash with the information about your API URL, which includes the account subdomain.

## Ping the service

You can ping the service in order to check if it is up with:

```ruby
  response = Quaderno::Base.ping #=> Quaderno::Base

  response.status #=> Boolean
```

This will return `status: true` if the service is up or `status: false` if it is not.

## Check the rate limit

```ruby
  response = Quaderno::Base.ping #=> Quaderno::Base
  response.rate_limit_info #=>  { :reset=> 4, :remaining=> 0 }

```

This will return a hash with information about the seconds until the rate limit reset and your remaining requests per minute ([check the API documentation for more information](https://developers.quaderno.io/api#tag/API-features/Rate-Limiting)).

You can also check the rate limit for each request by checking the `rate_limit_info` method on the response:

```ruby

  invoices = Quaderno::Invoice.all #=> Quaderno::Collection
  invoices.rate_limit_info #=> {:reset=> 5, :remaning=>6}

  invoice = Quaderno::Invoice.find INVOICE_ID #=> Quaderno::Invoice
  invoice.rate_limit_info #=> {:reset=>4, :remaining=>5}

  result = invoice.deliver #=> Quaderno::Base
  result.rate_limit_info #=> {:reset=>3, :remaining=>4}

  begin
    deleted_invoice = Quaderno::Invoice.delete(ANOTHER_INVOICE_ID) #=> Quaderno::Invoice
  rescue Quaderno::Exceptions::InvalidSubdomainOrToken => e
    # If the exception is triggered you can check the rate limit on the raised exception
    e.rate_limit_info #=> {:reset=>2, :remaining=>3}
  end

  deleted_invoice.rate_limit_info #=> {:reset=>2, :remaining=>3}

  # etc.
```

## Reading the values

Quaderno-ruby parses all the json responses in human readable data, so you can access each value just like this:

```ruby
  contact.id
  invoice.items
  estimates.payments
  etc.
```

## Managing contacts

### Getting contacts

```ruby
 Quaderno::Contact.all #=> Array
```

 will return an array with all your contacts. You can also pass query strings using the attribute :q in order to filter the results by contact name. For example:

```ruby
 Quaderno::Contact.all(q: 'John Doe') #=> Array
```

### Finding a contact

```ruby
 Quaderno::Contact.find(id) #=> Quaderno::Contact
```

will return the contact with the id passed as parameter.

### Retrieving a contact by its payment gateway customer ID

```ruby
 Quaderno::Contact.retrieve(PAYMENT_GATEWAY_CUSTOMER_ID, PAYMENT_GATEWAY) #=> Quaderno::Contact
```

will return the contact with the customer id passed as parameter.

### Creating a new contact

```ruby
 Quaderno::Contact.create(params) #=> Quaderno::Contact
```

will create a contact using the information of the hash passed as parameter and return an instance of Quaderno::Contact with the created contact.

### Updating an existing contact

```ruby
 Quaderno::Contact.update(id, params) #=> Quaderno::Contact
```

will update the specified contact with the data of the hash passed as second parameter.

### Deleting a contact

```ruby
  Quaderno::Contact.delete(id) #=> Quaderno::Contact
```

will delete the contact with the id passed as parameter. If the deletion was successful, an instance of `Quaderno::Contact` with the `deleted` attribute set to `true` will be returned.

## Managing items

### Getting items

```ruby
  Quaderno::Item.all #=> Array
```

will return an array with all your items.

### Finding an item

```ruby
  Quaderno::Item.find(id) #=> Quaderno::Item
```

will return the items with the id passed as parameter.

### Creating a new item

```ruby
 Quaderno::Item.create(params) #=> Quaderno::Item
```

will create an item using the information of the hash passed as parameter and return an instance of Quaderno::Item with the created contact.

### Updating an existing item

```ruby
 Quaderno::Item.update(id, params) #=> Quaderno::Item
```

will update the specified item with the data of the hash passed as second parameter.

### Deleting an item

```ruby
  Quaderno::Item.delete(id) #=> Quaderno::Item
```

will delete the item with the id passed as parameter.  If the deletion was successful, an instance of `Quaderno::Item` with the `deleted` attribute set to `true` will be returned.

## Managing transactions

### Creating a new transaction

```ruby
  Quaderno::Transaction.create(params) #=> Quaderno::Transaction
```

will create a sale or refund transaction using the information of the hash passed as parameter.

## Managing invoices

### Getting invoices

```ruby
  Quaderno::Invoice.all #=> Array
```

 will return an array with all your invoices. You can also pass query strings using the attribute :q in order to filter the results by contact name, :state to filter by state or :date to filter by date

### Finding an invoice

```ruby
  Quaderno::Invoice.find(id) #=> Quaderno::Invoice
```

will return the invoice with the id passed as parameter.

### Retrieving an invoice by its payment gateway transaction ID

```ruby
 Quaderno::Invoice.retrieve(PAYMENT_GATEWAY_TRANSACTION_ID, PAYMENT_GATEWAY) #=> Quaderno::Invoice
```

will return the invoice with the transaction id passed as parameter.

### Creating a new invoice

```ruby
  Quaderno::Invoice.create(params) #=> Quaderno::Invoice
```

will create an invoice using the information of the hash passed as parameter.

### Updating an existing invoice

```ruby
  Quaderno::Invoice.update(id, params) #=> Quaderno::Invoice
```

will update the specified invoice with the data of the hash passed as second parameter.

### Deleting an invoice

```ruby
  Quaderno::Invoice.delete(id) #=> Quaderno::Invoice
```

will delete the invoice with the id passed as parameter. If the deletion was successful, an instance of `Quaderno::Item` with the `deleted` attribute set to `true` will be returned.

### Adding or removing a payment

In order to  add a payment you will need the Invoice instance you want to update.

```ruby
  invoice = Quaderno::Invoice.find(invoice_id)
  invoice.add_payment(params) #=> Quaderno::Payment
```

Where params is a hash with the payment information. The method will return an instance of Quaderno::Payment wich contains the information of the payment.

In order to  remove a payment you will need the Invoice instance you want to update.

```ruby
  invoice = Quaderno::Invoice.find(invoice_id)
  invoice.remove_payment(payment_id) #=> Boolean
```

### Delivering the invoice

  In order to deliver the invoice to the default recipient you will need the invoice you want to send.

```ruby
  invoice = Quaderno::Invoice.find(invoice_id)
  result = invoice.deliver #=> Quaderno::Base

  result.success #=> Boolean
```

## Managing credits

### Getting credits

```ruby
  Quaderno::Credit.all #=> Array
```

 will return an array with all your credit notes. You can also pass query strings using the attribute :q in order to filter the results by contact name, :state to filter by state or :date to filter by date

### Finding a credit

```ruby
  Quaderno::Credit.find(id) #=> Quaderno::Credit
```

will return the credit with the id passed as parameter.

### Retrieving a credit by its payment gateway transaction ID

```ruby
 Quaderno::Credit.retrieve(PAYMENT_GATEWAY_TRANSACTION_ID, PAYMENT_GATEWAY) #=> Quaderno::Credit
```

will return the credit note with the transaction id passed as parameter.

### Creating a new credit

```ruby
  Quaderno::Credit.create(invoice_id: 42) #=> Quaderno::Credit
```

will create a credit from the invoice specified in the parameter.

### Updating an existing credit

```ruby
  Quaderno::Credit.update(id, params) #=> Quaderno::Credit
```

will update the specified credit with the data of the hash passed as second parameter.

### Deleting a credit

```ruby
  Quaderno::Credit.delete(id) #=> Quaderno::Credit
```

will delete the credit with the id passed as parameter. If the deletion was successful, an instance of `Quaderno::Credit` with the `deleted` attribute set to `true` will be returned.

### Adding or removing a payment

 In order to  add a payment you will need the Credit instance you want to update.

```ruby
  credit = Quaderno::Credit.find(credit_id)
  credit.add_payment(params) #=> Quaderno::Payment
```

Where params is a hash with the payment information. The method will return an instance of Quaderno::Payment wich contains the information of the payment.

In order to  remove a payment you will need the Credit instance you want to update.

```ruby
  credit = Quaderno::Credit.find(credit_id)
  credit.remove_payment(payment_id) #=> Quaderno::Payment
```

If the deletion was successful, an instance of `Quaderno::Payment` with the `deleted` attribute set to `true` will be returned.

### Delivering the credit

  In order to deliver the credit to the default recipient you will need the credit you want to send.

```ruby
  credit = Quaderno::Credit.find(credit_id)
  result = credit.deliver #=> Quaderno::Base

  result.success #=> Boolean
```

## Managing estimates

### Getting estimates

```ruby
  Quaderno::Estimate.all #=> Array
```

 will return an array with all your estimates.

### Finding an estimate

```ruby
  Quaderno::Estimate.find(id) #=> Quaderno::Estimate
```

will return the estimate with the id passed as parameter.

### Creating a new estimate

```ruby
  Quaderno::Estimate.create(params) #=> Quaderno::Estimate
```

will create an estimate using the information of the hash passed as parameter.

### Updating an existing estimate

```ruby
  Quaderno::Estimate.update(id, params)
```

will update the specified estimate with the data of the hash passed as second parameter.

### Deleting an estimate

```ruby
  Quaderno::Estimate.delete(id) #=> Quaderno::Estimate
```

will delete the estimate with the id passed as parameter. If the deletion was successful, an instance of `Quaderno::Contact` with the `deleted` attribute set to `true` will be returned.

### Adding or removing a payment

In order to add a payment you will need the estimate you want to update.

```ruby
  estimate = Quaderno::Estimate.find(estimate_id)
  estimate.add_payment(params) #=> Quaderno::Payment
```

Where params is a hash with the payment information. The method will return an instance of Quaderno::Payment wich contains the information of the payment.

In order to  remove a payment you will need the estimate you want to update.

```ruby
  estimate = Quaderno::Estimate.find(estimate_id)
  estimate.remove_payment(payment_id) #=> Boolean
```

### Delivering the estimate

In order to deliver the estimate to the default recipient you will need the estimate you want to send.

```ruby
  estimate = Quaderno::Estimate.find(estimate_id)
  result = estimate.deliver #=> Quaderno::Base

  result.success #=> Boolean
```

## Managing expenses

### Getting expenses

```ruby
 Quaderno::Expense.all #=> Array
```

 will return an array with all your expenses. You can also pass query strings using the attribute :q in order to filter the results by contact name, :state to filter by state or :date to filter by date.

### Finding an expense

```ruby
 Quaderno::Expense.find(id) #=> Quaderno::Expense
```

will return the expense with the id passed as parameter.

### Creating a new expense

```ruby
 Quaderno::Expense.create(params) #=> Quaderno::Expense
```

will create an expense using the information of the hash passed as parameter and return an instance of Quaderno::Expense with the created expense.

### Updating an existing expense

```ruby
 Quaderno::Expense.update(id, params) #=> Quaderno::Expense
```

will update the specified expense with the data of the hash passed as second parameter.

### Deleting an expense

```ruby
  Quaderno::Expense.delete(id) #=> Quaderno::Expense
```

will delete the expense with the id passed as parameter. If the deletion was successful, an instance of `Quaderno::Expense` with the `deleted` attribute set to `true` will be returned.

## Managing recurrings

### Getting recurrings

```ruby
  Quaderno::Recurring.all #=> Array
```

 will return an array with all your recurring notes. You can also pass query strings using the attribute :q in order to filter the results by contact name, :state to filter by state or :date to filter by date

### Finding a recurring

```ruby
  Quaderno::Recurring.find(id) #=> Quaderno::Recurring
```

will return the recurring with the id passed as parameter.

### Creating a new recurring

```ruby
  Quaderno::Recurring.create(params) #=> Quaderno::Recurring
```

will create a recurring using the information of the hash passed as parameter.

### Updating an existing recurring

```ruby
  Quaderno::Recurring.update(id, params) #=> Quaderno::Recurring
```

will update the specified recurring with the data of the hash passed as second parameter.

### Deleting a recurring

```ruby
  Quaderno::Recurring.delete(id) #=> Quaderno::Recurring
```

will delete the recurring with the id passed as parameter. If the deletion was successful, an instance of `Quaderno::Recurring` with the `deleted` attribute set to `true` will be returned.

## Managing webhooks

### Getting webhooks

```ruby
 Quaderno::Webhook.all #=> Array
```

 will return an array with all the webhooks you have subscribed.

### Finding a webhook

```ruby
 Quaderno::Webhook.find(id) #=> Quaderno::Webhook
```

will return the webhook with the id passed as parameter.

### Creating a new webhook

```ruby
 Quaderno::Webhook.create(params) #=> Quaderno::Webhook
```

will create a webhook using the information of the hash passed as parameter and return an instance of Quaderno::Webhook with the created webhook.

### Updating an existing webhook

```ruby
 Quaderno::Webhook.update(id, params) #=> Quaderno::Webhook
```

will update the specified webhook with the data of the hash passed as second parameter.

### Deleting a webhook

```ruby
  Quaderno::Webhook.delete(id) #=> Quaderno::Webhook
```

will delete the webhook with the id passed as parameter. If the deletion was successful, an instance of `Quaderno::Webhook` with the `deleted` attribute set to `true` will be returned.

## Tax rates

### Calculating taxes

```ruby
 Quaderno::TaxRate.calculate(params) #=> Quaderno::TaxRate
```

will calculate the taxes applied for a customer based on the data pased as parameters.

## Tax jurisdictions

### Listing tax jurisdictions

```ruby
 Quaderno::TaxJurisdiction.all #=> Array
```

 will return an array with all the tax jurisdictions supported in Quaderno.

### Finding a tax jurisdiction

```ruby
 Quaderno::TaxJurisdiction.find(id) #=> Quaderno::TaxJurisdiction
```

will return the tax jurisdiction with the id passed as parameter.

## Tax codes

### Listing tax codes

```ruby
 Quaderno::TaxCode.all #=> Array
```

 will return an array with all the tax codes supported in Quaderno.

### Finding a tax jurisdiction

```ruby
 Quaderno::TaxCode.find(id) #=> Quaderno::TaxCode
```

will return the tax code with the id passed as parameter.

## Managing Tax ids

### Getting tax ids

```ruby
 Quaderno::TaxId.all #=> Array
```

 will return an array with all the tax ids in the target account.

### Finding a tax id

```ruby
 Quaderno::TaxId.find(id) #=> Quaderno::TaxId
```

will return the tax id with the id passed as parameter.

### Adding a new tax id

```ruby
 Quaderno::TaxId.create(params) #=> Quaderno::TaxId
```

will create a tax id using the information of the hash passed as parameter and return an instance of Quaderno::TaxId with the created tax id.

### Updating an existing tax id

```ruby
 Quaderno::TaxId.update(id, params) #=> Quaderno::TaxId
```

will update the specified tax id with the data of the hash passed as second parameter.

### Deleting a tax id

```ruby
  Quaderno::TaxId.delete(id) #=> Quaderno::TaxId
```

will delete the tax id with the id passed as parameter. If the deletion was successful, an instance of `Quaderno::TaxId` with the `deleted` attribute set to `true` will be returned.

### Validate a tax id

```ruby
 country = 'IE'
 tax_id = 'IE6388047V'

 result = Quaderno::TaxId.validate(country, tax_id) #=> Quaderno::TaxId

 result.valid #=> Boolean or nil
```

will validate the tax ID or business number for the specified country.

## Evidences

### Creating location evidences

```ruby
 Quaderno::Evidence.create(params) #=> Quaderno::Evidence
```

will create an evidence based on the data pased as parameters.

## Checkout Sessions

### Getting checkout sessions
```ruby
 Quaderno::CheckoutSession.all #=> Array
```

 will return an array with all the checkout sessions in your account.

### Finding a checkout session

```ruby
 Quaderno::CheckoutSession.find(id) #=> Quaderno::CheckoutSession
```

will return the checkout session with the id passed as parameter.

### Creating a new checkout session

```ruby
 Quaderno::CheckoutSession.create(params) #=> Quaderno::CheckoutSession
```

will create a checkout session using the information of the hash passed as parameter and return an instance of Quaderno::CheckoutSession with the created checout session.

### Updating an existing checkout session

```ruby
 Quaderno::CheckoutSession.update(id, params) #=> Quaderno::CheckoutSession
```

will update the specified checkout session with the data of the hash passed as second parameter.

### Deleting a checkout session

```ruby
  Quaderno::CheckoutSession.delete(id) #=> Quaderno::CheckoutSession
```

will delete the checkout session with the id passed as parameter. If the deletion was successful, an instance of `Quaderno::CheckoutSession` with the `deleted` attribute set to `true` will be returned.

## Managing report requests

### Getting report requests

```ruby
  Quaderno::ReportRequest.all #=> Array
```

 will return an array with all your report requests.

### Finding a report request

```ruby
  Quaderno::ReportRequest.find(id) #=> Quaderno::ReportRequest
```

will return the report request with the id passed as parameter.

### Creating a new report request

```ruby
  Quaderno::ReportRequest.create(params) #=> Quaderno::ReportRequest
```

will create a report request using the information of the hash passed as parameter and return an instance of Quaderno::ReportRequest with the created report request.

## Connect: Managing custom accounts

### Getting custom accounts

```ruby
  Quaderno::Account.all #=> Array
```

 will return an array with all your custom accounts

### Finding a custom account

```ruby
  Quaderno::Account.find(id) #=> Quaderno::Account
```

will return the account with the id passed as parameter.

### Creating a new custom account

```ruby
  Quaderno::Account.create(params) #=> Quaderno::Account
```

will create a custom account using the information of the hash passed as parameter.

### Updating an existing custom account

```ruby
  Quaderno::Account.update(id, params) #=> Quaderno::Account
```

will update the specified custom account with the data of the hash passed as second parameter.

### Deactivating a custom account

```ruby
  Quaderno::Account.deactivate(id) #=> Quaderno::Account
```

will deactivate the custom account with the id passed as parameter.

### Activating a custom account

```ruby
  Quaderno::Account.activate(id) #=> Quaderno::Account
```

will activate the custom account with the id passed as parameter.

## Connect: Managing addresses

### Getting addresses

```ruby
  Quaderno::Address.all(access_token: ACCESS_TOKEN) #=> Array
```

 will return an array with all the addresses of the target custom account

### Finding a address

```ruby
  Quaderno::Address.find(id, access_token: ACCESS_TOKEN) #=> Quaderno::Address
```

will return the address with the id passed as parameter.

### Creating a new address

```ruby
  Quaderno::Address.create(params.merge(access_token: ACCESS_TOKEN)) #=> Quaderno::Address
```

will add an address on the target custom account using the information of the hash passed as parameter.

### Updating an existing address

```ruby
  Quaderno::Address.update(id, params.merge(access_token: ACCESS_TOKEN)) #=> Quaderno::Address
```

will update the specified address with the data of the hash passed as second parameter.


## Exceptions

Quaderno-ruby exceptions raise depending on the type of error:

```ruby
  Quaderno::Exceptions::UnsupportedApiVersion # Raised when the API version set is not supported.

  Quaderno::Exceptions::InvalidSubdomainOrToken # Raised when the credentials are wrong, missing or do not match the permission for some object.

  Quaderno::Exceptions::InvalidID # Raised when the requested resource by ID does not exist in the account context.

  Quaderno::Exceptions::InvalidRequest # Raised when the requested requirements are not fulfilled.

  Quaderno::Exceptions::ThrottleLimitExceeded # Raised when the throttle limit is exceeded.

  Quaderno::Exceptions::RateLimitExceeded # Raised when the rate limit is exceeded.

  Quaderno::Exceptions::HasAssociatedDocuments # Raised when trying to delete a contact with associated documents.

  Quaderno::Exceptions::RequiredFieldsEmptyOrInvalid # Raised if the format of the request is right but some validations failed. You can JSON parse the exception message to get which field triggered the exception. For example: '{"errors":{"vat_number":["is not a valid German vat number"]}}'

  Quaderno::Exceptions::ServerError # Raised when Quaderno returns an HTTP response code of the 50X family. Try again later or contact support if the issue persists
```

All those exceptions inherit from `Quaderno::Exceptions::BaseException`.

You can inspect a the error response from the API by rescuing the exception and checking `response_body`:

```ruby
begin
  Quaderno::Invoice.find WRONG_ID
rescue Quaderno::Exceptions::BaseException => e
  e.response_body # =>  {"error"=>"Unauthorized access or document does not exist."}
end
```


### Pagination information

Whenever you call the `all` method on one of the classes, the result will be a `Quaderno::Collection`. For example:

```ruby
collection = Quaderno::Contact.all

collection.class #=> Quaderno::Collection
collection.has_more? #=> true
collection.next_page #=> another instance of
```

The `next_page` method is an abstraction for the `created_before` parameter, which you may also use with the `all` method.

```ruby
collection = Quaderno::Contact.all

Quaderno::Contact.all(created_before: collection.last.id)
```

You can also use the `limit` parameter to determine how many results to retrieve. Its default is `25`, and Quaderno will cap the limit at `100`.

```ruby
collection = Quaderno::Contact.all(limit: 50)

collection.length #=> 50
```

### Thread-safe configuration

If you are managing multiple accounts you may need a thread-safe way to configure the credentials. You can do it by passing the credentials on each request:

```ruby
Quaderno::Invoice.all(
  api_url: 'https://my_subdomain.quadernoapp.com/api/',
  auth_token: 'my_authenticate_token'
)

Quaderno::Invoice.find(INVOICE_ID,
  api_url: 'https://my_subdomain.quadernoapp.com/api/',
  auth_token: 'my_authenticate_token'
)

Quaderno::Invoice.update(INVOICE_ID,
  po_number: '12345',
  api_url: 'https://my_subdomain.quadernoapp.com/api/',
  auth_token: 'my_authenticate_token'
)

invoice = Quaderno::Invoice.find(INVOICE_ID,
  api_url: 'https://my_subdomain.quadernoapp.com/api/',
  auth_token: 'my_authenticate_token'
)

invoice.add_payment(params) # Credentials are already stored on the Quaderno::Invoice instance from the first request

invoice = Quaderno::Invoice.find(INVOICE_ID,
  api_url: 'https://my_subdomain.quadernoapp.com/api/',
  auth_token: 'my_authenticate_token'
)
invoice.remove_payment(PAYMENT_ID) # Credentials are already stored on the Quaderno::Invoice instance from the first request

Quaderno::Invoice.delete(INVOICE_ID,
  api_url: 'https://my_subdomain.quadernoapp.com/api/',
  auth_token: 'my_authenticate_token'
)
```

## More information

Remember this is only a ruby wrapper for the Quaderno API. Checkout our [OpenAPI documentation](https://developers.quaderno.io/api)!

If you need examples of `params` objects, head to our tests. For instance, in case you're an online store and want to register your sales and refunds, [here](https://github.com/quaderno/quaderno-ruby/blob/master/spec/unit/test_quaderno_transaction.rb) you can get examples of parameters to use with this Ruby gem.

---

## License

(The MIT License)

Copyright © 2013-2023 Quaderno

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
