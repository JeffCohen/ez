# EZ

* For educational purposes only.  Makes Rails a bit more beginner-friendly.
* Depends on Hirb ~> 0.7.1
* Patches the Rails dispatcher to avoid writing controllers for simple views by adding route support for `get "url" => "folder/file"`
* Enables instant modeling without migrations via `models.yml` and `rake ez:tables`
* Quick JSON API calls with `EZ.from_api(url)`, returns parsed Ruby hash (or array, etc.)
* Built-in `EZ.weather(location)` for classroom demo of API, to get quick hash and avoid JSON explanation.  Relies on http://openweathermap.org
* Adds controller and view helpers `current_user`, `user_signed_in?`, `sign_in_as`, and `sign_out` to avoid cookies/session hash details
* Adds ActiveRecord::Base `read` method to provide symmetry with `create`, `update`, and `delete`
* Adds ActiveRecord::Base `sample` method to choose a random row
* Patches Hirb to allow table output for `ActiveRecord::Relation` lists (i.e. result of `.all`, `.where` or `.read(:col => value)` but normal output for single ActiveRecord objects, like the result of `.find_by(:id => id)` or `read(id)`




