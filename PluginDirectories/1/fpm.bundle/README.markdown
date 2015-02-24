#Flashlight Package Manager

A simple decentralized package manager for Flashlight.

Flashlight Package Manager allows Flashlight users to install any plugin that is hosted on Github. In order to work with Flashlight Package Manager the plugin must be in its own repository and the root of the repository must contain the `info.json` file.

It is good practice to add a `version` property to `info.json`. It is not used at the moment, it's just displayed in Spotlight, however versioning will be supported in the future.

## Supported commands

### Install plugins

    fpm install ~id(a)
    flashpm install ~id(a)

### Remove plugins

    fpm remove ~id(a)
    flashpm remove ~id(a)


## Credits

 * Icon: the icon is a mashup of [box](http://thenounproject.com/term/box/52632/) created by [MarkieAnn Packer](http://thenounproject.com/MarkieAnn/) and [Flashlight](http://thenounproject.com/term/flashlight/67679/) by [RJMetrics](http://thenounproject.com/rjmetrics/).
