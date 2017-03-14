#Changelog

##1.11.2
* Specify `Content-Type` header so `HTTParty` don't merge the elements within the body content.

##1.11.1
* Added `retrieve` method for `Quaderno::Contact`, `Quaderno::Invoice`, `Quaderno::Credit`
* Deprecate `retrieve_customer` as an alias of `retrieve`

##1.11.0
* Added `Quaderno::Tax.validate_vat_number` method

##1.10.0
 * Added location evidences support

##1.9.2
 * Added `Quaderno::Contact.retrieve` method
 * Code cleanup
 * Update tests

##1.9.1
 * `Quaderno::Base.authorization` raises `Quaderno::Exceptions::InvalidSubdomainOrToken` instead returning false on wrong credentials
 * Inherit from `StandardError` instead of `Exception` for `Quaderno::Exceptions` by **@mvelikov**

##1.9.0
 * Add support for new versioning system

##1.8.0
 * Add Quaderno::Receipt support
 * Fix errors in README

##1.7.3
 * Raise exception on failed updates

##1.7.2
 * Fix URL in `Quaderno::Tax.calculate` by [**@jcxplorer**] (https://github.com/jcxplorer)

##1.7.1
 * Breaking change: change configuration options

##1.7.0
 * Added recurring documents
 * Raise existent exception

##1.6.1
 * Fixed typo from old version released as 1.6.0

##1.6.0 (yanked)
 * Crud module refactor
 * Added support for credit notes

##1.5.5
 * Move rdoc as a development dependency

##1.5.4
* Remove transaction class.

##1.5.3
* Update `rate_limit_info` to fit the new rate limit
* Remove transaction information from README (future resource name change)
* Added new throttle limit exception (will be activated in future releases)

##1.5.1 and 1.5.2
* Remove debugger
* `Quaderno::Exceptions::RequiredFieldsEmpty` replaced with `Quaderno::Exceptions::RequiredFieldsEmptyOrInvalid`

##1.5.0
* Added transactions
* Raise `Quaderno::Exceptions::RequiredFieldsEmpty` for 422 responses

##1.4.2
* Find method hotfix

##1.4.1
* Fix wrong method name
* Use correct organization in url
* Add short description of the gem

##1.4.0
* Added taxes calculations support
* Added webhooks documentation

##1.3.2

* Use new urls format

##1.3.1

* Added sandbox environment
* Added `to_hash` instance method

##1.3.0

* Removed debug mode

##1.2.2

* Added ruby 2.0.0 compatibility

##1.2.1

* Deleted debugger dependency

##1.2.0

* Added Quaderno webhooks as a resource
* Added authorization method

##1.1.2

* Fixed minor bugs

##1.1.0

* Added Quaderno items as a resource
* Added filter in index queries

##1.0.0

* Initial release
