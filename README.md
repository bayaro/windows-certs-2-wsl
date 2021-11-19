

There is a common issue to work in WSL under DPI shield. When we have not access to secured endpoints.

The idea is to copy ca certificates from host Windows machine into WSL.

In Windows host machine use the suggested script 
  `get-all-certs.ps1`
to extract all windows ca certificates in the specially created folder `all-certificates` just in current folder.

And after link the created folder to `/etc/ssl/certs` and import its content. Go to WSL and do follow
```
  sudo mv /etc/ssl/certs /etc/ssl/certs.orig
  sudo ln -s /mnt/<path to the "all-certificates" folder> /etc/ssl/certs
  update-ca-certificates ## debian & ubuntu; centos, etc requires something else(?)
```

Enjoy :)

PS The wrapper around wsl start (to extract certificates before every wsl start) and adding `update-ca-certificates` into `.bashrc` I left for you ))

