#!/bin/dumb-init /bin/sh
set -e

GIT2CONSUL_CONFIG_DIR=/git2consul/config

# If you do not want to provide the config via binding a volume and the --config-file option,
# you can provide your config in json format via the environment variable GIT2CONSUL_LOCAL_CONFIG
if [ -n "$GIT2CONSUL_LOCAL_CONFIG" ]; then
	echo "$GIT2CONSUL_LOCAL_CONFIG" > "$GIT2CONSUL_CONFIG_DIR/local.json"
    set -- /usr/bin/node /usr/lib/node_modules/git2consul \
        --config-file $GIT2CONSUL_CONFIG_DIR/local.json \
        "$@"
fi

# If the user is trying to run git2consul directly with some arguments,
# in this case "--config-file", then pass all of them to git2consul.
if echo "$@" | grep -q "config-file"; then
    set -- /usr/bin/node /usr/lib/node_modules/git2consul \
        "$@"
fi

exec "$@"
