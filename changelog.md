# Changelog

## 3.0.0
* Added support for accounts API
* Added support for addresses API
* Added support for tax rates API
* Added support for tax jurisdictions API
* Added support for tax codes API
* Clean parameters sent in the create request
* Phase out legacy `Quaderno::Tax` class in favour of `Quaderno::TaxRate` (the class will be removed in the next release)
* Relaxed httparty requirements
* Detect and handle `bad_request` response codes
* Added `Quaderno::Exceptions::InvalidRequest` to handle `not_acceptable` response codes
* Added `Quaderno::Exceptions::BaseException#response_body` to check the API response error
* Removed legacy `Quaderno::Contact.retrieve_customer` in favor of `Quaderno::Contact.retrieve`

## 2.2.0
* Added support for transactions API
* Bumped webmock to 3.18

## 2.1.3
* Bumped dependency httparty to 0.21.0 by [**adamgiounas**](https://github.com/adamgiounas): https://github.com/quaderno/quaderno-ruby/pull/28

## 2.1.2
* Fixed a reference to non-existent variable by [**@fwitzke**](https://github.com/fwitzke)
## 2.1.1
* Added assign operator to the user_agent_header

## 2.1.0
* Added a new `Quaderno::Exceptions::ServerError` exception for more transparency, and better control of workflows
* Added a `user_agent_header` optional configuration to make debugging oauth integrations easier

## 2.0.2
* Fix an issue with the parameters sent during the `validate_vat_number` request
* Renames `validate_vat_number` into `validate_tax_id`

## 2.0.1
* Fix an issue where requests would result in an error due to a missing `require`

## 2.0.0
* **Breaking change** Pagination strategy has been updated to be cursor based. Collections no longer offer the `current_page` and `total_pages` methods, and offer `has_more?` and `next_page` instead. The `page` parameter is no longer supported either, in favour of the `created_before` parameter. [See more information in the documentation](https://developers.quaderno.io/api/#pagination).
* **Breaking change** `Quaderno::Tax.calculate` uses the [new tax calculation endpoint](https://developers.quaderno.io/api/#calculate-a-tax-rate). This endpoint accepts address parameters with the prefix `to_`. For example, `postal_code` is deprecated in favour of `to_postal_code`.
* `Quaderno::Tax.validate` uses the [new tax ID validation endpoint](https://developers.quaderno.io/api/#validate-a-tax-id). The signature did not change, and no updates are necessary.
* All requests now send the gem version in their User Agent header.

## 1.17.1
* Do not modify the input arguments when the thread-safe mode is used.

## 1.17.0
* Added `rate_limit_info` method to each API response
* **Breaking change:** `.delete` methods no longer returns a boolean but an instance of the removed object with a `deleted` attribute set to `true`
* **Breaking change:** `Quaderno::Base.ping` no longer returns a boolean but a `Quaderno::Base` instance with a `status` attribute.
* **Breaking change:** `Quaderno::Base.authorization` no longer returns a `Hash` but a `Quaderno::Base` instance with an `identity` attribute.
* **Breaking change:** `Quaderno::Base.me` no longer returns a `Hash` but a `Quaderno::Base` instance with all the attributes contained in the previous format.
* **Breaking change:** `Quaderno::Tax.validate_vat_number` no longer returns a boolean but a `Quaderno::Tax` instance with a `valid` attribute.
* **Breaking change:** `.deliver` no longer returns a `Hash` but a `Quaderno::Base` instance with a `success` attribute.
* **Breaking change:** Removed `Quaderno::Base.rate_limit_info`. Now it's an alias of `Quaderno::Base.ping`.

## 1.16.0
* Added `Quaderno::CheckoutSession`

## 1.15.2
* Relax `httparty` version requirement.

## 1.15.1
* Fix `Quaderno` load order.

## 1.15.0
* Removed `jeweler` and updated the gem structure.

## 1.14.0
* Added `domestic_taxes`, `sales_taxes`, `vat_moss`, `ec_sales` and `international_taxes` to `Quaderno::Report`

## 1.13.2
* Added index method to `Quaderno::Tax` as `Quaderno::Tax.all()`.

## 1.13.1
* Added `taxes` report to `Quaderno::Report`.

## 1.13.0
* Added `Quaderno::Report`.

## 1.12.5
* Added `create` method to `Quaderno::Income`.
* Fix `Quaderno::Base.ping` and `Quaderno::Base.me` methods.

## 1.12.4
* Use version headers on taxes requests.

## 1.12.3
* Return integers insteado of strings on pagination readers.

## 1.12.2
* Added `me` method.

## 1.12.0
* Added thread-safe credentials configuration.
* `all` methods returns a `Quaderno::Object` with pagination info instead of an `Array`

## 1.11.2
* Specify `Content-Type` header so `HTTParty` don't merge the elements within the body content.

## 1.11.1
* Added `retrieve` method for `Quaderno::Contact`, `Quaderno::Invoice`, `Quaderno::Credit`
* Deprecate `retrieve_customer` as an alias of `retrieve`

## 1.11.0
* Added `Quaderno::Tax.validate_vat_number` method

## 1.10.0
 * Added location evidences support

## 1.9.2
 * Added `Quaderno::Contact.retrieve` method
 * Code cleanup
 * Update tests

## 1.9.1
 * `Quaderno::Base.authorization` raises `Quaderno::Exceptions::InvalidSubdomainOrToken` instead returning false on wrong credentials
 * Inherit from `StandardError` instead of `Exception` for `Quaderno::Exceptions` by **@mvelikov**

## 1.9.0
 * Add support for new versioning system

## 1.8.0
 * Add Quaderno::Receipt support
 * Fix errors in README

## 1.7.3
 * Raise exception on failed updates

## 1.7.2
 * Fix URL in `Quaderno::Tax.calculate` by [**@jcxplorer**](https://github.com/jcxplorer)

## 1.7.1
 * Breaking change: change configuration options

## 1.7.0
 * Added recurring documents
 * Raise existent exception

## 1.6.1
 * Fixed typo from old version released as 1.6.0

## 1.6.0 (yanked)
 * Crud module refactor
 * Added support for credit notes

## 1.5.5
 * Move rdoc as a development dependency

## 1.5.4
* Remove transaction class.

## 1.5.3
* Update `rate_limit_info` to fit the new rate limit
* Remove transaction information from README (future resource name change)
* Added new throttle limit exception (will be activated in future releases)

## 1.5.1 and 1.5.2
* Remove debugger
* `Quaderno::Exceptions::RequiredFieldsEmpty` replaced with `Quaderno::Exceptions::RequiredFieldsEmptyOrInvalid`

## 1.5.0
* Added transactions
* Raise `Quaderno::Exceptions::RequiredFieldsEmpty` for 422 responses

## 1.4.2
* Find method hotfix

## 1.4.1
* Fix wrong method name
* Use correct organization in url
* Add short description of the gem

## 1.4.0
* Added taxes calculations support
* Added webhooks documentation

## 1.3.2

* Use new urls format

## 1.3.1

* Added sandbox environment
* Added `to_hash` instance method

## 1.3.0

* Removed debug mode

## 1.2.2

* Added ruby 2.0.0 compatibility

## 1.2.1

* Deleted debugger dependency

## 1.2.0

* Added Quaderno webhooks as a resource
* Added authorization method

## 1.1.2

* Fixed minor bugs

## 1.1.0

* Added Quaderno items as a resource
* Added filter in index queries

## 1.0.0

* Initial release
