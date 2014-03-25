# EZ

For educational purposes only.  Makes Rails a bit more beginner-friendly.

### Console Enhancements

* Shows helpful instructions when console starts, including the list of model classes found in the application.
* Uses Hirb for table-like display. (Depends on Hirb ~> 0.7.1)
* Patches Hirb to allow table output for `ActiveRecord::Relation` lists (i.e. result of `.all`, `.where` or `.read(:col => value)` but normal output for single ActiveRecord objects, like the result of `.find_by(:id => id)` or `read(id)`

### Route Enhancements

* Patches the Rails dispatcher to avoid writing controllers for simple views by adding route support for `get "url" => "folder/file"`

### Model Enhancements

* Enables instant modeling without migrations via `models.yml` and `rake ez:tables`
* Adds ActiveRecord::Base `read` method to provide symmetry with `create`, `update`, and `delete`
* Adds ActiveRecord::Base `sample` method to choose a random row

### Controller and View Enhancements

* Easier JSON API calls by calling `EZ.from_api(url)`; returns parsed Ruby hash (or array, etc.)
* Built-in `EZ.weather(location)` for classroom demo of API, to get quick hash and avoid JSON explanation.  (Relies on http://openweathermap.org)
* Adds controller and view helpers `current_user`, `user_signed_in?`, `sign_in_as`, and `sign_out` to avoid cookies/session hash details
* Built-in `map` helper method to display a static map of any address. Example: `map('Millenium Park, Chicago, IL')`



