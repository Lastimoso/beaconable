## 1.0.0.alpha (2025-12-17)

### Breaking Changes

- **Minimum Ruby version:** 3.2.0
- **Minimum Rails version:** 7.0

### Changed

- Replaced `OpenStruct` with new `AttributeSnapshot` class for better performance and explicit immutability
- `ObjectWas` now uses modern Rails 7+ dirty tracking API (`changes_to_save`) instead of iterating columns with `_was` methods
- Updated development dependencies to modern versions
- Fixed typo in gemspec: "patern" → "pattern"

### Why this change?

- `OpenStruct` is no longer auto-loaded in Ruby 3.2+ and shows deprecation warnings
- Modern Rails provides cleaner dirty tracking APIs
- This release marks the gem as stable and production-ready

---

## 0.3.4 (2022-03-14)

### Improvements

- Add `#beacon_metadata` & `#beacon_metadata=` method to included classes

## 0.3.3 (2020-11-02)

-  Fixes a bug that causes an error when a beaconable was touch by an association without changes

### Improvements
- Add `#skip_beacon` method to included clases

## 0.3.2 (2020-10-07)

### Improvements
- Add `#destroyed_entry?` method

## 0.3.1 (2020-09-16)

- Fixes #fire_beacon not to use dirty attributes to check changes

## 0.3.0 (2020-08-03)

- Changed ObjectWas initialization to wrap al all the changes for a transaction

 ## 0.2.2 (2019-12-16)

- Added new tests for chained methods
- Fixed chained methods

 ## 0.2.1 (2019-12-16)

- Made #field_change, #from and #to public

 ## 0.2.0 (2019-12-12)

- Added new test and fixes styles
- Added #field_change, #from, #to
