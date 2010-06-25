cd webby; webby clobber; webby build; webby pdf; webby pdf; webby copy; cd ..
rsync -v -r --delete --exclude-from=script/rsync-exclude webby/output/ anaslist@ananelson.com:/home/anaslist/sites/findata.org
