# EZ

**Version 1.5.0.3**

*For educational purposes only.*

Tested against Rails 5.1.1.

_NOTE: For Rails < 5.0, use version 1.3_.

Easy domain modeling in Rails without migrations.  

* Applies instant schema changes based on a file named `db/models.yml`.  
* Schema changes applied automatically when code is reloaded.
* Diffs are determined automatically and applied to the database.  
* Embraces Rails' column naming conventions by inferring columns types based on the name.
* Enhances the Rails Console with customized AwesomePrint and Hirb integration
* Adds two new ActiveRecord methods: `.sample(n = 1)` and `.none?`


## Usage

```ruby
gem 'ez'
```

Then start your server or console to force the initial generation of
`db/models.yml` and a configuation file named `.ez`.

Alternatively, you can run `rails db:migrate` to generate these files without running your app.

## Get Started

1. Use `db/models.yml` to define your schema. Database schema changes are applied directly and triggered automatically in development mode.  (`rails db:migrate` will also trigger the changes).  Foreign-key indexes will be generated automatically.

2. Run `rails db:migrate:preview` to do a "dry run" and see what would change based your `db/models.yml` file.


2. Use the `.ez` file to control functionality.


|Config setting|Default|Description|
|----|----|----|
|models|true|Watches `models.yml` for changes.  Set to `false` to turn off all functionality|
|restful_routes|true|Adds `resources :<tablename>` to routes.rb for each model|
|controllers|true|Generates one controller per model with 7 empty methods.
|views|true|Generates the view folder for each model, with 7 empty views.
|timestamps|true|Generates `created_at` and `updated_at` columns on every model.


## Syntax Guide for `db/models.yml`**

It's just YAML.  We recommend `text` instead of `string` columns but both are supported.

```
Book:
  title: text
  author_id: integer
  created_at: datetime
  updated_at: datetime
  paperback: boolean

Author:
  last_name: text
  first_name: text
  book_count: integer
```

**(Optional) Variations**

1. The colon after the model name is optional.

2. Rails conventions are embraced in `db/models.yml` resulting in these sensible defaults:

   * If a column type isn't specified, it's assumed to be a `text` column.
   * Column names ending in `_id` and `_count` are assumed to be of type `integer`.
   * Column names ending in `_at` are assumed to be of type `datetime`.
   * Column names ending in `_on` are assumed to be of type `date`.

Also, note that `_id` columns are assumed to be foreign keys and will **automatically generate a database index for that column**.

So the above models could be written as:

```
Book
  title
  author_id
  created_at
  updated_at
  paperback: boolean

Author
  last_name
  first_name
  book_count
```

**Default Values**
You can specify default values for columns right after the column type:

```
Book
  title
  author_id
  created_at
  updated_at
  paperback: boolean(false)

Author
  last_name
  first_name
  book_count: integer(0)
```

* Boolean columns are assumed to be given a default of `false` if not otherwise specified.


### 2. ActiveRecord Enhancements

* Adds `.sample` method to choose a random row.
* Adds `.to_ez` to generate a snippet from legacy models that you can paste into models.yml.


### 3. Beginner-friendly "It Just Works" console

* Solves the "no connection" message in Rails >= 4.0.1 (if you try to inspect a model without making a query first) by establishing an initial connection to the development database.
* Shows helpful instructions when console starts, including the list of model classes found in the application.
* Activates AwesomePrint in the Rails consol.
* Uses Hirb for table-like display.
* Configures Hirb to allow nice table output for `ActiveRecord::Relation` collections
* Configures Hirb to produce hash-like output for single ActiveRecord objects
