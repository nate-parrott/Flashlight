# Internationalization


## Translating Flashlight.app

`Flashlight.app` is currently translated into English and German. (Thanks [xremix](https://github.com/xremix)!) If you're fluent in another language, it'd be awesome if you could translate it.

Flashlight is translated via the usual OS X app localization methods. You'll want to copy [en.lproj](https://github.com/nate-parrott/Flashlight/tree/master/FlashlightApp/EasySIMBL/en.lproj), replace `en` with your language code, and translate the strings in `Localizable.strings`. See [the German translation](https://github.com/nate-parrott/Flashlight/blob/master/FlashlightApp/EasySIMBL/de.lproj/Localizable.strings) for an example.

## Translating your plugin

Different parts of your plugin should be internationalized in different ways:

**Info.json** keys like `displayName` and `description` should be localized by adding new keys with names like `displayName_zh` and `description_zh`, where `zh` is replaced with your language code. Do _not_ translate `categories`.

**Examples.txt** can be translated by adding new `examples_zh.txt` files. Make sure to translate the commands and sample text, but not the field names. (e.g. `天气在 ~place(上海)`)

**Strings** that are returned by Python can be translated any way you'd like. The easiest way is probably to use Flashlight's `i18n` module. The strings you're going to display to the user, put them in a file called `strings_zh.json`, using the English phrases as keys and the translated phrases as values, and then call `i18n.localstr("english text")` to get a local string.

**Other files** like HTML can be localized by copying them with names like `myHTML_zh.html`, then getting the _appropriate localized file's path_ by calling `i18n.find_localized_path("myHTML.html")`.

_A good example of a localized plugin is the [timezone plugin](https://github.com/nate-parrott/Flashlight/tree/master/PluginDirectories/1/timezone.bundle)._
