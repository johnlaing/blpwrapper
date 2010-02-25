context("basic")

test_that("connection works", {
  conn <- blpConnect("Java")
  print(conn)
})
