

There is a common issue to work in WSL under DPI shield. When we don't have
access to secured endpoints.

The idea is to copy ca certificates from the host Windows machine into WSL.

In Windows host machine use the suggested script `get-all-certs.ps1`
to extract all windows ca certificates in the specially created folder
`all-certificates` just in the current folder.

Inside WSL create a symlink from the created folder to `/etc/ssl/certs`
and import its content.
```
  sudo mv /etc/ssl/certs /etc/ssl/certs.orig
  sudo ln -s /mnt/<path to the "all-certificates" folder> /etc/ssl/certs
  update-ca-certificates ## debian & ubuntu; centos, etc requires something else
```

Enjoy :)
