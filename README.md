# docker-git2consul

Docker image for [git2consul](https://github.com/Cimpress-MCP/git2consul), but with a few modifications. This image has support for various environment variables. Those env variables avoid the need to bind volumes to the container for the configuration of git2consul. This makes spinning up the container much simpler.

### Environment variables:

*   GIT2CONSUL_LOCAL_CONFIG - Provide config during startup, instead of config file  

### Example:
```
CONSUL_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' consul)

docker run -it --rm --name git2consul \
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
  mschirrmeister/git2consul --endpoint $CONSUL_IP --port 8500
```

