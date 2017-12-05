# EZ

Easy domain modeling in Rails without migrations.  

**Version 1.9.4**

*For educational purposes only.*

Tested against Rails 5.1.4.

_NOTE: For Rails < 5.0, use version 1.3_.

### Highlights

* Applies schema changes based on a file named `db/models.yml`.  
* Schema changes are applied by running `rails server`, `rails console`, or `reload!` in the console.
* Diffs are determined automatically and applied to the database.  
* Embraces Rails' column naming conventions by inferring columns types based on the name.
* Enhances the Rails Console with customized AwesomePrint and Hirb integration
* Adds two new ActiveRecord methods: `.sample(n = 1)` and `.none?`


### Installation

```ruby
gem 'ez'
```

Start the server or console to force the initial generation of
`db/models.yml` and a hidden configuration file named `.ez`.

Alternatively, you can run `rails db:migrate` to generate these files without running your app.

### Usage

1. Use `db/models.yml` to define your schema. Database schema changes are applied directly without affecting migrations.  (`rails db:migrate` will also trigger the changes).
2. Foreign-key indexes are generated automatically.
3. Use `rails db:migrate:preview` to perform a "dry run" based your `db/models.yml` file.
4. Use the `.ez` file to control functionality.
5. See the section on Migrations below.


|Config setting|Default|Description|
|----|----|----|
|models|true|Watches `models.yml` for changes.  Set to `false` to turn off all functionality|
|timestamps|true|Generates `created_at` and `updated_at` columns on every model.
|restful_routes|true|Adds `resources :<tablename>` to routes.rb for each model|
|controllers|true|Generates one controller per model with 7 empty methods.
|views|true|Generates the view folder for each model, with 7 empty views.

## Development vs Production

Renaming a column in `db/models.yml` appear to the gem as if you dropped
the old column and created a new column.  **You will lose any data you
had in that column**.  Same goes for renaming models: the old table
will be dropped.

In production, this could be catastrophic.  Therefore, this gem will
not delete tables or columns in production, only add tables and add
columns.  This could be problematic but is hopefully the 1% case.


## Syntax Guide for `db/models.yml`**

It's just YAML.  We recommend `text` instead of `string` columns (because of recent SQLite3 changes) but both are supported.

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


### ActiveRecord Enhancements

* `.sample` method to choose a random row, or `.sample(5)` for five sample rows.
* `.none?` method on a collection: `Product.where(in_stock: true).none?`
* `.to_ez` to generate a snippet from legacy models that you can paste into models.yml.


### Beginner-friendly Rails Console

* Shows helpful instructions when console starts, including the list of model classes found in the application.
* Solves the "no connection" message in Rails >= 4.0.1 (if you try to inspect a model without making a query first) by establishing an initial connection to the development database.
* Activates AwesomePrint.
* Uses Hirb for table-like display.
* Configures Hirb to allow nice table output for `ActiveRecord::Relation` collections
* Configures Hirb to produce hash-like output for single ActiveRecord objects


### Migrations

This gem is expecting that the student will not use database migrations
to control the schema.  It is ok to use both migrations
and `models.yml`, but be aware of the following:

* If at least one migration file is detected, this gem will not
removing tables that would normally removed via `models.yml` since
it's not possible to know if the table is supposed to be there or not.
* Where possible, it's best to translate a migration required for
a third-party gem (say, for Devise) into an entry in models.yml
so that everything is managed in one place.
Pull requests for integrating such features into `ez` are encouraged.
