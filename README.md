![GitHub](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square)
# stringray
macOS command line tool for manipulating and validating  strings files

## Usage
**Sort** a table by key:
```
stringray sort /path/to/base.lproj/Table.strings
````

**Move** strings where the keys prefix matches a given string (or strings with multiple `-p` args passed)
```
stringray move /path/to/original.lproj/Table.strings /path/to/new.lproj/Table.strings -p cells.title
````

**Rename** string keys where the prefix matches a given string  (`-p` arg) with the replacement key prefix string (`-r` arg) 
```
stringray rename /path/to/original.lproj/Table.strings -p cells.title -r labels.title
````

**Lint** a strings table or list the lint rules:  
```
stringray lint -i /path/to/original.lproj/Table.strings
stringray lint -l
````

## Building
Use `make` to build or `make xcode` to generate the Xcode project.
