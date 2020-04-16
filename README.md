<p align="center">
<i>(This project is not associated with the <a href="https://bitwarden.com/" title="Bitwarden">Bitwarden</a> project nor 8bit Solutions LLC.)</i>
</p>
<div align="center">
  <h1 align="center">Bitguarden</h1>
  <h3 align="center">Unofficial native bitwarden client for elementary OS</h3>
</div>

<br/>

<!--<p align="center">
    <a href="https://appcenter.elementary.io/com.github.denispalchuk.bitguarden">
        <img src="https://appcenter.elementary.io/badge.svg">
    </a>
</p>-->

<p align="center">
  <a href="https://github.com/DenisPalchuk/bitguarden/blob/master/LICENSE">
    <img src="https://img.shields.io/badge/License-GPL--3.0-blue.svg">
  </a>
  <a href="https://github.com/DenisPalchuk/bitguarden/releases">
    <img src="https://img.shields.io/badge/Release-v%200.1.0-orange.svg">
  </a>
</p>

  <br />
  <a href="https://github.com/DenisPalchuk/bitguarden/issues/new"> Report a problem! </a>
</p>

## Installation

### Dependencies
These dependencies must be present before building:
- `meson`
- `valac`
- `debhelper`
- `libgranite-dev`
- `libgtk-3-dev`
- `libsoup2.4-dev`
- `libjson-glib-dev`
- `libgcrypt20-dev`


Use the App script to simplify installation by running `./app install-deps`

 ### Building

```
git clone https://github.com/DenisPalchuk/bitguarden.git com.github.denispalchuk.bitguarden && cd com.github.denispalchuk.bitguarden
./app install-deps && ./app install
```

### Deconstruct

```
./app uninstall
```

### Development & Testing

Bitguarden includes a script to simplify the development process. This script can be accessed in the main project directory through `./app`.

```
Usage:
  ./app [OPTION]

Options:
  clean             Removes build directories (can require sudo)
  generate-i18n     Generates .pot and .po files for i18n (multi-language support)
  install           Builds and installs application to the system (requires sudo)
  install-deps      Installs missing build dependencies
  run               Builds and runs the application
  test              Builds and runs testing for the application
  test-run          Builds application, runs testing and if successful application is started
  beautify          Beautify code using uncrustify
  uninstall         Removes the application from the system (requires sudo)
```

### Contributing

To help look at the available [Issues](https://github.com/DenisPalchuk/bitguarden/issues). While some a labled "help wanted" you may pick anything to help out with so long as you notify me with a comment on the issue.


### License

This project is licensed under the GPL-3.0 License - see the [LICENSE](LICENSE.md) file for details.

### Resources used

* [https://github.com/jcs/rubywarden/blob/master/API.md](https://github.com/jcs/rubywarden/blob/master/API.md)
* [https://github.com/edas/bitwapi](https://github.com/edas/bitwapi)
* [https://github.com/bitwarden/jslib](https://github.com/bitwarden/jslib)
* [https://github.com/bitwarden/cli](https://github.com/bitwarden/cli)
