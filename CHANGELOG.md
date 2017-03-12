*Version 1.5.0.2*

- Rails 5 compatibility
- Column deletion, model deletion, and column renaming applied in dev and test environments only
- Warning! Column type changes are allowed in ALL environments.
- Starting the console no longer evaluates `models.yml` file.  You must run `reload!` to apply any changes.
- Focused on domain modeling only. Removed old controller filters, generators, and view helpers.
- Removed dead code.
