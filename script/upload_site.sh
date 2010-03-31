cd webby; webby; webby pdf; webby copy; cd ..
rsync -v -r --delete --exclude-from=script/rsync-exclude webby/output/ anaslist@ananelson.com:/home/anaslist/sites/findata.org
