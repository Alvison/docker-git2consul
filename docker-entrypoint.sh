#!/bin/dumb-init /bin/sh
set -e

GIT2CONSUL_CONFIG_DIR=/git2consul/config

if [ -n "${SSH_CLIENT_CONFIG}" ]; then
    if [ ! -d "${HOME}/.ssh" ]; then
        mkdir "${HOME}/.ssh"
    fi
    chmod 700 "${HOME}/.ssh"
    echo "${SSH_CLIENT_CONFIG}" > "${HOME}/.ssh/config"
    chmod 600 "${HOME}/.ssh/config"
fi

if [ -n "$SSH_KEY" ]; then
    if [ ! -d "${HOME}/.ssh" ]; then
        mkdir "${HOME}/.ssh"
    fi
    echo ${SSH_KEY} | base64 -d > "${HOME}/.ssh/id_rsa"
    echo ${SSH_KEY_PUB} | base64 -d > "${HOME}/.ssh/id_rsa.pub"
    chmod 700 -R "${HOME}/.ssh"
fi

# If you do not want to provide the config via binding a volume and the --config-file option,
# you can provide your config in json format via the environment variable GIT2CONSUL_LOCAL_CONFIG
if [ -n "${GIT2CONSUL_LOCAL_CONFIG}" ]; then
	echo "${GIT2CONSUL_LOCAL_CONFIG}" > "${GIT2CONSUL_CONFIG_DIR}/local.json"
    set -- /usr/bin/node /usr/lib/node_modules/git2consul \
        --config-file $GIT2CONSUL_CONFIG_DIR/local.json \
        "$@"
fi

# If the user is trying to run git2consul directly with some arguments,
# in this case "--config-file" or "--config_key", then pass all of them to git2consul.
if echo "$@" | grep -q "config"; then
    set -- /usr/bin/node /usr/lib/node_modules/git2consul \
        "$@"
fi

exec /usr/bin/node /usr/lib/node_modules/git2consul "$@"
