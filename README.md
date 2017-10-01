# status
This container makes it easy to monitor your network services with a simple configuration file.

Status is a traffic light status checker for any network service with an exposed port. Just put your services and their port numbers into a file and you're all set.

## Services definition
The services definition is in a JSON format. For a simple example, see the [default services file](https://github.com/JohnStarich/status/blob/master/default.json).

The first level in the definition contains the "domain" keys. These can be whatever you like! I typically use something like `"example.com"` or `"Main website"` to group all of one site's services together.

The second level are the services themselves: each with a protocol (`"tcp"` or `"udp"`), address (hostname or IP address), and the port to scan. Here is an example:

```json
{
    "Main Website": {
        "Web (HTTP)": {
            "protocol": "tcp",
            "address": "example.com",
            "port": 80
        },
        "Web (HTTPS)": {
            "address": "example.com",
            "port": 443
        },
        "MySQL": {
            "address": "192.168.1.2",
            "port": 3306
        }
    }
}
```

As you can see above, the protocol does not have to be defined because it defaults to `"tcp"`.

This file will be read by default from `services.json` in the same directory, but alternative methods are shown below.

## How to run it
You can run Status in three ways: from a custom services file, a JSON string, or standard input.

### File
If you have a file in your container where your services are defined, you can run one of the following:

```bash
# Use file already in the container
docker run --detach --publish 80:80 johnstarich/status file default.json
# Mount a file inside the container and use that instead
docker run --detach --publish 80:80 --volume /path/to/services.json:/var/www/html/services.json johnstarich/status file services.json
```

Be sure and replace `/path/to/services.json` with the path of your file.

### JSON String
If you want to feed the container a JSON string, you can do that too! Run something like this:

```bash
docker run --detach --publish 80:80 johnstarich/status json '{"example.com": {"Website": {"address": "example.com", "port": 80}}}'
```

### Standard Input
You can also read your services definition from stdin. This is a bit trickier, given that the docker CLI doesn't make it easy to pass in information like this. Unfortunately, after it starts running with interactive mode and stdin from a file, the `^C` signals don't work anymore.

Any of the following should work from a bash command line:

```bash
docker run -i --publish 80:80 johnstarich/status stdin < local_services_file.json
# or pipe it into the Docker command
cat local_services_file.json | docker run -i --publish 80:80 johnstarich/status stdin
```

#### Note:
This currently doesn't work very well with UDP ports because the UDP protocol doesn't have a standardized "received" response.

This means that a green light means the service's port is accessible, and a red light indicates the UDP service is *not* accessible.

