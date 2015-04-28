Flashlight
==========

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/nate-parrott/Flashlight?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

_The missing Spotlight plugin system_

_Das fehlende Plugin-System für Spotlight._

<img src='https://raw.github.com/nate-parrott/flashlight/master/Image.png' width='100%'/>

Flashlight is an **unofficial Spotlight API** that allows you to programmatically process queries and add additional results. It's *very rough right now,* and a *horrendous hack*, but a fun proof of concept.

_Have an idea for a plugin?_ [Suggest it](http://flashlight.nateparrott.com/ideas)

**Installation**

Clone and build using Xcode, or [download Flashlight.app from _releases_](https://github.com/nate-parrott/Flashlight/releases).

## Writing Plugins

**Start with the [tutorial on writing plugins](https://github.com/nate-parrott/Flashlight/wiki/Creating-a-Plugin).**

Once you're finished with a plugin, clone our repo, place your bundle in `PluginDirectories/1`, and we'll upload it to the online directory.

## Contributing

We welcome all contributions to the Flashlight core and plugins. See [the wiki](https://github.com/nate-parrott/Flashlight/wiki/Contributing-to-Flashlight-and-Plugins) for more info.

## Credits

Huge thanks to everyone who's contributed translations:

 - [xremix](http://github.com/xremix) and [DanielBocksteger](http://github.com/DanielBocksteger) for German
 - [matth96](http://github.com/matth96) for Dutch
 - [tiphedor](http://github.com/tiphedor) for French
 - [lipe1966](http://github.com/lipe1966) for Portugese
 - [chuyik](http://github.com/chuyik) for Chinese
 - [suer](http://github.com/suer) and [ymyzk](http://github.com/ymyzk) for Japanese
 - [andreaponza](http://github.com/andreaponza) for Italian
 - [iltercengiz](http://github.com/iltercengiz) for Turkish
 - [AlAdler](http://github.com/AlAdler) for Spanish
 - [readingsnail](http://github.com/readingsnail) for Korean
 - [davochka](http://github.com/davochka) for Russian
 - [dougian](http://github.com/dougian) for Greek
 - [Kejk](http://github.com/kejk) for Swedish
 - [majk-p](https://github.com/majk-p) for Polish
 - [jurgemaister](https://github.com/jurgemaister) for Norweigan
 - [/vlcekmi3](https://github.com/vlcekmi3) for Czech
 

If it's not translated into your native language yet, you should [consider helping us localize.](https://github.com/nate-parrott/Flashlight/wiki/Internationalization)

The iOS-style switches in the app (`ITSwitch.h/m`) are [ITSwitch](https://github.com/iluuu1994/ITSwitch), by [Ilija Tovilo](https://github.com/iluuu1994).

The code injection system is forked from [Norio Nomura](https://github.com/norio-nomura)'s [EasySIMBL](https://github.com/norio-nomura/EasySIMBL).

The [ZipZap library by Glen Low](https://github.com/pixelglow/zipzap) is used internally.

Licensed under the GPL and MIT licenses (see LICENSE).

**Helping out**

You can help out by [writing a plugin you want](https://github.com/nate-parrott/Flashlight/wiki/Creating-a-Plugin), taking a look at [the Github issues](https://github.com/nate-parrott/Flashlight/issues), or sharing the app with friends on Twitter or Facebook.
