library(Rbbg)
conn <- blpConnect()

for (name in conn$DATETIME_OPTION_NAMES) {
  print(name)
}

for (name in conn$BOOLEAN_OPTION_NAMES) {
  print(name)
}

blpDisconnect(conn)

