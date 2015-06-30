# Evercam Media

Evercam Media is the component that is responsible for talking directly to the camera. Consider it as a "proxy" for all commands. Processes here request either snapshots or streams and then send them to the API, S3 Storage, or directly to any of the clients (e.g. Evercam-Dashboard , Evercam-Play-Android , Evercam-Play-iOS)

| Name   | Evercam Media  |
| --- | --- |
| Owner   | [@mosic](https://github.com/mosic)   |
| Version  | 1.0 |
| Evercam API Version  | 1.0  |
| Licence | [AGPL](https://tldrlegal.com/license/gnu-affero-general-public-license-v3-%28agpl-3.0%29) |

## Features

* Built using Elixir & Phoenix
* Request snapshots from snapshot endpoint
* Request rtsp stream from rtsp endpoint
* Convert rtsp stream to rtmp
* store snapshots to S3 bucket

## Come on in, the water's warm :)

We've identified some tasks as good one's to just "Dip your toe" into our codebase: [Toe Dipper Issues](https://github.com/evercam/evercam-media/labels/Difficulty%20-%20Toe%20Dipper)

And, there's a reward of a lifetime's subscription to [Elixir Sips](http://elixirsips.com/) for anyone who solves an issue :)

The entire Evercam codebase is open source, see details: http://www.evercam.io/open-source

Any questions or suggestions, drop us a line: http://www.evercam.io/contact
