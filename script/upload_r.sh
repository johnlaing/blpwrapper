rsync -v -r --delete R/ jlaing@findata.org:/home/jlaing/sites/r.findata.org
ssh jlaing@findata.org 'find /home/jlaing/sites/r.findata.org/bin -name "*.zip" | xargs chmod a+r'
