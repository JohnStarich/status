# status
Status is a green and red light style status checker for any service with a bound network port.

This means that you just have to throw your services into a file with their port numbers and you're all set.

## Services File
The services file is defined very simply in a JSON format. See the [default services](default.json) file for a quick example.

The document `{}` has the service domains defined in the first level. The second level are the service definitions themselves: each with a protocol, address, and port to check. Here is an example:

    {
        "Main Website": {
            "Web": {
                "protocol": "tcp",
                "address": "example.com",
                "port": 80
            },
            "Web SSL": {
                "address": "example.com",
                "port": 443
            }
        }
    }
As you can see, the protocol does not have to be defined as it assumes a default of "tcp".
Available protocols are "tcp" and "udp".

This file will be read by default from `services.json` in the same directory, but alternative methods are shown below.

## How to run it
You can start Status in any of three ways:

### File
If you have a file in your container where your services are defined, you can just run the following:

    docker run --detach --publish 80:80 johnstarich/status file default.json
Be sure and replace `default.json` with the name of your file.

### Json String
If you want to just feed the container a JSON string, you can do that too! Just run something like the following:

    docker run --detach --publish 80:80 johnstarich/status json '{"example.com": {"Website": {"address": "example.com", "port": 80}}}'

### Standard Input
Last, but not least, you can also read your services definition from stdin. This is a bit trickier, given that the docker CLI doesn't make it easy to pass in information like this.

Any of the following should work from a bash command line:

    docker run -i --publish 80:80 johnstarich/status stdin < local_services_file.json
    # or pipe it into the Docker command
    cat local_services_file.json | docker run -i --publish 80:80 johnstarich/status stdin
(Unfortunately, after it starts running, the `^C` signals don't work anymore.)

#### Note:
This currently doesn't work very effectively with UDP ports simply because it doesn't verify the program on the other end is actually receiving data.

So for now a red light means the service is definitely down while the green light means it is *most likely* up.

