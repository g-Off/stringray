![GitHub](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square)
# stringray
macOS command line tool for manipulating and validating  strings files

## Usage
Sort a table by key:
```
stringray sort /path/to/base.lproj/Table.strings
````

Move strings where the keys prefix matches a given string (or strings with multiple `-p` args passed)
```
stringray move /path/to/original.lproj/Table.strings /path/to/new.lproj/Table.strings -p cells.title
````

## Building
Use `make` to build or `make xcode` to generate the Xcode project.