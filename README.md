# docker-git2consul

Docker image for [git2consul](https://github.com/Cimpress-MCP/git2consul), but with a few modifications. This image has support for various environment variables. Those env variables avoid the need to bind volumes to the container for the configuration of git2consul. This makes spinning up the container much simpler.

### Environment variables

* `CONSUL_ENDPOINT` - Consul endpoint
* `CONSUL_PORT` - Consul port
* `CONSUL_SECURE` - ( yes|no ) If connection to consul is using **https** or not
* `TOKEN` - Consul ACL token
* `SSH_CLIENT_CONFIG` - SSH client config
* `SSH_KEY` - SSH private key (base64 encoded)
* `SSH_KEY_PUB` - SSH public key (if really needed) (base64 encoded)
* `GIT2CONSUL_LOCAL_CONFIG` - Provide config during startup, instead of config file  

### Example

#### Docker native


```
CONSUL_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' consul)

docker run \
  -it \
  --rm \
  --name git2consul \
  -e CONSUL_ENDPOINT=consul.service.consul.company.com \
  -e CONSUL_PORT='8501' \
  -e CONSUL_SECURE=yes \
  -e TOKEN=xxx \
  -e SSH_CLIENT_CONFIG='
StrictHostKeyChecking no
UserKnownHostsFile /dev/null
VerifyHostKeyDNS yes' \
  -e SSH_KEY='xxx' \
  -e SSH_KEY_PUB='xxx' \
  -e GIT2CONSUL_LOCAL_CONFIG='{
  "version": "1.0",
      {
          "name" : "app1",
          "url" : "git@git.example.com:mygroup/myrepo.git",
          "branches" : ["master"],
          "include_branch_name": false,
          "source_root": "app1",
          "support_tags": false,
          "hooks": [
              {
                  "type" : "polling",
                  "interval" : "1"
              }
          ]
      }
  ]
}' \
  mschirrmeister/git2consul
```

#### Ansible playbook

`.ansible_vault_pass.sh`

```bash
#!/bin/bash

echo $ANSIBLE_VAULT_PASS
```

`docker-git2consul.yml`

```yml
---
# Example playbook command
# ansible-playbook docker-git2consul.yml --vault-password-file ~/.ansible_vault_pass.sh

- hosts: docker-git2consul
  become: yes
  user: "{{ ansible_user | default('ansibledeploy') }}"

  vars:
      container_recreate: "{{ recreate | default('no') }}"
      consul_token: "xxx"
      ssh_private_key: "xxx"
      ssh_public_key: "xxx"
      
  tasks:
      - name: Install dependencies
        yum: pkg={{ item }}
        with_items:
          - python-docker-py
          - python-httplib2
        tags:
            - docker:git2consul
        register: pkg_installed

      - name: Run git2consul
        docker_container:
            name: git2consul
            image: mschirrmeister/git2consul
            state: started
            recreate: "{{ container_recreate }}"
            env:
                CONSUL_ENDPOINT: "consul.service.consul.company.com"
                CONSUL_PORT: '8501'
                CONSUL_SECURE: yes
                TOKEN: "{{ consul_token }}"
                SSH_CLIENT_CONFIG: |
                  StrictHostKeyChecking no
                  UserKnownHostsFile /dev/null
                  VerifyHostKeyDNS yes
                SSH_KEY: "{{ ssh_private_key }}"
                SSH_KEY_PUB: "{{ ssh_public_key }}"
        tags:
            - docker:git2consul

```