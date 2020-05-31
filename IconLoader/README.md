## Refactoryx

Refactoryx is an application for interacting with Alteryx workflows on a project/library basis.  It is meant to complement Designer with enhanced macro and folder operations, tasks that are difficult and prone to error today.  Some examples include:
- Convert all of your macros in all of your workflows to relative or absolute file paths
- Move macros and folders of macros to new locations and update the macro references in all workflows that use them
- Select tools in a workflow and extract them to a macro

**Refactoryx is NOT complete and should not be used in production!  It is under active development; there are no alpha, beta, or production releases available at this time.**

Multiple repositories comprise the entire Refactoryx application.  A unified project view of all outstanding enhancements and bugs is provided by the [ryx GitHub project](https://github.com/users/tlarsen7572/projects/1).

## IconLoader

IconLoader is a small sub-application used to load tool connection data and icons from Alteryx DLL files.  Output is in JSON format using stdout.