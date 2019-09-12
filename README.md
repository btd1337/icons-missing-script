# Identify Missing Icons

This script check your installed applications and scans an icon pack folder for missing icons. With data found in the `.desktop` files that has the applications information of your system, it generates a my_request.txt file that contains all the icons that are missing from an Icon Pack.

## How to use:

```
git clone https://github.com/btd1337/icons-missing-script
cd icons-missing-script
./identify-missing-icons.sh
```

A **my_request** file is generated in this folder so you can create a request in the icon pack repository. You must edit this file and place the links to the application icons in line `[Icon Link]()`

Example:

```
- [ ] quickDocs
Comment=A fast developer docs reader that supports Valadoc and DevDocs
Icon=com.github.mdh34.quickdocs
[Icon Link](https://github.com/mdh34/quickDocs/blob/master/data/icons/128/com.github.mdh34.quickdocs.svg)
```

## Passing optional language

If you need a language other than English use the `--lang` parameter and pass your language code

Example:

The Italian language code is `it`.

```
./identify-missing-icons.sh --lang it
```

Note that only the applications that have in the `.desktop` file data for the chosen language will have translation.


`.desktop` files are usually stored in the following folders:

```
/usr/share/applications
~/.local/share/applications
~/.local/share/flaptak/app
/var/lib/snapd/desktop/applications/
```
## Build

```
valac src/Main.vala --pkg sqlite3
```
