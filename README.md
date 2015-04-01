# quaderno-ruby

Quaderno-ruby is a ruby wrapper for [Quaderno API] (https://github.com/quaderno/quaderno-api). 
As the API, it's mostly CRUD.

Current version is 1.5.5. See the changelog [here](https://github.com/quaderno/quaderno-ruby/blob/master/changelog.md)

## Installation & Configuration

To install add the following to your Gemfile:

```ruby
  gem 'quaderno', require: 'quaderno-ruby'
```

To configure just add this to your initializers

```ruby
  Quaderno::Base.configure do |config|
    config.auth_token = 'my_authenticate_token'
    config.subdomain = 'my_subdomain'
    config.environment = :production
  end
```

The `environment` attribute is optional and set to `:production` by default. Optionally, you can set it to `:sandbox` in order to test your application before deploying it to production.

## Get authorization data

You can get your account subdomain by grabbing it from your account url or by calling the authorization method with your personal api token.

```ruby
  Quaderno::Base.authorization 'my_authenticate_token', environment
  # => {"identity"=>{"id"=>737000, "name"=>"Walter White", "email"=>"cooking@br.bd", "href"=>"https://my_subdomain.quadernoapp.com/api/v1/"}} 
```

`environment` is an optional argument. By passing `:sandbox`, you will retrieve your credentials for the sandbox environment and not for production.

This will return a hash with the information about your api url, which includes the account subdomain.

## Ping the service
 You can ping the service in order to check if it is up with: 
 
```ruby
  Quaderno::Base.ping #=> Boolean
```

This will return true if the service is up or false if it is not.

## Check the rate limit

```ruby
  Quaderno::Base.rate_limit_info #=>  {:reset=>4, :remaining=>0} 
```

This will return a hash with information about the seconds until the rate limit reset and your remaining requests per minute ([check the API documentation for more information](https://github.com/quaderno/quaderno-api#rate-limiting)).

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
 Quaderno::Contact.all() #=> Array
 Quaderno::Contact.all(page: 1) #=> Array
```

 will return an array with all your contacts on the first page. You can also pass query strings using the attribute :q in order to filter the results by contact name. For example:
 
```ruby
 Quaderno::Contact.all(q: 'John Doe') #=> Array
```
 
### Finding a contact
```ruby
 Quaderno::Contact.find(id) #=> Quaderno::Contact
```

will return the contact with the id passed as parameter.

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
  Quaderno::Contact.delete(id) #=> Boolean
```

will delete the contact with the id passed as parameter.

## Managing items

### Getting items
```ruby
  Quaderno::Item.all() #=> Array
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
  Quaderno::Item.delete(id) #=> Boolean
```

will delete the item with the id passed as parameter.


## Managing invoices

### Getting invoices
```ruby
  Quaderno::Invoice.all #=> Array
  Quaderno::Invoice.all(page: 1) #=> Array
```

 will return an array with all your invoices on the first page. You can also pass query strings using the attribute :q in order to filter the results by contact name, :state to filter by state or :date to filter by date 

### Finding an invoice
```ruby
  Quaderno::Invoice.find(id) #=> Quaderno::Invoice
```

will return the invoice with the id passed as parameter.

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
  Quaderno::Invoice.delete(id) #=> Boolean
```

will delete the invoice with the id passed as parameter.

 
###Adding or removing a payment
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
 
###Delivering the invoice

  In order to deliver the estimate to the default recipient you will need the estimate you want to send.
  
```ruby
  invoice = Quaderno::Invoice.find(invoice_id)
  invoice.deliver
```


## Managing estimates


### Getting estimates
```ruby
  Quaderno::Estimate.all() #=> Array
  Quaderno::Estimate.all(page: 1) #=> Array
```

 will return an array with all your estimates on the first page.
 
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
  Quaderno::Estimate.delete(id) #=> Boolean
```

will delete the estimate with the id passed as parameter.

 
###Adding or removing a payment
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
 
###Delivering the estimate
  In order to deliver the estimate to the default recipient you will need the estimate you want to send.
  
```ruby
  estimate = Quaderno::Estimate.find(estimate_id)
  estimate.deliver
```

 
## Managing expenses

### Getting expenses
```ruby
 Quaderno::Expense.all() #=> Array
 Quaderno::Expense.all(page: 1) #=> Array
```

 will return an array with all your expenses on the first page. You can also pass query strings using the attribute :q in order to filter the results by contact name, :state to filter by state or :date to filter by date.
 
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
  Quaderno::Expense.delete(id) #=> Boolean
```

will delete the expense with the id passed as parameter.


## Managing webhooks

### Getting webhooks
```ruby
 Quaderno::Webhook.all() #=> Array
```

 will return an array with all the webhooks you have subscribed.
 
### Finding an webhook
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
  Quaderno::Webhook.delete(id) #=> Boolean
```
will delete the webhook with the id passed as parameter.



## Taxes

### Calculating taxes
```ruby
 Quaderno::Tax.calculate(params) #=> Quaderno::Tax
```

will calculate the taxes applied for a customer based on the data pased as parameters.


## Exceptions
Quaderno-ruby exceptions raise depending on the type of error:

```ruby
  Quaderno::Exceptions::InvalidSubdomainOrToken # Raised when the credentials are wrong, missing or do not match the permission for some object.

  Quaderno::Exceptions::RateLimitExceeded # Raised when the rate limit is exceeded.

  Quaderno::Exceptions::RequiredFieldsEmptyOrInvalid # Raised if the format of the request is right but some validations failed.
```


## More information

Remember this is only a ruby wrapper for the original API. If you want more information about the API itself, head to the original [API documentation](https://github.com/quaderno/quaderno-api).

## License
(The MIT License)

Copyright © 2013-2015 Quaderno

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


