# code-splash

A lightweight visual effects overlay for live coding presentations on macOS.

## Features

- **Transparent overlay window**: Always on top, click-through, fullscreen effects
- **HTTP-triggered animations**: Send code via POST request to trigger visual effects
- **Five effect types**: Dynamic visual effects with random selection (prevents 3+ consecutive repeats)
- **Concurrent animations**: Multiple effects can run simultaneously
- **Adjustable opacity**: Control effect visibility to minimize coding interference
- **Low CPU usage**: Optimized for real-time performance alongside audio processing

## Installation

### Build with CMake (recommended)

Generate build system. For debug builds, specify `-DCMAKE_BUILD_TYPE=Debug`.

```
cd /path/to/code-splash
cmake -B build -DCMAKE_BUILD_TYPE=Release
```

build.

```
cmake --build build
```

The executable will be located at `build/bin/code-splash`.

### Alternative: Build with Swift Package Manager

```bash
swift build -c release
```

The executable will be located at `.build/release/code-splash`.

## Usage

### Start the server

```bash
# Using CMake build
build/bin/code-splash

# Or using release build
release/code-splash
```

### Options

- `-p, --port PORT`: Port number to listen on (default: 8080)
- `-o, --opacity OPACITY`: Maximum opacity for effects, 0.0-1.0 (default: 1.0)
- `-h, --help`: Show help message

### Trigger effects

Send code text via HTTP POST to the `/effect` endpoint:

```bash
# From a file
curl -X POST http://localhost:8080/effect --data-binary @file.txt

# From stdin
echo "const hello = 'world';" | curl -X POST http://localhost:8080/effect --data-binary @-
```

### VSCode integration

Add to your `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "code-splash",
      "type": "shell",
      "command": "curl -X POST http://localhost:8080/effect --data-binary @${file}",
      "presentation": {
        "reveal": "never"
      }
    }
  ]
}
```

## Effect Types

Effects are randomly selected with intelligent prevention of excessive repetition (same effect won't appear more than twice in a row):

1. **Scatter**: Characters burst out from the code block in all directions with physics-based motion
2. **PopOut**: Characters leap off the screen one after another with 3D perspective and gravity
3. **Orbit**: Text rotates along a pseudo-3D elliptical orbit path
4. **Scroll**: A mass of code scrolls vertically at high speed across the screen
5. **Accelerate**: Lines of code flow in from the side, accelerate, and shoot away

Each effect features dynamic positioning, gradient colors, and automatic cleanup.

## Requirements

- macOS 13.0 or later
- Swift 5.9 or later

## License

GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
