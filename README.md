# Quaderno-ruby

Quaderno-ruby is a ruby wrapper for [quaderno api] (https://github.com/recrea/quaderno-api). 
As the API, it's mostly CRUD.

Current version is 1.3.2. See the changelog [here](https://github.com/recrea/quaderno-ruby/blob/master/changelog.md)

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
  Quaderno::Base.rate_limit_info #=>  { :limit => 100, :remaining => 100 }
```

This will return a hash with information about the rate limit and your remaining requestes

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


## Quaderno-api 

For further information, please visit [quaderno api] (https://github.com/recrea/quaderno-api) wiki
