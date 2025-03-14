# sxiv.yazi

Preview and select image files through [sxiv](https://github.com/xyb3rt/sxiv)


## Installation

```sh
ya pack -a NoponyAsked/sxiv
```

## Usage

Add this to your `~/.config/yazi/keymap.toml`:

```toml
[[manager.prepend_keymap]]
on   = ["c", "i"]
run  = "plugin sxiv"
desc = "Preview images in sxiv"
```


## License

This plugin is MIT-licensed. For more information check the [LICENSE](LICENSE) file.
