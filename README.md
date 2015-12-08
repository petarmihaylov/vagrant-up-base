WARNING: This is a WORK-IN-PROGRESS. I wouldn't even call it a beta version, more like early ALPHA.
---

This is a Vagrant configuration plus provisioning shell script that lets you easily `vagrant up` a local machine for development. It was forked from [kappataumu's] excellent [vagrant-up-github-pages](https://github.com/kappataumu/vagrant-up-github-pages).

Getting started is straightforward:

```
$ git clone https://github.com/petarmihaylov/vagrant-up-base.git
$ cd vagrant-up-base
$ sed -i 's#XXX#https://github.com/kappataumu/kappataumu.github.com.git#' bootstrap.sh
$ vagrant up
$ curl http://localhost:4000
```

Replace the contents between `sed -i 's#XXX#` and `bootstrap.sh` on line 3 with the actual repository you would like to clone as a base for your project.

If you don't have `sed` laying around, you can simply tweak `CLONEREPO` right at the top of `bootstrap.sh`, replacing `XXX` with the URL for the GitHub pages repository that will be the base of your project.

You should also modify the package list in `bootstrap.sh` to suit your needs. One package per line, please.

```
apt_package_check_list=(
    ...
)
```

If you are new to Vagrant, please checkout the [Vagrant Getting Started Guide](https://docs.vagrantup.com/v2/getting-started/) and for a much deeper dive (an excellent beginners guide) check out Wlodzimierz Gajda's book [Pro Vagrant](http://www.apress.com/9781484200742?gtmf=s)
