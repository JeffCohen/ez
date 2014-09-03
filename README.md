# EZ

**Version 0.9.8**

*For educational purposes only.*

Makes domain modeling in Rails more beginner-friendly by avoiding migrations.

Also enhances the rails console.


## Usage

```ruby
gem 'ez'
```

Then:

`rake db:migrate` to generate a skeleton `db/models.yml` that you should edit.


## Summary of Best Practices

1. Use `db/models.yml` to define your schema. Foreign-key indexes will be generated automatically.  (This should cover 100% of what most beginners will ever need to do.)

2. Use Rails migrations for any additional indexes, database constraints, etc.

3. Just use `rake db:migrate` as usual.  Nothing new to learn.



## Features


### 1. Domain Modeling Enhancements

* Enables **instant domain modeling without migrations** by using a file named `db/models.yml`.
* No new rake tasks to learn.  This gem enhances `db:migrate` to incorporate the `db/models.yml` file automatically.
* You can run `rake db:migrate` to initially generate a file named `db/models.yml`.  It will have some self-documenting comments inside of it.
* In development mode, there's no need to ever run `rake db:migrate`! Every brower request will trigger automatic table updates.
* In the rails console, 'reload!' will also trigger table updates.
* If you prefer, you can run `rake db:migrate` whenever you modify `db/models.yml`.
* `rake db:migrate` will run any pending migrations *after* following instructions in the `db/models.yml` file.



**Syntax Guide for `db/models.yml`**

It's just YAML and the syntax is very simple:

```
Book:
  title: string
  copies_on_hand: integer
  author_id: integer
  created_at: datetime
  updated_at: datetime
  paperback: boolean

Author:
  last_name: string
  first_name: string
  book_count: integer
```

**(Optional) Variations**

The colon after the model name is optional.

Also, you can often omit the column type and rely on conventions.  I don't recommend this for beginning students, but is very handy for experienced developers.  Rails conventions are embraced in `db/models.yml` resulting in these sensible defaults:

* If a column type isn't specified, it's assumed to be a `string` column.
* Column names ending in `_id` and `_count` are assumed to be of type `integer`.
* Column names ending in `_at` are assumed to be of type `datetime`.
* Column names ending in `_on` are assumed to be of type `date`.

Also, note that `_id` columns are further assumed to be foreign keys and will **automatically generate a database index for that column**.

So the above models could be written as:

```
Book
  title
  copies_on_hand: integer
  author_id
  created_at
  updated_at
  paperback: boolean

Author
  last_name
  first_name
  book_count
```

Finally, you can specify default values for columns in several ways.  Suppose we want to make sure that `copies_on_hand` always has the value `0` for new rows.  First, the fancy way:

```
Book
  title
  copies_on_hand: integer, default: 0
  author_id
  created_at
  updated_at
  paperback: boolean

Author
  last_name
  first_name
  book_count: integer, default: 0
```

The syntax is forgiving, so the comma and colon are just for readability; this would work too:

```
Book
  title
  copies_on_hand: integer default 0
  author_id
  created_at
  updated_at
  paperback: boolean

Author
  last_name
  first_name
  book_count: integer default 0
```

And for the extra lazy like me, you can use parentheses:

```
Book
  title
  copies_on_hand: integer(0)
  author_id
  created_at
  updated_at
  paperback: boolean

Author
  last_name
  first_name
  book_count(0)
```

* Boolean columns are assumed to be given a default of `false` if not otherwise specified.


### 2. More Model Enhancements

* Adds ActiveRecord::Base `.read` method so that models have complete *CRUD*: `.create`, `.read`, `.update`, and `.delete`.  When given an integer, `.read` becomes a synonym for `.find`.  When given a hash, it is a synonym for `.where`.
* Adds ActiveRecord::Base `.sample` method to choose a random row.
* Adds ActiveRecord::Base `[id]` method as a synonym for `.find_by(id: ...)`. Especially handy in the console, i.e. `Book[5]` instead of `Book.find_by(id: 5)` and in controllers: `Book[params[:id]]` if you don't find the double bracing too harsh to look at.


### 3. Beginner-friendly "It Just Works" console

* Solves the "no connection" message in Rails >= 4.0.1 (if you try to inspect a model without making a query first) by establishing an initial connection to the development database.
* Shows helpful instructions when console starts, including the list of model classes found in the application.
* Uses Hirb for table-like display. (Requires Hirb ~> 0.7.1)
* Patches Hirb to allow nice table output for `ActiveRecord::Relation` lists (i.e. result of `.all`, `.where`) and hash-like output for single ActiveRecord objects, such as the result of `.find_by(:title => 'Apollo 13')`.
* `reload!` will automatically trigger the table updates from the console.


### 4. Controller and View Enhancements

* Easier JSON API calls by calling `EZ.from_api(url)`; returns parsed Ruby hash (or array, etc.)
* Built-in view helper `<%= weather %>` and `EZ.weather` for classroom demo of a JSON API, to get quick hash and avoid gory details.  (Relies on http://openweathermap.org).  Default location is Evanston.  Can pass location: `<%= weather('San Diego, CA') %>`.  The `<%= weather %>` helper just delegates to `EZ.weather`.
* Adds view helper `map` to display a static Google map of any address. Example: `<%= map('Millenium Park, Chicago, IL') %>`
