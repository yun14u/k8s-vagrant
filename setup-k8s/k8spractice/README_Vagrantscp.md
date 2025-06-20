# README

## Purpose
While experiment with K8s cluster, this procedure is to preserver the experiment artifact(s).

## Copy from Vagrant host

### Get ssh configuration for specific Vagrant host
```
vagrant ssh-config sbmaster01 > vagrant-ssh-config.tmp
```

### Execute rsync command
```
rsync -avz -e "ssh -F vagrant-ssh-config.tmp" sbmaster01:/var/tmp/artifact/ .
```

