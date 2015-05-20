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

## Help make it better

The entire Evercam codebase is open source, see details: http://www.evercam.io/open-source

Any questions or suggestions, drop us a line: http://www.evercam.io/contact
