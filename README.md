# code-splash

A lightweight visual effects overlay for live coding presentations on macOS.

## Features

- **Transparent overlay window**: Always on top, click-through, fullscreen effects
- **HTTP-triggered animations**: Send code via POST request to trigger visual effects
- **Three effect types**: Scatter, PopOut, and Orbit animations (round-robin)
- **Concurrent animations**: Multiple effects can run simultaneously
- **Low CPU usage**: Optimized for real-time performance alongside audio processing

## Installation

```bash
swift build -c release
```

The executable will be located at `.build/release/code-splash`.

## Usage

### Start the server

```bash
# Default port (8080)
.build/release/code-splash

# Custom port
.build/release/code-splash -p 3000

# Show help
.build/release/code-splash --help
```

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

Effects are displayed in round-robin order:

1. **Scatter**: Characters fly out radially from the center
2. **PopOut**: Characters pop out sequentially with scaling
3. **Orbit**: Characters spiral outward in a circular motion

Each effect automatically fades out after 2-3 seconds.

## Options

- `-p, --port PORT`: Port number to listen on (default: 8080)
- `-h, --help`: Show help message

## Requirements

- macOS 13.0 or later
- Swift 5.9 or later

## License

GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
