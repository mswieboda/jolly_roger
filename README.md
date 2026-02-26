# Jolly Roger

## Installation

1. [Install SDL3]([https://wiki.libsdl.org/SDL3/Installation](https://github.com/libsdl-org/SDL/releases))

or install with favorite library / package manager

for example for macOS:

```
brew install sdl3 sdl3_image sdl3_ttf
```

will install all required libraries

2. Run `shards install`

```
shards install
```

3. Install GameSDL Tools

```
crystal lib/game_sdl/install_gsdl_tools.cr
```

installs tools to your `./bin` directory, such as `./bin/gsdl-packer`

which packages all assets into an `assets/assets.pack` binary file

see usage via:

```
./bin/gsdl-packer --help
```

## Documentation

To see full documentation of GameSDL, and SDL3 (included bindings library) you can run the `crystal docs` command, but specify the lib entry points, in correct order (SDL3 first, GSDL second, because GSDL depends on SDL3):

```
crystal docs lib/sdl3/src/sdl3.cr src/game_sdl.cr
```

or in your game:

```
crystal docs lib/sdl3/src/sdl3.cr lib/game_sdl/src/game_sdl.cr src/your_game_entry_point.cr
```

Unfortunately the `delegate` methods docs will not expand to full method signatures, so you'll need to infer wrapped classes like GSDL::Point that wraps SDL3::FPoint to see those method signatures. Eventually I plan to either document each delegate so the parameters and return types are clear, or fully wrap the methods themselves so it is even more clear.
