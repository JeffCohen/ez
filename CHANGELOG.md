*Version 1.9.7*

- Automatic routes/controllers/views are turned off by default.  Modify the .ez file to override.

*Version 1.5.0.4*
- Use `ApplicationRecord` as the model base class for Rails version >= 5

*Version 1.5.0.3*
- Fixed bug when configuring Hirb

*Version 1.5.0.2*

- Rails 5 compatibility
- Column deletion, model deletion, and column renaming applied in dev and test environments only
- Warning! Column type changes are allowed in ALL environments.
- Starting the console no longer evaluates `models.yml` file.  You must run `reload!` to apply any changes.
- Focused on domain modeling only. Removed old controller filters, generators, and view helpers.
- Removed dead code.
